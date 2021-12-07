:- module(node, [
    get_times_explored/2,
    get_times_white_won/2,
    get_times_black_won/2,
    add_node/2,
    find_node/2
]).

:- use_module(library(persistency)).

% define persistent game node
:- persistent
    node(
        address:string,          % hash(parent_address + str(game_state))
        parent_address:string,   
        game_state:list,         % [board, players, turns, last_played]
        node_type: atom,         % non_terminal | white_won | black_won | draw
        node_visited: bool,      % true | false
        times_explored: integer,
        times_white_won: integer,
        times_black_won: integer
    ).

% load stored tree
load_tree_db :-
    db_attach('./tree_db.pl', []).

% Properties:
%
get_times_explored(
    node(_, _, _, _, _, Explored, _, _),
    Explored
).

get_times_white_won(
    node(_, _, _, _, _, _, WhiteWon, _),
    WhiteWon
).

get_times_black_won(
    node(_, _, _, _, _, _, _, BlackWon),
    BlackWon
).

% Methods:
%
% From parent address and Game State calculate node properties
% and insert in tree_db.pl
add_node(ParentAddress, GameState, NodeType) :-
    keccak256(ParentAddress, GameState, NodeAddres),
    assert_node(
        NodeAddress, 
        ParentAddress, 
        GameState, 
        NodeType, 
        false, 
        0, 
        0,
        0
    ).

% returns a node by it's address
find_node(
    NodeAddress,
    node(
        NodeAddress, 
        ParentAddress, 
        GameState, 
        Explored, 
        WhiteWon, 
        BlackWon
    )
).

% For backpropagation:
% 1. Finds node at NodeAddress
% 2. Updates properties
% 3. Returns ParentAddress
update_node(NodeAddress, NewExplored, NewWhiteWon, NewBlackWon, ParentAddress) :-
    find_node(NodeAddress, Node),
    Node = node(_, ParentAddress, GameState, NodeType, Explored, WhiteWon, BlackWon),
    retract_node(Node),
    assert_node(
        NodeAddres,
        ParentAddress,
        GameState,
        NodeType,
        NewExplored,
        NewWhiteWon,
        NewBlackWon
    ).

keccak256(ParentAdrress, GameState, Hash) :-
    term_string(GameState, StrGameState),
    string_concat(ParentAdrress, StrGameState, Seed),
    crypto_data_hash(Seed, Hash, [algorithm(sha3)]).