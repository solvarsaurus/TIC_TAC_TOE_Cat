IDENTIFICATION DIVISION.
       PROGRAM-ID. TIC-TAC-TOE-CAT.
       AUTHOR. ANDY - SOLVARSAURUS GITHUB.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       *> ---------------------------------------------------
       *> GAME BOARD & STATE
       *> ---------------------------------------------------
       01  GAME-BOARD.
           05  BOARD-ROW OCCURS 3 TIMES.
               10  BOARD-COL PIC X(1) OCCURS 3 TIMES VALUE ' '.

       01  GAME-STATE.
           05  MOVES-COUNT        PIC 9(1) VALUE 0.
           05  TURN-STATUS        PIC X(1) VALUE ' '.
               88  GAME-IN-PROGRESS    VALUE 'P'.
               88  GAME-WON            VALUE 'W'.
               88  GAME-DRAW           VALUE 'D'.
           05  WINNER-TOKEN       PIC X(1) VALUE ' '.
           05  CURRENT-PLAYER     PIC X(1) VALUE 'X'.
               88  PLAYER-HUMAN        VALUE 'X'.
               88  PLAYER-AI           VALUE 'O'.

       *> ---------------------------------------------------
       *> SESSION SCORES
       *> ---------------------------------------------------
       01  SESSION-STATE.
           05  PLAY-AGAIN-FLAG    PIC X(1) VALUE 'Y'.
               88  PLAY-AGAIN-YES      VALUE 'Y', 'y'.
               88  PLAY-AGAIN-NO       VALUE 'N', 'n'.
           05  HUMAN-SCORE        PIC 9(2) VALUE 0.
           05  AI-SCORE           PIC 9(2) VALUE 0.
           05  DRAW-SCORE         PIC 9(2) VALUE 0.

       *> ---------------------------------------------------
       *> ROBUST INPUT HANDLING
       *> ---------------------------------------------------
       01  RAW-INPUT.
           05  RAW-ROW            PIC X(1).
           05  RAW-COL            PIC X(1).
       01  PARSED-INPUT.
           05  ROW-IDX            PIC 9(1).
           05  COL-IDX            PIC 9(1).
       01  INPUT-VALID-FLAG       PIC X(1).
           88  INPUT-IS-VALID      VALUE 'Y'.
           88  INPUT-IS-INVALID    VALUE 'N'.

       *> ---------------------------------------------------
       *> AI UTILITY VARIABLES
       *> ---------------------------------------------------
       01  AI-VARS.
           05  BEST-ROW           PIC 9(1).
           05  BEST-COL           PIC 9(1).
           05  FOUND-MOVE-FLAG    PIC X(1).
               88  MOVE-FOUND          VALUE 'Y'.
               88  MOVE-NOT-FOUND      VALUE 'N'.
           05  SCAN-TOKEN         PIC X(1).

       *> ---------------------------------------------------
       *> LOOP COUNTERS
       *> ---------------------------------------------------
       01  COUNTERS.
           05  I                  PIC 9(1).
           05  J                  PIC 9(1).
           05  TOKEN-COUNT        PIC 9(1).
           05  EMPTY-COUNT        PIC 9(1).
           05  EMPTY-ROW          PIC 9(1).
           05  EMPTY-COL          PIC 9(1).

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM DISPLAY-TITLE.

           PERFORM UNTIL PLAY-AGAIN-NO
               PERFORM INITIALIZE-MATCH
               PERFORM PLAY-MATCH
               PERFORM FINALIZE-MATCH
               PERFORM ASK-REPLAY
           END-PERFORM.

           DISPLAY " "
           DISPLAY "THANKS FOR PLAYING TIC TAC TOE CAT. MEOW!"
           STOP RUN.

       *> ---------------------------------------------------
       *> INITIALIZATION
       *> ---------------------------------------------------
       INITIALIZE-MATCH.
           MOVE 0 TO MOVES-COUNT.
           SET GAME-IN-PROGRESS TO TRUE.
           MOVE ' ' TO WINNER-TOKEN.
           SET PLAYER-HUMAN TO TRUE.
           
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
               PERFORM VARYING J FROM 1 BY 1 UNTIL J > 3
                   MOVE ' ' TO BOARD-COL(I, J)
               END-PERFORM
           END-PERFORM.

       *> ---------------------------------------------------
       *> CORE GAME LOOP
       *> ---------------------------------------------------
       PLAY-MATCH.
           PERFORM UNTIL NOT GAME-IN-PROGRESS
               PERFORM DISPLAY-BOARD
               
               IF PLAYER-HUMAN
                   PERFORM GET-HUMAN-MOVE
               ELSE
                   PERFORM GET-AI-MOVE
               END-IF

               PERFORM CHECK-GAME-STATUS
               
               IF GAME-IN-PROGRESS
                   PERFORM SWITCH-TURN
               END-IF
           END-PERFORM.

       SWITCH-TURN.
           IF PLAYER-HUMAN
               SET PLAYER-AI TO TRUE
           ELSE
               SET PLAYER-HUMAN TO TRUE
           END-IF.

       *> ---------------------------------------------------
       *> HUMAN LOGIC (ROBUST INPUT)
       *> ---------------------------------------------------
       GET-HUMAN-MOVE.
           SET INPUT-IS-INVALID TO TRUE.
           PERFORM UNTIL INPUT-IS-VALID
               DISPLAY "HUMAN (X), ENTER ROW (1-3) AND COL (1-3): " 
                   WITH NO ADVANCING
               ACCEPT RAW-INPUT
               
               *> ENSURE NUMERIC BEFORE MOVING TO PIC 9
               IF RAW-ROW IS NUMERIC AND RAW-COL IS NUMERIC
                   MOVE RAW-ROW TO ROW-IDX
                   MOVE RAW-COL TO COL-IDX
                   
                   IF ROW-IDX >= 1 AND ROW-IDX <= 3 AND 
                      COL-IDX >= 1 AND COL-IDX <= 3
                       IF BOARD-COL(ROW-IDX, COL-IDX) = ' '
                           MOVE 'X' TO BOARD-COL(ROW-IDX, COL-IDX)
                           ADD 1 TO MOVES-COUNT
                           SET INPUT-IS-VALID TO TRUE
                       ELSE
                           DISPLAY "SPACE OCCUPIED. TRY AGAIN."
                       END-IF
                   ELSE
                       DISPLAY "COORDINATES OUT OF RANGE (1-3)."
                   END-IF
               ELSE
                   DISPLAY "INVALID INPUT. USE NUMBERS ONLY."
               END-IF
           END-PERFORM.

       *> ---------------------------------------------------
       *> AI LOGIC (HEURISTIC)
       *> ---------------------------------------------------
       GET-AI-MOVE.
           DISPLAY "THE CAT IS PLOTTING..."
           SET MOVE-NOT-FOUND TO TRUE.

           *> 1. ATTEMPT TO WIN (LOOK FOR 2 'O'S)
           IF NOT MOVE-FOUND
               MOVE 'O' TO SCAN-TOKEN
               PERFORM SCAN-FOR-WIN-OR-BLOCK
           END-IF.

           *> 2. BLOCK HUMAN (LOOK FOR 2 'X'S)
           IF NOT MOVE-FOUND
               MOVE 'X' TO SCAN-TOKEN
               PERFORM SCAN-FOR-WIN-OR-BLOCK
           END-IF.

           *> 3. TAKE CENTER (STRATEGIC)
           IF NOT MOVE-FOUND
               IF BOARD-COL(2, 2) = ' '
                   MOVE 2 TO BEST-ROW
                   MOVE 2 TO BEST-COL
                   SET MOVE-FOUND TO TRUE
               END-IF
           END-IF.

           *> 4. TAKE ANY CORNER (STRATEGIC)
           IF NOT MOVE-FOUND
               PERFORM TRY-CORNERS
           END-IF.

           *> 5. TAKE FIRST AVAILABLE
           IF NOT MOVE-FOUND
               PERFORM TAKE-FIRST-SLOT
           END-IF.

           *> EXECUTE MOVE
           MOVE 'O' TO BOARD-COL(BEST-ROW, BEST-COL)
           ADD 1 TO MOVES-COUNT.

       *> ---------------------------------------------------
       *> AI HELPERS
       *> ---------------------------------------------------
       SCAN-FOR-WIN-OR-BLOCK.
           *> CHECK ROWS
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3 OR MOVE-FOUND
               MOVE 0 TO TOKEN-COUNT
               MOVE 0 TO EMPTY-COUNT
               PERFORM VARYING J FROM 1 BY 1 UNTIL J > 3
                   IF BOARD-COL(I, J) = SCAN-TOKEN
                       ADD 1 TO TOKEN-COUNT
                   ELSE IF BOARD-COL(I, J) = ' '
                       ADD 1 TO EMPTY-COUNT
                       MOVE I TO EMPTY-ROW
                       MOVE J TO EMPTY-COL
                   END-IF
               END-PERFORM
               IF TOKEN-COUNT = 2 AND EMPTY-COUNT = 1
                   MOVE EMPTY-ROW TO BEST-ROW
                   MOVE EMPTY-COL TO BEST-COL
                   SET MOVE-FOUND TO TRUE
               END-IF
           END-PERFORM.

           *> CHECK COLS
           IF NOT MOVE-FOUND
               PERFORM VARYING J FROM 1 BY 1 UNTIL J > 3 OR MOVE-FOUND
                   MOVE 0 TO TOKEN-COUNT
                   MOVE 0 TO EMPTY-COUNT
                   PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
                       IF BOARD-COL(I, J) = SCAN-TOKEN
                           ADD 1 TO TOKEN-COUNT
                       ELSE IF BOARD-COL(I, J) = ' '
                           ADD 1 TO EMPTY-COUNT
                           MOVE I TO EMPTY-ROW
                           MOVE J TO EMPTY-COL
                       END-IF
                   END-PERFORM
                   IF TOKEN-COUNT = 2 AND EMPTY-COUNT = 1
                       MOVE EMPTY-ROW TO BEST-ROW
                       MOVE EMPTY-COL TO BEST-COL
                       SET MOVE-FOUND TO TRUE
                   END-IF
               END-PERFORM
           END-IF.

           *> CHECK DIAGONALS
           IF NOT MOVE-FOUND
               PERFORM CHECK-DIAGONALS
           END-IF.

       CHECK-DIAGONALS.
           *> DIAGONAL 1 (1,1) (2,2) (3,3)
           MOVE 0 TO TOKEN-COUNT
           MOVE 0 TO EMPTY-COUNT
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
               IF BOARD-COL(I, I) = SCAN-TOKEN
                   ADD 1 TO TOKEN-COUNT
               ELSE IF BOARD-COL(I, I) = ' '
                   ADD 1 TO EMPTY-COUNT
                   MOVE I TO EMPTY-ROW
                   MOVE I TO EMPTY-COL
               END-IF
           END-PERFORM
           IF TOKEN-COUNT = 2 AND EMPTY-COUNT = 1
               MOVE EMPTY-ROW TO BEST-ROW
               MOVE EMPTY-COL TO BEST-COL
               SET MOVE-FOUND TO TRUE
           END-IF.

           *> DIAGONAL 2 (1,3) (2,2) (3,1)
           IF NOT MOVE-FOUND
               MOVE 0 TO TOKEN-COUNT
               MOVE 0 TO EMPTY-COUNT
               IF BOARD-COL(1, 3) = SCAN-TOKEN ADD 1 TO TOKEN-COUNT END-IF
               IF BOARD-COL(2, 2) = SCAN-TOKEN ADD 1 TO TOKEN-COUNT END-IF
               IF BOARD-COL(3, 1) = SCAN-TOKEN ADD 1 TO TOKEN-COUNT END-IF
               
               IF BOARD-COL(1, 3) = ' ' 
                   ADD 1 TO EMPTY-COUNT
                   MOVE 1 TO EMPTY-ROW MOVE 3 TO EMPTY-COL 
               END-IF
               IF BOARD-COL(2, 2) = ' '
                   ADD 1 TO EMPTY-COUNT
                   MOVE 2 TO EMPTY-ROW MOVE 2 TO EMPTY-COL
               END-IF
               IF BOARD-COL(3, 1) = ' '
                   ADD 1 TO EMPTY-COUNT
                   MOVE 3 TO EMPTY-ROW MOVE 1 TO EMPTY-COL
               END-IF

               IF TOKEN-COUNT = 2 AND EMPTY-COUNT = 1
                   MOVE EMPTY-ROW TO BEST-ROW
                   MOVE EMPTY-COL TO BEST-COL
                   SET MOVE-FOUND TO TRUE
               END-IF
           END-IF.

       TRY-CORNERS.
           IF BOARD-COL(1, 1) = ' '
               MOVE 1 TO BEST-ROW MOVE 1 TO BEST-COL SET MOVE-FOUND TO TRUE
           ELSE IF BOARD-COL(1, 3) = ' '
               MOVE 1 TO BEST-ROW MOVE 3 TO BEST-COL SET MOVE-FOUND TO TRUE
           ELSE IF BOARD-COL(3, 1) = ' '
               MOVE 3 TO BEST-ROW MOVE 1 TO BEST-COL SET MOVE-FOUND TO TRUE
           ELSE IF BOARD-COL(3, 3) = ' '
               MOVE 3 TO BEST-ROW MOVE 3 TO BEST-COL SET MOVE-FOUND TO TRUE
           END-IF.

       TAKE-FIRST-SLOT.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3 OR MOVE-FOUND
               PERFORM VARYING J FROM 1 BY 1 UNTIL J > 3 OR MOVE-FOUND
                   IF BOARD-COL(I, J) = ' '
                       MOVE I TO BEST-ROW
                       MOVE J TO BEST-COL
                       SET MOVE-FOUND TO TRUE
                   END-IF
               END-PERFORM
           END-PERFORM.

       *> ---------------------------------------------------
       *> WIN DETECTION
       *> ---------------------------------------------------
       CHECK-GAME-STATUS.
           *> CHECK ROWS
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
               IF BOARD-COL(I, 1) NOT = ' ' AND
                  BOARD-COL(I, 1) = BOARD-COL(I, 2) AND
                  BOARD-COL(I, 2) = BOARD-COL(I, 3)
                   MOVE BOARD-COL(I, 1) TO WINNER-TOKEN
                   SET GAME-WON TO TRUE
               END-IF
           END-PERFORM.

           *> CHECK COLS
           IF GAME-IN-PROGRESS
               PERFORM VARYING J FROM 1 BY 1 UNTIL J > 3
                   IF BOARD-COL(1, J) NOT = ' ' AND
                      BOARD-COL(1, J) = BOARD-COL(2, J) AND
                      BOARD-COL(2, J) = BOARD-COL(3, J)
                       MOVE BOARD-COL(1, J) TO WINNER-TOKEN
                       SET GAME-WON TO TRUE
                   END-IF
               END-PERFORM
           END-IF.

           *> CHECK DIAGONALS
           IF GAME-IN-PROGRESS
               IF BOARD-COL(1, 1) NOT = ' ' AND
                  BOARD-COL(1, 1) = BOARD-COL(2, 2) AND
                  BOARD-COL(2, 2) = BOARD-COL(3, 3)
                   MOVE BOARD-COL(1, 1) TO WINNER-TOKEN
                   SET GAME-WON TO TRUE
               END-IF
               IF BOARD-COL(1, 3) NOT = ' ' AND
                  BOARD-COL(1, 3) = BOARD-COL(2, 2) AND
                  BOARD-COL(2, 2) = BOARD-COL(3, 1)
                   MOVE BOARD-COL(1, 3) TO WINNER-TOKEN
                   SET GAME-WON TO TRUE
               END-IF
           END-IF.

           *> CHECK DRAW
           IF GAME-IN-PROGRESS AND MOVES-COUNT = 9
               SET GAME-DRAW TO TRUE
           END-IF.

       *> ---------------------------------------------------
       *> END OF MATCH HANDLING
       *> ---------------------------------------------------
       FINALIZE-MATCH.
           PERFORM DISPLAY-BOARD.
           IF GAME-WON
               DISPLAY " "
               DISPLAY "   / \__"
               DISPLAY "  \    @\___"
               DISPLAY "  /         O"
               DISPLAY " /   (_____/  WINNER: " WINNER-TOKEN "!"
               DISPLAY "/_____/   U"
               DISPLAY " "
               IF WINNER-TOKEN = 'X'
                   ADD 1 TO HUMAN-SCORE
               ELSE
                   ADD 1 TO AI-SCORE
               END-IF
           ELSE
               DISPLAY "GAME DRAW! THE CAT IS UNIMPRESSED."
               ADD 1 TO DRAW-SCORE
           END-IF.
           PERFORM DISPLAY-SCORE.

       DISPLAY-SCORE.
           DISPLAY "+-----------------------------+".
           DISPLAY "|        CURRENT SCORE        |".
           DISPLAY "+-----------------------------+".
           DISPLAY "| HUMAN (X)       : " HUMAN-SCORE.
           DISPLAY "| TIC TAC CAT (O) : " AI-SCORE.
           DISPLAY "| DRAWS           : " DRAW-SCORE.
           DISPLAY "+-----------------------------+".

       ASK-REPLAY.
           DISPLAY "PLAY AGAIN? (Y/N): " WITH NO ADVANCING.
           ACCEPT PLAY-AGAIN-FLAG.

       *> ---------------------------------------------------
       *> VISUALS
       *> ---------------------------------------------------
       DISPLAY-TITLE.
           DISPLAY " ".
           DISPLAY "  _______ __   ______      ______          ______     ".
           DISPLAY " /_  __(_) /__/ ____/___ _/ ____/___ _____/ ____/___ _/ /_".
           DISPLAY "  / / / / //_/ /   / __ `/ /   / __ `/ __/ /   / __ `/ __/".
           DISPLAY " / / / / ,< / /___/ /_/ / /___/ /_/ / /_/ /___/ /_/ / /_  ".
           DISPLAY "/_/ /_/_/|_|\____/\__,_/\____/\__,_/\__/\____/\__,_/\__/  ".
           DISPLAY " ".
           DISPLAY "               |\__/,|   (`\ ".
           DISPLAY "             _.|o o  |_   ) )".
           DISPLAY "           -///---///--------".
           DISPLAY "          TIC TAC TOE CAT AI".
           DISPLAY " ".

       DISPLAY-BOARD.
           DISPLAY " "
           DISPLAY "    1   2   3"
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3
               DISPLAY I "  " BOARD-COL(I, 1) " | " 
                              BOARD-COL(I, 2) " | " 
                              BOARD-COL(I, 3)
               IF I < 3
                   DISPLAY "   ---|---|---"
               END-IF
           END-PERFORM.
           DISPLAY " ".