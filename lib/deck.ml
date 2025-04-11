module C = Card

type deck = C.card list (* deck is a list of cards *)

let make_deck : deck =
  let suits = [ C.Diamond; C.Club; C.Heart; C.Spade ] in
  let ranks =
    [
      C.Two;
      C.Three;
      C.Four;
      C.Five;
      C.Six;
      C.Seven;
      C.Eight;
      C.Nine;
      C.Ten;
      C.Jack;
      C.Queen;
      C.King;
      C.Ace;
    ]
  in
  List.concat (List.map (fun r -> List.map (fun s -> (r, s)) suits) ranks)

let shuffle (d : deck) : deck =
  let arr = Array.of_list d in
  Array.sort (fun _ _ -> Random.int 3 - 1) arr;
  (* random shuffle by generating -1, 0, 1 *)
  Array.to_list arr

let draw_card (d : deck) : C.card option * deck =
  match d with [] -> (None, []) | card :: deck -> (Some card, deck)

let rec draw_cards d n acc : deck * deck =
  if n = 0 then (acc, d)
  else
    match draw_card d with
    | Some card, new_deck -> draw_cards new_deck (n - 1) (card :: acc)
    | None, _ -> (acc, d)
