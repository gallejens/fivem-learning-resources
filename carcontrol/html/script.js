CarControl = {}
CarControl.Functions = {}

// event gets called from client.lua to open
$(document).ready(function () {
    window.addEventListener('message', function (event) {
        if (event.data.Action == "Show") {
            CarControl.DoorAmount = event.data.DoorAmount;
            CarControl.EngineStatus = event.data.EngineStatus;
            CarControl.Functions.Show();
        }
    });
});

// Open the window, load HTML and start game after 3 sec
CarControl.Functions.Show = function () {
    $("#container").show();
    LoadHTML()
}

// close window and post 
CarControl.Functions.Hide = function () {
    $("#container").hide();
    $.post('https://jens-CarControl/Hide');
}

// add event when clicked on block
$(document.body).on("click", ".button", OnButtonClick);
$(document).on('keydown', (e) => {
    if (e.keyCode == 27) {
        CarControl.Functions.Hide();
    }
});

function OnButtonClick(e) {
    let clickedButton = e.target;
    let buttonName = clickedButton.classList[1];

    let index = 0;
    if (buttonName == "window" || buttonName == "door" || buttonName == "seat") {
        index = clickedButton.classList[2];
    }

    $.post('https://jens-CarControl/ButtonClicked', JSON.stringify({
        Name: buttonName,
        Index: index,
    }))
}

function LoadHTML() {
    $("#grid").html(
        "<div class='button hide'></div>" +
        "<div class='button door 4'>H</div>" +
        "<div class='button engine'>E</div>" +
        "<div class='button hide'></div>" +
        "<div class='button door 5'>T</div>" +
        "<div class='button hide'></div>" +
        "<div class='button window 0'>W1</div>" +
        "<div class='button door 0'>D1</div>" +
        "<div class='button seat -1'>S1</div>" +         
        "<div class='button seat 0'>S2</div>" +
        "<div class='button door 1'>D2</div>" +
        "<div class='button window 1'>W2</div>" +
        "<div class='button window 2'>W3</div>" +
        "<div class='button door 2'>D3</div>" +
        "<div class='button seat 1'>S3</div>" +
        "<div class='button seat 2'>S4</div>" +
        "<div class='button door 3'>D4</div>" +
        "<div class='button window 3'>W4</div>"
    );
}







