package main

import (
	"net/http"
	"github.com/gorilla/mux"
	"log"
	"text/template"
)

//https://davidwalsh.name/browser-camera
const site_template string = `
<html>
<body>
<video id="video" width="640" height="480" autoplay></video><br />
<button id="snap">Snap&Upload</button><br />
<canvas id="canvas" width="640" height="480"></canvas>
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

// Trigger photo take
document.getElementById("snap").addEventListener("click", function() {
	context.drawImage(video, 0, 0, 640, 480);
});
</script>
</body>

</html>
`

func GetRootSite(response_writer http.ResponseWriter, _ *http.Request) {
	tmpl, err := template.New("hello").Parse(site_template)
	if err != nil { panic(err) }
	err = tmpl.Execute(response_writer, nil)
	if err != nil { panic(err) }
}

func GetImage(w http.ResponseWriter, r *http.Request) {

}

func SaveImage(w http.ResponseWriter, r *http.Request) {

}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", GetRootSite).Methods("GET")
	router.HandleFunc("/image/{image_name}", GetImage).Methods("GET")
	router.HandleFunc("/image/{image_name}", SaveImage).Methods("POST")
	log.Fatal(http.ListenAndServe(":8000", router))
}