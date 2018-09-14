window.foosv2 = {};
/**
 * GENERICS
 */

/**
 * Sort an array
 */
function sortByVictoriesAndPlayers(a, b) {
  if (a.maxFollowingVictories < b.maxFollowingVictories) return 1;
  if (a.maxFollowingVictories > b.maxFollowingVictories) return -1;
  if (a.followingVictories < b.followingVictories) return 1;
  if (a.followingVictories > b.followingVictories) return -1;
  if (a.player > b.player) return 1;
  if (a.player < b.player) return -1;
  return 0;
}

/**
 * Initial execution
 */
function v2startup() {
  getDivisions(window.sessionId || default_season_id);
}

/**
 * Ajax call to get divisions
 */
function getDivisions(seasonId) {
  $.get("/api/v1/seasons/" + seasonId + "/", function(res) {
    const response = JSON.parse(res);
    const activeDivisionByDefault = response.divisions[0].id;

    response.divisions.forEach(function(division) {
      division.logo = division.title.replace("Division ", "");
    });
    window.foosv2.season = response;
    window.foosv2.divisions = response.divisions;

    populateTopWinners();

    // Remove prev menu items
    $("#v2-season-selector .tab-division").remove();

    for (var index in response.divisions.reverse()) {
      // Add elements to menu
      $("#v2-season-selector").prepend(createDivisionSelector(response.divisions[index]));
    }

    // Set first element as active
    setTimeout(() => {
      selectDivision(activeDivisionByDefault);
    }, 500);
  });
}

/**
 * Selects a division by default
 * @param {number} divisionId
 */
function selectDivision(divisionId) {
  $(".SummaryTables-divisionSelector").removeClass("active");
  $(".SummaryTables-divisionSelector[data-id=" + divisionId + "]").addClass("active");

  $(".SummaryTables-division").removeClass("active");
  $(".SummaryTables-division[data-id=" + divisionId + "]").addClass("active");
}

/**
 * Append tabs to navbar
 */
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

/**
 * SIDEBAR
 */

/**
 * Open/close recent matches
 */
function toggleSidebar() {
  $(".Recents").toggleClass("active");
}

/**
 * WIDGET
 */

/**
 * Get DOM elements where widget stuff is going to be used
 */
function getWidgetItems() {
  return {
    matches: $(".Widget-content .Widget-match"),
    dots: $(".Widget-pagination .Widget-slideDot")
  };
}

/**
 * Check wich item has an `active` class, and return its index
 * @param {object[]} elements
 * @return {number}
 */
function getIndexOfActiveElement(elements) {
  var active = -1;

  $(elements).each((index, elem) => {
    if (elem.classList.contains("active")) {
      active = index;
    }
  });

  return active;
}

/**
 * Remove `active` class from any widget element, and add it to
 * the specified element by the indexToSelect param
 * @param {object[]} cards
 * @param {number} index
 */
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

/**
 * Navigate to prev item
 */
function showPrevWidgetItem() {
  var cards = getWidgetItems();
  var activeIndex = getIndexOfActiveElement(cards.matches);

  if (activeIndex === 0) {
    selectWidgetItem(cards, cards.matches.length - 1);
  } else {
    selectWidgetItem(cards, activeIndex - 1);
  }
}

/**
 * Navigate to next item
 */
function showNextWidgetItem() {
  var cards = getWidgetItems();
  var activeIndex = getIndexOfActiveElement(cards.matches);

  if (activeIndex === cards.matches.length - 1) {
    selectWidgetItem(cards, 0);
  } else {
    selectWidgetItem(cards, activeIndex + 1);
  }
}

/**
 * DIVISION: PLAYER DETAILS
 */

/**
 * Close player details
 */
function closePlayerDetails() {
  $(".Table--withDetails tr").removeClass("active");
}

/**
 * Open player details
 * @param {number} playerId
 */
function showPlayerDetails(playerId) {
  closePlayerDetails();
  const row = $(".Table tr[data-id=" + playerId + "]");
  row[0].classList.add("active");
}

/**
 * SUMMARY: TOP WINNERS
 */

/**
 * Given a list of divisions, it loops through each one to get
 * people with more following wins
 * @param {object[]} divisions
 * @return {object[]}
 */
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
            followingVictories: 0,
            maxFollowingVictories: 0
          });

          playerIndex = followingPlayerVictories.length - 1;
        }

        if (player.victories === 3) {
          followingPlayerVictories[playerIndex].followingVictories++;
        } else {
          followingPlayerVictories[playerIndex].followingVictories = 0;
        }

        if (
          followingPlayerVictories[playerIndex].followingVictories >
          followingPlayerVictories[playerIndex].maxFollowingVictories
        ) {
          followingPlayerVictories[playerIndex].maxFollowingVictories =
            followingPlayerVictories[playerIndex].followingVictories;
        }
      }
    }
  }
  followingPlayerVictories.sort(sortByVictoriesAndPlayers);

  return followingPlayerVictories.slice(0, 3);
}

/**
 * Merge all matches of all divisions in one single place
 * @return {Promise<object[]>}
 */
function getAllDivisionsMatches() {
  const promises = [];

  for (var x in window.foosv2.divisions) {
    const division = window.foosv2.divisions[x];
    promises.push(
      new Promise(function(resolve) {
        $.get("/api/v1/divisions/" + division.id + "/matches/played/?", function(response) {
          var matches = JSON.parse(response);

          var storedDivision = window.foosv2.divisions.find(d => d.id === division.id);
          if (storedDivision) {
            storedDivision.matches = matches;
          }

          resolve({
            division: division.id,
            matches
          });
        });
      })
    );
  }

  return Promise.all(promises);
}

/**
 * Get the people with best winning streaks
 * @returns {Promise<object[]>}
 */
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

/**
 * Fill the `Best winning streaks` widget
 */
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

      foosv2.topWinners = ranking;

      var list = document.createElement("ul");

      ranking.forEach(function(winner) {
        var element = document.createElement("li");
        element.className = "Ranking-element";

        var logo = document.createElement("span");
        var division = window.foosv2.divisions.find(d => d.id === winner.division);
        logo.className = "Ranking-logo DivisionLogo";
        logo.innerHTML = division.logo;
        element.appendChild(logo);

        var username = document.createElement("span");
        username.className = "Ranking-username";
        username.innerText = winner.player.name;
        element.appendChild(username);

        var counter = document.createElement("span");
        counter.className = "Ranking-counter";
        counter.innerText = winner.maxFollowingVictories + " invictus";
        element.appendChild(counter);

        list.appendChild(element);
      });

      $(".Widget .Ranking ul").remove();
      $(".Widget .Ranking").append(list);
    });
  });
}

$(document).ready(v2startup);
