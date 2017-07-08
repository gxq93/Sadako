var refreshDelay = 500;
var footerElement = null;

function updateTimestamp() {
    var now = new Date();
    footerElement.innerHTML = "Last updated on " + now.toLocaleDateString() + " " + now.toLocaleTimeString();
}

function refresh() {
    var timeElement = document.getElementById("maxTime");
    var maxTime = timeElement.getAttribute("data-value");
    console.log(maxTime);
    timeElement.parentNode.removeChild(timeElement);
                                           
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4) {
            if (xmlhttp.status == 200) {
                var contentElement = document.getElementById("content");
                contentElement.innerHTML = contentElement.innerHTML + xmlhttp.responseText;
                updateTimestamp();
                setTimeout(refresh, refreshDelay);
            } else {
                footerElement.innerHTML = "<span class=\"error\">Connection failed! Reload page to try again.</span>";
            }
        }
    }
    xmlhttp.open("GET", "/output?after=" + maxTime, true);
    xmlhttp.send();
}
                                                             
window.onload = function() {
    footerElement = document.getElementById("footer");
    updateTimestamp();
    setTimeout(refresh, refreshDelay);
}
