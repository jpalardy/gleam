import gleam/list
import gleam/string
import gleam/map.{type Map}

type Wall {
  Corner
  Vertical
  Horizontal
}

pub fn rectangles(input: String) -> Int {
  input
  |> parse_input
  |> find_rectangles
}

fn parse_input(input: String) -> Map(#(Int, Int), Wall) {
  input
  |> string.split("\n")
  |> list.index_map(fn(row, line) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(col, char) {
      case char {
        "+" -> [#(#(row, col), Corner)]
        "|" -> [#(#(row, col), Vertical)]
        "-" -> [#(#(row, col), Horizontal)]
        _ -> []
      }
    })
  })
  |> list.flatten
  |> list.flatten
  |> map.from_list
}

fn find_rectangles(map: Map(#(Int, Int), Wall)) -> Int {
  let corners = map.filter(map, fn(_pos, wall) { wall == Corner })

  map.fold(
    from: 0,
    over: corners,
    with: fn(rectangles, position1, _corner) {
      let #(x1, y1) = position1

      map.fold(
        from: rectangles,
        over: corners,
        with: fn(rectangles, position2, _corner2) {
          let #(x2, y2) = position2
          let position3 = #(x1, y2)
          let position4 = #(x2, y1)
          let is_rectangle =
            x1 < x2 && y1 < y2 && map.has_key(corners, position3) && map.has_key(
              corners,
              position4,
            ) && has_vertical_walls_between(map, position1, position4) && has_vertical_walls_between(
              map,
              position3,
              position2,
            ) && has_horizontal_walls_between(map, position1, position3) && has_horizontal_walls_between(
              map,
              position4,
              position2,
            )

          case is_rectangle {
            True -> rectangles + 1
            False -> rectangles
          }
        },
      )
    },
  )
}

fn has_vertical_walls_between(
  map: Map(#(Int, Int), Wall),
  position1: #(Int, Int),
  position2: #(Int, Int),
) -> Bool {
  let #(x1, y1) = position1
  let #(x2, y2) = position2
  let assert True = y1 == y2
  let assert True = x1 < x2

  list.range(x1, x2)
  |> list.map(fn(x) { #(x, y1) })
  |> list.all(fn(pos) {
    case map.get(map, pos) {
      Ok(Corner) -> True
      Ok(Vertical) -> True
      _ -> False
    }
  })
}

fn has_horizontal_walls_between(
  map: Map(#(Int, Int), Wall),
  position1: #(Int, Int),
  position2: #(Int, Int),
) -> Bool {
  let #(x1, y1) = position1
  let #(x2, y2) = position2
  let assert True = x1 == x2
  let assert True = y1 < y2

  list.range(y1, y2)
  |> list.map(fn(y) { #(x1, y) })
  |> list.all(fn(pos) {
    case map.get(map, pos) {
      Ok(Corner) -> True
      Ok(Horizontal) -> True
      _ -> False
    }
  })
}
