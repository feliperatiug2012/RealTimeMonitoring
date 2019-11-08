$(document).ready(function () {
    window.onload = function () {
        document.getElementById("sendButton").onclick = function () {
            url = "ws://localhost/websocket/webSocketsServer.ashx?chatName=" + $("#name").val();
            w = new WebSocket(url);
            w.onopen = function () {
                log("open");
                w.send("sale dato ");
            };
            w.onmessage = function (e) {
                log(e.data.toString());
            };
            w.onclose = function (e) {
                log("close");
            };
            w.onerror = function (e) {
                log("eror");
            };
            w.send(document.getElementById("inputMessage").value);
        };
    };
    function log(s) {
        var logOutput = document.getElementById("logOutput");
        var el = $("#logOutput").after('<p>' + s + '<p>');
        $("p").slice(2).addClass("highlight");
    }
});