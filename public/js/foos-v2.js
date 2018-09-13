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
  anchor.href = "/#15-" + division.id;
  anchor.dataset = {
    "division-id": division.id
  };
  anchor.innerHTML = "<span>" + division.title + "</span>";

  element.appendChild(anchor);
  element.onclick = function(event) {
    // Load division data
    division_id = division.id;
    load_division_subsection(division.id);

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

function toggleSidebar() {
  $(".Recents").toggleClass("active");
}

function getWidgetItems() {
  return {
    matches: $(".Widget-content .Widget-match"),
    dots: $(".Widget-pagination .Widget-slideDot")
  };
}

function getIndexOfActiveElement(elements) {
  var active = -1;

  $(elements).each((index, elem) => {
    if (elem.classList.contains("active")) {
      active = index;
    }
  });

  return active;
}

function selectWidgetItem(cards, indexToSelect) {
  if (!cards) {
    cards = getWidgetItems();
  }

  // Match cards
  $(cards.matches).each((index, item) => {
    item.classList.remove("active");

    if (index === indexToSelect) {
      item.classList.add("active");
    }
  });

  // Pagination dots
  $(cards.dots).each((index, item) => {
    item.classList.remove("active");

    if (index === indexToSelect) {
      item.classList.add("active");
    }
  });
}

function showPrevWidgetItem() {
  var cards = getWidgetItems();
  console.log("Number of items", cards.matches.length);

  var activeIndex = getIndexOfActiveElement(cards.matches);
  console.log("Active element", activeIndex);

  if (activeIndex === 0) {
    selectWidgetItem(cards, cards.matches.length - 1);
  } else {
    selectWidgetItem(cards, activeIndex - 1);
  }
}

function showNextWidgetItem() {
  var cards = getWidgetItems();
  console.log("Number of items", cards.matches.length);

  var activeIndex = getIndexOfActiveElement(cards.matches);
  console.log("Active element", activeIndex);

  if (activeIndex === cards.matches.length - 1) {
    selectWidgetItem(cards, 0);
  } else {
    selectWidgetItem(cards, activeIndex + 1);
  }
}

function closePlayerDetails() {
  $(".Table--withDetails tr").removeClass("active");
}

function showPlayerDetails(playerId) {
  closePlayerDetails();
  const row = $(".Table tr[data-id=" + playerId + "]");
  row[0].classList.add("active");
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
