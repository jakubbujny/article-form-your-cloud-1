package main

import (
	"net/http"
	"github.com/gorilla/mux"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"log"
	"text/template"
	"io"
	"io/ioutil"
	"time"
	"bytes"
	"strconv"
	"encoding/base64"
	"strings"
)

//source: https://davidwalsh.name/browser-camera
const site_template string = `
<html>
<body>
<video id="video" width="640" height="480" autoplay></video><br />
<button id="snap">Snap&Upload</button><br />
<canvas id="canvas" width="640" height="480" style="display: none"></canvas>
<br /><br />
{{ range $key, $value := . }}
   <li><a href="/image/{{ $value.Key }}">{{ $value.Key }}</a></li>
{{ end }}
<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>
<script>
var video = document.getElementById('video');

if(navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    navigator.mediaDevices.getUserMedia({ video: true }).then(function(stream) {
        video.src = window.URL.createObjectURL(stream);
        video.play();
    });
}
// Elements for taking the snapshot
var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');
var video = document.getElementById('video');

document.getElementById("snap").addEventListener("click", function() {
	context.drawImage(video, 0, 0, 640, 480);
	$.ajax({
        url: '/image',
        type: 'POST',
        data: canvas.toDataURL("image/jpeg"),
        success: function (data) {
            if (data.error) {
                alert(data.error);
                return;
            }
			location.reload();
        }, 
        error : function (r, s, e) {
                alert("Unexpected error:" + e);
                console.log(r);
                console.log(s);
                console.log(e);
            } 
        });
});
</script>
</body>

</html>
`

func SpawnAwsSdkS3Service() *s3.S3 {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("eu-central-1")},
	)
	if err != nil {
		panic(err)
	}
	return s3.New(sess)
}
func GetRootSite(ResponseWriter http.ResponseWriter, _ *http.Request) {
	svc := SpawnAwsSdkS3Service()
	resp, err := svc.ListObjects(&s3.ListObjectsInput{Bucket: aws.String("jakubbujny-article-form-your-cloud-1-photos")})
	if err != nil {
		panic(err)
	}

	tmpl, err := template.New("hello").Parse(site_template)
	if err != nil { panic(err) }
	err = tmpl.Execute(ResponseWriter, resp.Contents)
	if err != nil { panic(err) }
}

func GetImage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	w.WriteHeader(http.StatusOK)
	svc := SpawnAwsSdkS3Service()
	resp, err := svc.GetObject(&s3.GetObjectInput{Bucket: aws.String("jakubbujny-article-form-your-cloud-1-photos"), Key: aws.String(vars["image_name"])})
	if err != nil {
		panic(err)
	}
	w.Header().Set("Content-Type", "image/jpeg")
	io.Copy(w, resp.Body)
}

func SaveImage(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	svc := SpawnAwsSdkS3Service()
	decoded, err := base64.StdEncoding.DecodeString(strings.Split(string(body), ",")[1])
	if err != nil {
		panic(err)
	}
	_ , err1 := svc.PutObject(&s3.PutObjectInput{Key: aws.String(strconv.FormatInt(time.Now().UnixNano(), 10)+".jpg"), Bucket: aws.String("jakubbujny-article-form-your-cloud-1-photos"), Body: bytes.NewReader(decoded)})
	if err1 != nil {
		panic(err1)
	}
	w.WriteHeader(http.StatusOK)
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", GetRootSite).Methods("GET")
	router.HandleFunc("/image/{image_name}", GetImage).Methods("GET")
	router.HandleFunc("/image", SaveImage).Methods("POST")
	log.Fatal(http.ListenAndServe(":8000", router))
}