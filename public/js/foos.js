function startup() {
	$(".season-selector").click(select_season);
	load_season_section();
}

function select_season() {
	season_id = $(this).data('season-id');
	current_season_id = season_id;
	current_season_title = $(this).text();
	$("#season-selected").text(current_season_title);
	load_season_section();
}

function load_season_section() {
	$("#content").load('ajax/season/' + current_season_id, on_load_season_section);
	return false;
}

function on_load_season_section() {
	$(".tab1").click(activate_tab1);
	load_summary_subsection();
}

function activate_tab1() {
	division_id = $(this).data('id');

	$(".tab1-element").removeClass("active");
	$("#tab1-division-" + division_id).addClass("active");

	if (division_id == 0) {
		load_summary_subsection();
	} else {
		load_division_subsection(division_id);
	}
}


/* Summary subsection */

function load_summary_subsection() {
	$("#tab1-content").load('ajax/summary/' + current_season_id, on_load_summary_subsection);
}

function on_load_summary_subsection() {
    activate_match_popovers();
}

function activate_match_popovers() {
    $('.match-result-popover').popover({
      container: 'body',
      trigger: 'hover',
      placement: 'auto',
      html: true,
      animation: false
    })
}


/* Division subsection */

function load_division_subsection(division_id) {
	$("#tab1-content").load('ajax/division/' + division_id, on_load_division_subsection);
}

function on_load_division_subsection() {
    $(".player-detail").click(activate_player_detail);
    $("#simulator-modal").on('show.bs.modal', function (event) {
        button = $(event.relatedTarget);
        match_id = button.data('match-id');
        load_simulator_modal(match_id);
    });
    activate_match_popovers();
}

function activate_player_detail() {
    player_id = $(this).data('player-id');
    element = "#classification-detail-" + player_id;
	$(".classification-detail").hide();
	$("#classification-detail-" + player_id).show();
}


/* Simulator modal */

function load_simulator_modal(match_id) {
	$("#simulator-content").load('ajax/simulator/' + match_id, on_load_simulator_modal);
}

function on_load_simulator_modal() {
	$(".result-selector").click(select_result);
    $(".result-direct").click(select_result_direct);
}

function select_result() {
	submatch = $(this).data('submatch');
    result_a = $(this).data('result-a');
    result_b = $(this).data('result-b');
    update_selected_result(submatch, result_a, result_b);
    $("#dropdown-" + submatch).dropdown("toggle");
    run_simulation();
    return false;
}

function select_result_direct() {
	player = $(this).data("player");
	result_direct = $(this).data("result-direct");
	// FIXME: This if/else sequence could obviously be made
	// cleaner, but for the moment it works OK :)
	if (player == 0 && result_direct == 3) {
		update_selected_result(1, 5, 2);
		update_selected_result(2, 5, 2);
		update_selected_result(3, 5, 2);
	} else if (player == 0 && result_direct == 0) {
		update_selected_result(1, 2, 5);
		update_selected_result(2, 2, 5);
		update_selected_result(3, 2, 5);
	} else if (player == 1 && result_direct == 3) {
		update_selected_result(1, 5, 2);
		update_selected_result(2, 2, 5);
		update_selected_result(3, 2, 5);
	} else if (player == 1 && result_direct == 0) {
		update_selected_result(1, 2, 5);
		update_selected_result(2, 5, 2);
		update_selected_result(3, 5, 2);
	} else if (player == 2 && result_direct == 3) {
		update_selected_result(1, 2, 5);
		update_selected_result(2, 5, 2);
		update_selected_result(3, 2, 5);
	} else if (player == 2 && result_direct == 0) {
		update_selected_result(1, 5, 2);
		update_selected_result(2, 2, 5);
		update_selected_result(3, 5, 2);
	} else if (player == 3 && result_direct == 3) {
		update_selected_result(1, 2, 5);
		update_selected_result(2, 2, 5);
		update_selected_result(3, 5, 2);
	} else if (player == 3 && result_direct == 0) {
		update_selected_result(1, 5, 2);
		update_selected_result(2, 5, 2);
		update_selected_result(3, 2, 5);
	}
	run_simulation();
	return false;
}

function update_selected_result(submatch, result_a, result_b) {
	result_txt = result_a + '-' + result_b;
	$("#result-selected-" + submatch).text(result_txt);
	$("#result-selected-" + submatch).data('valid', 1);
	$("#result-selected-" + submatch).data('result-a', result_a);
	$("#result-selected-" + submatch).data('result-b', result_b);
}

function run_simulation() {
    if ($("#result-selected-1").data("valid") != 1 &&
        $("#result-selected-2").data("valid") != 1 &&
        $("#result-selected-3").data("valid") != 1) {
		return false;
	}
    load_simulation();
	fill_victories();
}

function load_simulation() {
    match_id = $("#simulation-data").data('match-id');
    post_data = JSON.stringify({
        results: [
          [$("#result-selected-1").data('result-a'), $("#result-selected-1").data('result-b')],
          [$("#result-selected-2").data('result-a'), $("#result-selected-2").data('result-b')],
          [$("#result-selected-3").data('result-a'), $("#result-selected-3").data('result-b')]
        ]
    });
	$.post('ajax/simulation/' + match_id, post_data, on_load_simulation);
}

function fill_victories() {
	victories = [0, 0, 0, 0]
	if ($("#result-selected-1").data('result-a') == 5) {
		victories[0] += 1;
		victories[1] += 1;
	} else {
		victories[2] += 1;
		victories[3] += 1;
	}
	if ($("#result-selected-2").data('result-a') == 5) {
		victories[0] += 1;
		victories[2] += 1;
	} else {
		victories[1] += 1;
		victories[3] += 1;
	}
	if ($("#result-selected-3").data('result-a') == 5) {
		victories[0] += 1;
		victories[3] += 1;
	} else {
		victories[1] += 1;
		victories[2] += 1;
	}
	$("#player-victories-0").html(victories[0]);
	$("#player-victories-1").html(victories[1]);
	$("#player-victories-2").html(victories[2]);
	$("#player-victories-3").html(victories[3]);
}

function on_load_simulation(data, status) {
    $("#simulation-classification-new").html(data);
}

$(document).ready(startup)
