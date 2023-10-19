(** The signature of the scrabble board. *)
module type BoardType = sig
  type letter_bank
  type tile
  type board_type

  val init_board : int -> int -> board_type
  val show_board : unit

  (* val check_word_fit : string -> bool *)
  (** Check if given String [word], fits on the current [board] *)

  val sample : int -> letter_bank -> tile list
  val add_word : string -> (char * int) * (char * int) -> (board_type)-> bool
end

(** Scrabble board *)
module ScrabbleBoard : BoardType = struct
  (* letter_bank is a multiset of the Scrabble letters *)
  type letter_bank = char list

  (* Each tile in a board *)
  type tile =
    | Empty
    | Letter of char

  type board_type = tile array array

  let init_board (w : int) (h : int) : board_type = Array.make_matrix w h Empty
  (* Creates a 2D array which represents the board. *)

  let show_board = ()

  (* Given a list and an element, returns that list without the first appreance
     of that element. Helper function for play_tiles *)
  let rec list_without_elem (lst : 'a list) (elem : 'a) : 'a list =
    match lst with
    | [] -> lst
    | h :: t -> if h = elem then t else h :: list_without_elem t elem

  (* Given an integer, and the letter bank, returns *)
  let rec sample_helper (count : int) (bank : letter_bank) : tile list =
    if count == 0 then []
    else
      let n = Random.int (List.length bank) in
      let elem = List.nth bank n in
      Letter elem :: sample_helper (count - 1) (list_without_elem bank elem)

  let sample (n : int) (bank : letter_bank) : tile list =
    match bank with
    | [] -> []
    | h :: t -> sample_helper n bank

  let check_word_fit (word : string) = failwith "unimplemented"

  (** Given list of chars representing the word, and a tuple of the starting and
      ending location of word on the board. *)
      type direction = 
      | None
      | Horizontal
      | Vertical 
    
     
      let position_of_char (letter : char) : int= 
        match letter with
        |'A' -> 1
        |'B' -> 2
        |'C' -> 3
        |'D' -> 4
        |'E' -> 5
        |'F' -> 6
        |'G' -> 7
        |_ -> failwith "invalid coordinate"


    
      (*helper function to determine if a given word is in a valid direction (either 
         vertical or horizontal) if so, which direction it's in*)
      let rec valid_dir (starter : char * int) (ending : char * int) : bool * direction =
        if fst starter = fst ending then (true, Vertical)
        else if snd starter = snd ending then (true, Horizontal)
        else (false, None)
      (** Given list of chars representing the word, and a tuple of the starting and
          ending location of word on the board. *)
      let add_word (word : string) (location : (char * int) * (char * int)) (board : board_type) : bool =
        let temp = (valid_dir (fst location) (snd location)) in
        if fst (temp) then let direction = snd (temp) in 
        (if direction = Horizontal then get board else true)
        else failwith "word not in valid direction"
end
