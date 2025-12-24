# TIC TAC TOE - COBOL AI Edition

A Tic Tac Toe game implemented in COBOL featuring an intelligent AI opponent named **TIC_TAC_CAT**, session scoring, and input validation.

```
  _______ __   ______      ______          ______     
 /_  __(_) /__/ ____/___ _/ ____/___ _____/ ____/___ _/ /_
  / / / / //_/ /   / __ `/ /   / __ `/ __/ /   / __ `/ __/
 / / / / ,< / /___/ /_/ / /___/ /_/ / /_/ /___/ /_/ / /_  
/_/ /_/_/|_|\____/\__,_/\____/\__,_/\__/\____/\__,_/\__/  

               |\__/,|   (`\ 
             _.|o o  |_   ) )
           -///---///--------
          TIC TAC TOE CAT AI
```

## Quick Start

### Prerequisites
- COBOL compiler (GnuCOBOL recommended)
- Terminal/Command line

### How to Run

```bash
# Navigate to the game directory
cd /home/xxx/xxx/COBOL

# Compile the program
cobc -x -free TIC_TAC_TOE.cob -o tictactoe

# Run the game
./tictactoe
```

## How to Play

### Game Rules
- Classic Tic Tac Toe: Get 3 of your marks in a row (horizontal, vertical, or diagonal) to win
- You play as **X**, TIC_TAC_CAT plays as **O**
- The board is a 3x3 grid numbered 1-3 for rows and columns

### Making a Move
1. When prompted "HUMAN (X), ENTER ROW (1-3) AND COL (1-3):", enter two single digits
2. First digit: row (1-3)
3. Second digit: column (1-3)
4. Example: `22` places your mark in the center

### Board Layout
```
    1   2   3
1   X | O | X
   ---|---|---
2   O | X | O
   ---|---|---
3   X | O | X
```

### Input Validation
The game validates all input:
- Rejects non-numeric characters
- Ensures coordinates are within range (1-3)
- Prevents moves on occupied spaces
- Prompts for retry on invalid input

### Winning
- Get 3 marks in a row to win
- If all 9 squares fill with no winner, it's a draw
- Game displays the winner with ASCII cat art
- Score is tracked across multiple games

## TIC_TAC_CAT AI Strategy

The AI uses a sophisticated priority-based decision system:

1. **Win Move** - If TIC_TAC_CAT can win, it will (scans rows, columns, diagonals)
2. **Block Move** - If you can win next turn, TIC_TAC_CAT blocks you
3. **Center Control** - Takes the center square (2,2) if available
4. **Corner Strategy** - Prefers corner positions (1,1), (1,3), (3,1), (3,3)
5. **Fill Available** - Takes any remaining empty square

### AI Implementation Details
- `SCAN-FOR-WIN-OR-BLOCK`: Checks all rows, columns, and diagonals for 2-in-a-row patterns
- `CHECK-DIAGONALS`: Specialized logic for both diagonal directions
- `TRY-CORNERS`: Strategic corner preference
- `TAKE-FIRST-SLOT`: Fallback to fill any available space

## Session Features

### Score Tracking
The game tracks scores across multiple games:
- **HUMAN (X)**: Your wins
- **TIC_TAC_CAT (O)**: AI wins
- **DRAWS**: Games ending in a draw

Score is displayed after each match and persists until you exit.

### Play Again
After each game, you're prompted to play again. Enter:
- `Y` or `y` to continue
- `N` or `n` to exit

## Program Architecture

### Data Structures

```
GAME-BOARD (3x3 Grid)
├── BOARD-ROW (3 rows)
│   └── BOARD-COL (3 columns)
│       └── Cell value: ' ', 'X', or 'O'

GAME-STATE
├── MOVES-COUNT (0-9)
├── TURN-STATUS (P=Progress, W=Won, D=Draw)
├── WINNER-TOKEN (' ', 'X', 'O')
└── CURRENT-PLAYER ('X' or 'O')

SESSION-STATE
├── PLAY-AGAIN-FLAG (Y/N)
├── HUMAN-SCORE (0-99)
├── AI-SCORE (0-99)
└── DRAW-SCORE (0-99)

INPUT HANDLING
├── RAW-INPUT (character input)
├── PARSED-INPUT (numeric conversion)
└── INPUT-VALID-FLAG (validation status)

AI-VARS
├── BEST-ROW (calculated move row)
├── BEST-COL (calculated move column)
├── FOUND-MOVE-FLAG (move found status)
└── SCAN-TOKEN (token being scanned: 'X' or 'O')
```

### Program Flow Schematic

```
┌─────────────────────────────────────┐
│      MAIN-PROCEDURE START           │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│    DISPLAY-TITLE (Show ASCII art)   │
└────────────┬────────────────────────┘
             │
             ▼
        ┌────────────────────────┐
        │  SESSION LOOP START    │
        │  (Until PLAY-AGAIN-NO) │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │ INITIALIZE-MATCH       │
        │ (Clear board, reset    │
        │  scores, set player)   │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  PLAY-MATCH LOOP       │
        │  (Until game ends)     │
        └────────┬───────────────┘
                 │
                 ├─────────────────────────┐
                 │                         │
                 ▼                         │
        ┌────────────────────┐             │
        │  DISPLAY-BOARD     │             │
        │  (Show current     │             │
        │   board state)     │             │
        └────────┬───────────┘             │
                 │                         │
                 ▼                         │
        ┌────────────────────┐             │
        │ Is it HUMAN turn?  │             │
        └────┬───────────┬───┘             │
             │           │                 │
          YES│           │NO               │
             │           │                 │
             ▼           ▼                 │
        ┌──────────┐  ┌──────────────┐    │
        │GET-HUMAN-│  │GET-AI-MOVE   │    │
        │MOVE      │  │              │    │
        │          │  │1.Try Win     │    │
        │1.Input   │  │2.Block Human │    │
        │  Row/Col │  │3.Center      │    │
        │2.Validate│  │4.Corners     │    │
        │3.Place X │  │5.Fill        │    │
        └────┬─────┘  └────┬─────────┘    │
             │             │               │
             └──────┬──────┘               │
                    │                      │
                    ▼                      │
        ┌────────────────────────┐         │
        │CHECK-GAME-STATUS       │         │
        │                        │         │
        │1.Check rows            │         │
        │2.Check columns         │         │
        │3.Check diagonals       │         │
        │4.Check draw (9 moves)  │         │
        └────────┬───────────────┘         │
                 │                         │
                 ▼                         │
        ┌────────────────────────┐         │
        │ Game still in progress?│         │
        └────┬───────────────┬───┘         │
             │               │             │
          YES│               │NO           │
             │               │             │
             ▼               │             │
        ┌──────────────┐     │             │
        │SWITCH-TURN   │     │             │
        │(X ↔ O)       │     │             │
        └────┬─────────┘     │             │
             │               │             │
             └───────┬───────┘             │
                     │                     │
                     └─────────────────────┘
                           │
                           ▼
        ┌────────────────────────┐
        │  PLAY-MATCH LOOP END   │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  FINALIZE-MATCH        │
        │  (Display result,      │
        │   update scores)       │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  DISPLAY-SCORE         │
        │  (Show session totals)  │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  ASK-REPLAY            │
        │  (Prompt for Y/N)      │
        └────────┬───────────────┘
                 │
        (Loop back if Y, exit if N)
                 │
                 ▼
┌─────────────────────────────────────┐
│  Display exit message               │
│  STOP RUN (Exit program)            │
└─────────────────────────────────────┘
```

### Key Procedures

| Procedure | Purpose |
|-----------|---------|
| `MAIN-PROCEDURE` | Session controller, manages multiple games |
| `INITIALIZE-MATCH` | Clear board, reset game state |
| `PLAY-MATCH` | Core game loop |
| `GET-HUMAN-MOVE` | Robust input validation and move placement |
| `GET-AI-MOVE` | AI decision logic with priority system |
| `SCAN-FOR-WIN-OR-BLOCK` | Find 2-in-a-row patterns (rows/cols/diagonals) |
| `CHECK-DIAGONALS` | Specialized diagonal checking |
| `TRY-CORNERS` | Strategic corner preference |
| `TAKE-FIRST-SLOT` | Fallback move selection |
| `CHECK-GAME-STATUS` | Detect win/draw/continue |
| `SWITCH-TURN` | Toggle between human and AI |
| `FINALIZE-MATCH` | Display results and update scores |
| `DISPLAY-SCORE` | Show session score table |
| `ASK-REPLAY` | Prompt for another game |
| `DISPLAY-TITLE` | Show ASCII art title |
| `DISPLAY-BOARD` | Render current board state |

## Example Game Session

```
  _______ __   ______      ______          ______     
 /_  __(_) /__/ ____/___ _/ ____/___ _____/ ____/___ _/ /_
  / / / / //_/ /   / __ `/ /   / __ `/ __/ /   / __ `/ __/
 / / / / ,< / /___/ /_/ / /___/ /_/ / /_/ /___/ /_/ / /_  
/_/ /_/_/|_|\____/\__,_/\____/\__,_/\__/\____/\__,_/\__/  

               |\__/,|   (`\ 
             _.|o o  |_   ) )
           -///---///--------
          TIC TAC TOE CAT AI
 
    1   2   3
1     |   |  
   ---|---|---
2     |   |  
   ---|---|---
3     |   |  
 
HUMAN (X), ENTER ROW (1-3) AND COL (1-3): 22
THE CAT IS PLOTTING...

    1   2   3
1     |   |  
   ---|---|---
2     | X |  
   ---|---|---
3     | O |  
 
HUMAN (X), ENTER ROW (1-3) AND COL (1-3): 11
THE CAT IS PLOTTING...

    1   2   3
1   X |   |  
   ---|---|---
2     | X | O
   ---|---|---
3     | O |  
 
HUMAN (X), ENTER ROW (1-3) AND COL (1-3): 33
THE CAT IS PLOTTING...

    1   2   3
1   X |   | O
   ---|---|---
2     | X | O
   ---|---|---
3     | O | X
 
   / \__
  \    @\___
  /         O
 /   (_____/  WINNER: O!
/_____/   U
 
+-----------------------------+
|        CURRENT SCORE        |
+-----------------------------+
| HUMAN (X)       : 0
| TIC TAC CAT (O) : 1
| DRAWS           : 0
+-----------------------------+
PLAY AGAIN? (Y/N): Y
```

## Troubleshooting

### Compilation Errors
- Ensure GnuCOBOL is installed: `cobc --version`
- Check file path is correct
- Verify COBOL syntax (free format)

### Invalid Move Errors
- Enter row and column as single digits (1-3)
- Ensure cell is empty (not already occupied)
- Use numeric characters only
- Format: `RC` (two digits, no space)

### Game Hangs
- Check that input is being entered correctly
- Ensure terminal supports the display characters
- Verify input is followed by Enter key

## Technical Details

- **Language**: COBOL (Free Format)
- **Compiler**: GnuCOBOL
- **Board Size**: 3x3 grid
- **Players**: Human (X) vs AI (O)
- **Win Condition**: 3 in a row (horizontal, vertical, diagonal)
- **Draw Condition**: All 9 squares filled with no winner
- **Session Scoring**: Tracks wins and draws across multiple games

## Features

1. Intelligent AI with multi-level strategy  
2. Robust input validation  
3. Session score tracking  
4. ASCII art visuals  
5. Play multiple games without restarting  
6. Comprehensive error handling  
7. Clean, readable COBOL code  

---

**Enjoy playing against TIC_TAC_CAT!** 🐱
# TIC_TAC_TOE_Cat
