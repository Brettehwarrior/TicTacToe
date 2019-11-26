/* TicTacToe by Trent Baker of (c) 26 November 2019
 *
 * That's right, it's the classic Tic Tac Toe game recreated in Processing.
 * This was made for the NBVLC Computer Science class 
 * I went a little off-script for this one but I think it ended up turning out very nice and it makes more sense to me
 */

/// Global Variables
Board board;
int scale;
int dim;
int mouseGridX = 0, mouseGridY = 0;
ArrayList<Board> boards; // used ArrayList instead of Stack because Processing tends to suggest ArrayList instead and doesn't require an import

/// Initialize
void setup() {
  size(400, 600);
  dim = 3;
  scale = width/dim;

  board = new Board();
  boards = new ArrayList<Board>();
  boards.add(board);
  updateGridPos();
}

/// Loop
void draw() {
  // BG
  background(71, 119, 230);
  // Board stuff
  board.updateTiles();
  board.showTiles();
  updateGridPos();
  // Text
  textAlign(CENTER, CENTER);
  textSize(18);
  fill(0);
  if (board.getWinner() == "") {
    text("It is "+board.getCurrentPlayer()+"'s move", width/2, 4*height/5);
  } else {
    text("Winner: "+board.getWinner(), width/2, 4*height/5);
  }

  //println("ArrayList size: "+boards.size());
}

/// Board class
class Board {
  Tile[][] tiles;
  String currentPlayer;
  String winner;

  // Constructor
  Board() {
    // Init variables
    tiles = new Tile[dim][dim];
    currentPlayer = "X";
    winner = "";

    // Create Tiles
    for (int i = 0; i < dim; i++) {
      for (int j = 0; j < dim; j++) {
        tiles[i][j] = new Tile(i, j);
      }
    }
  }

  // Create copy
  Board copyBoard() {
    Board b = new Board();
    b.tiles = new Tile[dim][dim];
    for (int i = 0; i < dim; i++) {
      for (int j = 0; j < dim; j++) {
        b.tiles[i][j] = tiles[i][j].copyTile();
      }
    }
    b.setCurrentPlayer(currentPlayer);
    b.setWinner(winner);
    return b;
  }

  // Tile logic updates
  void updateTiles() {
    // Update hovered tile's color
    Tile hovered = board.tiles[mouseGridX][mouseGridY];
    for (int i = 0; i < dim; i++) {
      for (Tile t : tiles[i]) {
        if (hovered == t) {
          if (hovered.txt.equals("") && winner == "") {
            t.isActive = 1;
          }
        } else {
          t.isActive =  0;
        }
      }
    }
  }

  // Render all tiles
  void showTiles() {
    // Loop through all tiles and render them
    for (int i = 0; i < dim; i++) {
      for (Tile t : tiles[i]) {
        t.show(t.col[t.isActive]);
      }
    }
  }

  // Getters
  String getCurrentPlayer() {
    return currentPlayer;
  }
  String getWinner() {
    return winner;
  }
  // Setters
  void setCurrentPlayer(String p) {
    currentPlayer = p;
  }
  void setWinner(String w) {
    winner = w;
  }
}

/// Tile class
class Tile {
  // Variables
  private int x, y;
  color[] col;
  int isActive;
  String txt;

  // Constructor
  Tile(int xIn, int yIn) {
    // Position
    x = xIn;
    y = yIn;

    // Displayed symbol
    txt = "";

    // Init colors
    isActive = 0;
    col = new color[2];
    col[0] = color(172, 187, 227); // Inactive color
    col[1] = color(192, 217, 252); // Active color
  }

  // Create copy
  Tile copyTile() {
    Tile t = new Tile(x, y);
    t.txt = txt;
    return t;
  }

  // Display tile
  void show(color c) {
    // Tile
    strokeWeight(2);
    stroke(153, 108, 204);
    fill(c);
    rect(x*scale, y*scale, scale, scale);
    // Text
    fill(153, 108, 204);
    textSize(48);
    text(txt, x*scale+scale/2, y*scale+scale/2);
  }
}

/// Get the mouse position in grid
void updateGridPos() {
  // Indicies are based on mouse position
  mouseGridX = mouseX/scale;
  mouseGridY = mouseY/scale;

  // Constrain indicies to prevent out of range exceptions
  mouseGridX = constrain(mouseGridX, 0, dim-1);
  mouseGridY = constrain(mouseGridY, 0, dim-1);
}

/// Click to set space and change player
void mousePressed() {
  Tile hovered = board.tiles[mouseGridX][mouseGridY];
  if (hovered.isActive == 1) { // Only on successful click
    // Create and update data for next board
    Board b = board.copyBoard();
    Tile newHovered = b.tiles[mouseGridX][mouseGridY];
    newHovered.txt = b.getCurrentPlayer();
    newHovered.isActive = 0;
    boards.add(b);
    board = b;
    checkForWin();
    b.setCurrentPlayer((b.getCurrentPlayer().equals("X"))?"O":"X");
  }
}

// Determine if somebody won the game
void checkForWin() {
  boolean win = false;
  for (int i = 0; i < dim; i++) {
    if (board.tiles[i][0].txt != "") { // Only if not empty
      // Vertical win
      if (board.tiles[i][0].txt == board.tiles[i][1].txt && board.tiles[i][0].txt == board.tiles[i][2].txt) {
        win = true;
      }
      // Horizontal win
      if (board.tiles[0][i].txt == board.tiles[1][i].txt && board.tiles[0][i].txt == board.tiles[2][i].txt) {
        win = true;
      }
    }
  }
  // Diagonal win with the single longest line of code I've ever written
  if (board.tiles[0][0].txt != "" && board.tiles[0][0].txt == board.tiles[1][1].txt && board.tiles[0][0].txt == board.tiles[2][2].txt || board.tiles[0][2].txt != "" && board.tiles[0][2].txt == board.tiles[1][1].txt && board.tiles[0][2].txt == board.tiles[2][0].txt) {
    win = true;
  }

  // Update win
  if (win) {
    board.setWinner(board.getCurrentPlayer());
  }
}

/// Key Press to undo
void keyPressed() {
  if (boards.size() > 1) { // Only proceed if there is more than 1 Board in ArrayList
    boards.remove(boards.size()-1);
    board = boards.get(boards.size()-1);
  }

  for (Board b : boards) {
    println("Board" + b);
    for (Tile[] i : b.tiles) {
      for (Tile t : i) {
        println(t.txt);
      }
    }
  }
}
