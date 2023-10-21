open Game
open Board
open Player

(* Given a string [input], returns a char list representation of that string. *)
let rec char_list_of_string (input : string) : char list =
  match input with
  | "" -> []
  | str ->
      str.[0] :: char_list_of_string (String.sub str 1 (String.length str - 1))

(* Given a list and an element, returns that list without the first appreance of
   that element. Helper function for update_bank. REMOVE DUPLICATE IN board.ml
   eventually. *)
let rec list_without_elem (lst : 'a list) (elem : 'a) : 'a list =
  match lst with
  | [] -> lst
  | h :: t -> if h = elem then t else h :: list_without_elem t elem

(* Returns a char list represnting the official letter bank of Scrabble
   (multiset of English alphabet). *)
let init_letter_bank : char list =
  "run/scrabble_letter_bank.txt" |> In_channel.open_text |> In_channel.input_all
  |> char_list_of_string

(** Given a letter [bank] and a list of sampled letters [input], returns a new
    letter bank without the sampled input. *)
let rec update_bank (bank : char list) (input : char list) : char list =
  match input with
  | [] -> []
  | h :: t ->
      let x = List.find_opt (fun x -> if x = h then true else false) bank in
      if x = None then h :: update_bank bank t
      else update_bank (list_without_elem bank (Option.get x)) t

(** Given string of location (user input), checks whether location was given in
    the correct format. TODO : test this !!! *)
let valid_loc_string (loc : string) : bool = true
(* let r = Str.regexp {|([A-Za-z])?([0-9])? - ([A-Za-z])?([0-9])?|} in if
   Str.string_match r loc 0 then true else false *)

(** Given string of location (user input), returns a tuple of tuple
    representation of the location. *)
let gen_loc (loc : string) : (char * int) * (char * int) =
  let start = String.sub loc 0 2 in
  let end_ = String.sub loc 5 2 in
  ((start.[0], int_of_char start.[1]), (end_.[0], int_of_char end_.[1]))

(** Prompts the user to enter a location until it confirms that the format is
    valid *)
let rec prompt_location () =
  print_endline
    "Please specify where you want to place the word (follow the format A3 - \
     A7):";
  print_string ">>> ";
  let loc_string = read_line () in
  if valid_loc_string loc_string then gen_loc loc_string
  else (
    print_endline
      "That is not a valid format for the location of the word. Please try \
       again.";
    prompt_location ())

(** Prompts the user to enter a word and location for the word. Returns tuple of
    word and lcoation. *)
let prompt_word () =
  print_endline "Please enter a word or hit enter to end the game.";
  print_string ">>> ";
  let word = read_line () in
  match word with
  | "" -> ("", (('a', -1), ('a', -1)))
  | w ->
      let loc = prompt_location () in
      (w, loc)

(* Given information about the player and the next word they want to add, makes
   the play and asks for the next word recursively until the user quits. *)
let rec make_play (next_word : string) (loc : (char * int) * (char * int))
    (bank : char list) (board : ScrabbleBoard.board_type)
    (player : SinglePlayer.t) =
  match next_word with
  | "" ->
      print_endline
        ("\nThanks for playing! Your final score was "
        ^ string_of_int (SinglePlayer.score player))
  | word ->
      if
        Player.check_word
          (SinglePlayer.current_tiles player)
          next_word (fst loc) (snd loc)
        && ScrabbleBoard.check_word_fit board next_word loc
      then (
        ScrabbleBoard.add_word next_word loc board 0;
        ScrabbleBoard.show_board;
        let sampled = ScrabbleBoard.sample (String.length next_word) bank in
        let new_player = SinglePlayer.update_tiles player bank sampled in
        let new_bank = update_bank bank sampled in
        print_string "\nHere are your updated tiles: ";
        print_endline (SinglePlayer.print_tiles player);
        let word, loc = prompt_word () in
        make_play word loc new_bank board new_player)
      else (
        print_endline "That isn't a valid word. Please try again.";
        let word, loc = prompt_word () in
        make_play word loc bank board player)

(* Only single player functionality at the moment. *)
(* TODO make it so that the scrabble board can be any dimensions? *)
let () =
  print_endline "\nWelcome to (O)Camel ScrObble!\n";
  print_endline
    "RULES:\n\
    \ - All words are case sensitive (only use uppercase characters when \
     creating words)\n\
    \ - Familiar rules of scrabble apply\n";
  print_endline "Please enter your player name";
  print_string ">>> ";
  let player_name = read_line () in
  print_endline ("\nHi " ^ player_name ^ "! Get ready to play :)");
  let board = ScrabbleBoard.init_board 7 7 in
  let letter_bank = init_letter_bank in
  let player =
    SinglePlayer.create_player (ScrabbleBoard.sample 7 letter_bank) 0
  in
  print_string "Here is your first set of tiles: ";
  print_endline (SinglePlayer.print_tiles player);
  let word, loc = prompt_word () in
  make_play word loc letter_bank board player
