% Load libraries and tools
:- use_module(library(pce)).
:- use_module("./graphics/board_graphics", [draw_board/2, refresh/1]).
:- use_module("./graphics/side_board_graphics", [draw_side_board/3]).
:- use_module("./events/board_events", [select_event/4]).
:- use_module("./events/side_board_events", [select_side_board/4]).
:- use_module("../game/gui_api").


menu_bar_setup(MainWin, Board, BlackCells, WhiteCells) :-
    send(new(D, dialog), above, Board),
    send(D, append, new(MB, menu_bar)),
    send(D, background, colour(orange)),

    send(MB, append, new(File, popup(file))),
    send_list(File, append,
                [new(Opt, popup(new_Game)),
                 menu_item(exit, message(MainWin, destroy))]),
    send_list(Opt, append,
                [menu_item(against_AI_white, message(
                        @prolog, start_game, aiw, Board, BlackCells, WhiteCells)),
                menu_item(against_AI_black, message(
                        @prolog, start_game, aib, Board, BlackCells, WhiteCells)),
                 menu_item(aI_vs_AI, message(
                        @prolog, start_game, ai_vs_ai_visual, Board, BlackCells, WhiteCells)),
                 menu_item(local_game, message(
                        @prolog, start_game, human, Board, BlackCells, WhiteCells)),
                 menu_item(online)]).

file_dialog_setup(Canvas, BlackCells, WhiteCells) :-
    send(new(T, dialog), right, Canvas),
    send(T, ver_shrink, 100),
    send(T, ver_stretch, 100),
    send(T, background, colour(orange)),

    send(T, append, new(BlackCells, window)),
    send(BlackCells, width, 400),
    send(BlackCells, height, 200),
    send(BlackCells, recogniser, 
            click_gesture(left, '', single,
                            message(@prolog, select_side_board, Canvas, BlackCells, @event?position, black))),

    send(T, append, new(WhiteCells, window)),
    send(WhiteCells, width, 400),
    send(WhiteCells, height, 200),
    send(WhiteCells, recogniser,
            click_gesture(left, '', single,
                            message(@prolog, select_side_board, Canvas, WhiteCells, @event?position, white))),

    send(button(refresh, message(@prolog, refresh, Canvas)), below, WhiteCells).


start_game(Opponent, Canvas, BlackCells, WhiteCells) :-
    % Init Global Vars
    nb_setval(scale, 0.75),
    nb_setval(move_cell, undefined),
    nb_setval(position_cell, undefined),
    nb_setval(pillbug_effect, undefined),

    get(Canvas, size, size(W, H)),
    CH is H/2, CW is W/2,
    nb_setval(center, point(CW, CH)),

    gui_start_game(+Opponent, -Board, -[Player1, Player2]),
    nb_setval(white_player, Player1),
    nb_setval(black_player, Player2),
    write_ln(Board),write_ln(Player1),write_ln(Player2),
    nb_setval(board, Board),

    draw_side_board(Player1, white, WhiteCells),
    draw_side_board(Player2, black, BlackCells),
    draw_board(Board, Canvas),

    (
        (
            Opponent = aiw, 
            nb_setval(opponent, ai),
            nb_setval(player_turn, black),
            gui_ai_turn(),
            write_ln('ai played'),
            gui_get_visual_game_state(NewBoard, [BlackPlayer, WhitePlayer]),
            nb_setval(board, NewBoard),
            nb_setval(black_player, BlackPlayer),
            nb_setval(white_player, WhitePlayer),
            draw_side_board(WhitePlayer, white, WhiteCells),
            draw_side_board(BlackPlayer, black, BlackCells),
            draw_board(NewBoard, Canvas)
        );
        (
            Opponent = aib, 
            nb_setval(opponent, ai),
            nb_setval(player_turn, white)
        );
        nb_setval(opponent, Opponent),
        nb_setval(player_turn, white)
    ).

gui_init :-
    % Setting up Game Panel
    new(MainWin, frame("CoolCows Hive Game")),
    send(MainWin, append, new(Board, picture("Board"))),

    % Game Side Configs 
    file_dialog_setup(Board, BlackPlayer, WhitePlayer),
    menu_bar_setup(MainWin, Board, BlackPlayer, WhitePlayer),

    % Main Board Configs
    % send(Board, width, 1280),
    % send(Board, height, 720),
    send(Board, recogniser,
            click_gesture(left, '', single,
                          message(@prolog, select_event, Board, @event?position, WhitePlayer, BlackPlayer))),
    send(MainWin, open).

?- gui_init.
