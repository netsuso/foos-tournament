function log() {
  console.log("[V2]", ...arguments);
}

function sortByVictoriesAndPlayers(a, b) {
  if (a.followingVictories < b.followingVictories) return 1;
  if (a.followingVictories > b.followingVictories) return -1;
  if (a.player > b.player) return 1;
  if (a.player < b.player) return -1;
  return 0;
}

function v2startup() {
  getDivisions(window.sessionId || default_season_id);
}

function getDivisions(seasonId) {
  $.get("/api/v1/seasons/" + seasonId + "/", handleGetDivisions);
}

function handleGetDivisions(res) {
  const response = JSON.parse(res);
  const activeDivisionByDefault = response.divisions[0].id;
  summary.divisions = response.divisions;

  populateTopWinners();

  // Add elements to menu
  $("#v2-season-selector .tab-division").remove();

  for (var index in response.divisions.reverse()) {
    $("#v2-season-selector").prepend(createDivisionSelector(response.divisions[index]));
  }

  // Set first element as active
  setTimeout(() => {
    summary.selectDivision(activeDivisionByDefault);
  }, 500);
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
  var activeIndex = getIndexOfActiveElement(cards.matches);

  if (activeIndex === 0) {
    selectWidgetItem(cards, cards.matches.length - 1);
  } else {
    selectWidgetItem(cards, activeIndex - 1);
  }
}

function showNextWidgetItem() {
  var cards = getWidgetItems();
  var activeIndex = getIndexOfActiveElement(cards.matches);

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

function calculateWinners(divisions) {
  var followingPlayerVictories = [];

  for (var x in divisions) {
    var journeys = divisions[x];

    for (var y in journeys) {
      var journey = journeys[y];

      for (var z in journey) {
        var player = journey[z];
        var playerIndex = followingPlayerVictories.findIndex(p => p.player === player.player);

        if (playerIndex < 0) {
          followingPlayerVictories.push({
            player: Number(player.player),
            division: player.division,
            followingVictories: 0
          });

          playerIndex = followingPlayerVictories.length - 1;
        }

        if (player.victories === 3) {
          followingPlayerVictories[playerIndex].followingVictories++;
        } else {
          followingPlayerVictories[playerIndex].followingVictories = 0;
        }
      }
    }
  }
  followingPlayerVictories.sort(sortByVictoriesAndPlayers);

  return followingPlayerVictories.slice(0, 3);
}

function getAllDivisionsMatches() {
  const promises = [];

  for (var x in summary.divisions) {
    const division = summary.divisions[x];
    promises.push(
      new Promise(function(resolve) {
        $.get("/api/v1/divisions/" + division.id + "/matches/played/?", function(response) {
          resolve({
            division: division.id,
            matches: JSON.parse(response)
          });
        });
      })
    );
  }

  return Promise.all(promises);
}

function getTopWinners() {
  return new Promise(function(resolve) {
    getAllDivisionsMatches().then(function(divisions) {
      var matches = [];
      var topWinners = [];

      // Mix all matches in the same array, without distinguish divisions
      divisions.forEach(function(division) {
        matches.push(
          division.matches.reverse().map(function(match) {
            return match.players.map(function(player, index) {
              return {
                division: division.division,
                player: player,
                victories: match.victories[index]
              };
            });
          })
        );
      });

      // Calculate the top 3
      resolve(calculateWinners(matches));
    });
  });
}

function populateTopWinners() {
  var ranking;
  var promises = [];

  getTopWinners().then(function(topWinners) {
    ranking = JSON.parse(JSON.stringify(topWinners));

    topWinners.forEach(function(winner) {
      promises.push(
        new Promise(function(resolve) {
          $.get("/api/v1/players/" + winner.player + "/").then(function(response) {
            const data = JSON.parse(response);

            resolve({
              id: winner.player,
              name: data.name,
              nick: data.nick
            });
          });
        })
      );
    });

    Promise.all(promises).then(players => {
      players.forEach(function(player) {
        var rankingIndex = ranking.findIndex(function(p) {
          return p.player === player.id;
        });

        ranking[rankingIndex].player = player;
      });

      var list = document.createElement("ul");

      ranking.forEach(function(position) {
        var element = document.createElement("li");
        element.className = "Ranking-element";

        var logo = document.createElement("img");
        logo.className = "Ranking-logo";
        logo.src = "";
        logo.title = "Division logo";
        logo.alt = "Division logo";
        element.appendChild(logo);

        var username = document.createElement("span");
        username.className = "Ranking-username";
        username.innerText = position.player.name;
        element.appendChild(username);

        var counter = document.createElement("span");
        counter.className = "Ranking-counter";
        counter.innerText = position.followingVictories + " invictus";
        element.appendChild(counter);

        list.appendChild(element);
      });

      $(".Widget .Ranking ul").remove();
      $(".Widget .Ranking").append(list);
    });
  });
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

$(document).ready(v2startup);
