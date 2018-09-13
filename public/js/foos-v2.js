function log() {
  console.log("[V2]", ...arguments);
}

function startup() {
  getDivisions();
}

function createDivisionSelector(division) {
  const element = document.createElement("li");
  element.classList.add("tab-division");
  if (division.isActive) {
    element.classList.add("active");
  }

  const anchor = document.createElement("a");
  anchor.href = "/#15-" + division.id.toString();
  anchor.dataset = {
    "division-id": division.id.toString()
  };
  anchor.innerHTML = "<span>" + division.title + "</span>";

  element.appendChild(anchor);
  element.onclick = function(event) {
    // Load division data
    division_id = division.id;
    load_division_subsection(division_id);

    // Remove active elements
    $(".tab-division").removeClass("active");

    // Mark tab as active
    element.classList.add("active");
  };

  return element;
}

function getDivisions(seasonId) {
  var season = seasonId || default_season_id;
  $.get("/api/v1/seasons/" + season + "/", handleGetDivisions);
}

function handleGetDivisions(res) {
  const response = JSON.parse(res);
  const activeDivisionByDefault = summary.activeDivision || response.divisions[0].id;

  // Add elements to menu
  for (var index in response.divisions.reverse()) {
    $("#v2-season-selector").prepend(createDivisionSelector(response.divisions[index]));
  }

  // Set first element as active
  setTimeout(() => {
    if (activeDivisionByDefault !== summary.activeDivision) {
      summary.selectDivision(activeDivisionByDefault);
    }
  }, 500);
}

var summary = {
  activeDivision: undefined,
  selectDivision: function(divisionId) {
    summary.activeDivision = divisionId;

    $(".SummaryTables-divisionSelector").removeClass("active");
    $(".SummaryTables-divisionSelector[data-id=" + divisionId + "]").addClass("active");

    $(".SummaryTables-division").removeClass("active");
    $(".SummaryTables-division[data-id=" + divisionId + "]").addClass("active");
  }
};

$(document).ready(startup);
