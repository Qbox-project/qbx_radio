var QBRadio = {};

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

        fetch(`https://${GetParentResourceName()}/leaveRadio`, {
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
        });
    });

    document.getElementById('increaseradiochannel').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/increaseradiochannel`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
        });
    });

    document.getElementById('poweredOff').addEventListener('click', function (e) {
        e.preventDefault();

        fetch(`https://${GetParentResourceName()}/poweredOff`, {
            method: 'POST',
            body: JSON.stringify({
                channel: document.getElementById("channel").value
            })
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
