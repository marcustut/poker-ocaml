open Poker

type op = Add | Sub | Mul | Div

let apply_op a b = function
  | Add -> a +. b
  | Sub -> a -. b
  | Mul -> a *. b
  | Div -> a /. b

let rec solve (values : float list) (target : float) : bool =
  match values with
  | [] -> false
  | [ x ] ->
      abs_float (x -. target)
      < 0.0001 (* Account for floating point precision *)
  | _ ->
      let rec try_combinations = function
        | [] -> false
        | (i, j, op) :: rest ->
            let a = List.nth values i in
            let b = List.nth values j in
            let new_value = apply_op a b op in
            let new_values =
              List.mapi
                (fun idx v -> if idx = i || idx = j then None else Some v)
                values
              |> List.filter_map Fun.id
              |> fun lst -> new_value :: lst
            in
            solve new_values target || try_combinations rest
      in

      (* Generate all possible (i,j,op) combinations *)
      let combinations =
        let n = List.length values in
        let rec gen_ijs i acc =
          if i >= n then acc
          else
            let rec gen_js j acc =
              if j >= n then acc
              else if j = i then gen_js (j + 1) acc
              else
                let ops = [ Add; Sub; Mul; Div ] in
                let new_acc =
                  List.fold_left (fun a op -> (i, j, op) :: a) acc ops
                in
                gen_js (j + 1) new_acc
            in
            gen_js 0 (gen_ijs (i + 1) acc)
        in
        gen_ijs 0 []
      in
      try_combinations combinations

let can_reach_target (cards : Poker.Card.card list) (target : int) : bool =
  let values =
    List.map (fun (r, _) -> float_of_int (Poker.Card.rank_value r)) cards
  in
  solve values (float_of_int target)

let () =
  Random.self_init ();

  (* Make a deck *)
  let deck = Poker.Deck.shuffle Poker.Deck.make_deck in

  (* Draw 5 cards *)
  let hand, remaining_deck = Poker.Deck.draw_cards deck 5 [] in

  (* Print results *)
  List.iter (fun c -> Printf.printf "%s " (Card.string_of_card c)) hand;
  Printf.printf "\nRemaining cards: %d\n" (List.length remaining_deck);

  (* Check if cards can make 24 *)
  let target = 24 in
  let result = can_reach_target hand target in
  Printf.printf "Can make %d: %b\n" target result
