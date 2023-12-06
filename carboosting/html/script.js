CarBoosting = {}
CarBoosting.Functions = {}

CarBoosting.Classes = ["D", "C", "B", "A", "S"];
CarBoosting.Rep;
CarBoosting.Contracts = {}
CarBoosting.CanDoContract;

// event gets called from client.lua to start game
$(document).ready(function () {
    window.addEventListener('message', function(event) {
        if (event.data.action == "Show") {   
            CarBoosting.Rep = event.data.rep;
            CarBoosting.Contracts = event.data.contracts;
            CarBoosting.CanDoContract = event.data.allowed;
            CarBoosting.Functions.Show();
        }
    });
})

function OnCloseButtonClick() {
    CarBoosting.Functions.Hide();
}

function OnAcceptButtonClick(e) {
    $.post('https://jens-CarBoosting/StartContract', JSON.stringify({
        selectedContract: e.target.classList[2],
    }));
    CarBoosting.Functions.Hide();
}

// Open the window, load HTML and start game after 3 sec
CarBoosting.Functions.Show = function () {
    $("#container").show();
    $("#rep-progress").html("Current class: " + GetClassFromRep(CarBoosting.Rep) + "&emsp; " + CarBoosting.Rep % 100 + "/100 &emsp; Next class: " + GetClassFromRep(CarBoosting.Rep + 100));

    for (let i = 0; i < CarBoosting.Contracts.length; i++) {
        if (CarBoosting.Classes.indexOf(CarBoosting.Contracts[i][0]) <= CarBoosting.Classes.indexOf(GetClassFromRep(CarBoosting.Rep))){
            AddContract(CarBoosting.Contracts[i], i);
        }
    }

    if (CarBoosting.CanDoContract) {
        $(".accept-button").prop("disabled",true);
    }
}

// close window and post 
CarBoosting.Functions.Hide = function () {
    $("#container").hide();
    $.post('https://jens-CarBoosting/Hide');
    $("#contracts").html("");
}

function GetClassFromRep(rep) {
    let index = Math.floor(rep / 100);
    let contractClass = CarBoosting.Classes[index];
    return contractClass != null ? contractClass : "None"
}

function AddContract(contract, count) {
    $("#contracts").append(
        "<div id='contract-background'>" +
        "<div class='text-container'>" +
        "<p class='class-text'>" + contract[0] + "</p>" +
        "<p>&emsp;Price: " + contract[2] + " Bits</p>" +
        "<p>&emsp;Model: " + contract[1] + "</p>" + 
        "</div>" +
        "<input class='button accept-button " + count + "' type='button' value='Accept'>" +
        "</div>"
    )
}

$(document.body).on("click", ".accept-button", OnAcceptButtonClick);

// for testing in browser
// CarBoosting.Rep = 500; 
// CarBoosting.Functions.Show();







