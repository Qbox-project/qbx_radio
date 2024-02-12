let QBRadio = {};

window.addEventListener('DOMContentLoaded', function () {
    window.addEventListener('message', function (event) {
        if (event.data.type == "open") {
            QBRadio.SlideUp();
        }

        if (event.data.type == "close") {
            QBRadio.SlideDown();
        }
    });

    document.onkeyup = function (data) {
        if (data.key == "Escape") {
            fetch(`https://${GetParentResourceName()}/escape`, {
                method: 'POST',
                body: JSON.stringify({})
            });
            QBRadio.SlideDown();
        } else if (data.key == "Enter") {
            fetch(`https://${GetParentResourceName()}/joinRadio`, {
                method: 'POST',
                body: JSON.stringify({
                    channel: document.getElementById("channel").value
                })
            });
        }
    };

    document.getElementById('toggleClicks').addEventListener('click', function (e) {
        e.preventDefault();
        fetch(`https://${GetParentResourceName()}/toggleClicks`, {
            method: 'POST',
        });
    });

    document.getElementById('submit').addEventListener('click', function (e) {
        e.preventDefault();
        fetch(`https://${GetParentResourceName()}/joinRadio`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
        });
    });

    document.getElementById('disconnect').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/leaveChannel`, {
            method: 'POST'
        });
    });

    document.getElementById('volumeUp').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/volumeUp`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
        });
    });

    document.getElementById('volumeDown').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/volumeDown`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
        });
    });

    document.getElementById('decreaseradiochannel').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/decreaseradiochannel`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
        }).then(response => response.json()).then(newChannel => {
            document.getElementById("channel").value = newChannel;
        });
    });

    document.getElementById('increaseradiochannel').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/increaseradiochannel`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
        }).then(response => response.json()).then(newChannel => {
            document.getElementById("channel").value = newChannel;
        });
    });

    document.getElementById('powerButton').addEventListener('click', function (e) {
        e.preventDefault();

        document.getElementsByClassName("channel")[0].style.display = "none";
        fetch(`https://${GetParentResourceName()}/powerButton`, {
            method: 'POST',
        }).then(response => response.json()).then(data => {
            if (data == "on") {
                document.getElementsByClassName("channel")[0].style.display = "block";
            } else {
                document.getElementsByClassName("channel")[0].style.display = "none";
            }
        });
    });

    QBRadio.SlideUp = function () {
        document.getElementById("container").style.display = "block";
        document.getElementById("radio-container").animate({ bottom: "6vh" }, 250).onfinish = function () {
            document.getElementById("radio-container").style.bottom = "6vh";
        };
    };

    QBRadio.SlideDown = function () {
        document.getElementById("radio-container").animate({ bottom: "-110vh" }, 400).onfinish = function () {
            document.getElementById("container").style.display = "none";
        };
    };
});