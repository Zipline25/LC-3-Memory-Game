# LC-3 Memory Game

A memory-sequence game written in **LC-3 assembly language**.
The player must memorize and repeat a long sequence of letters (A–Z).
Each correct round increases the difficulty by adding letters.

---

## How to Play

- Press **1** to start the game from the menu
- A sequence of letters is displayed briefly
- The player must re-enter the sequence exactly
- Each successful round increases the sequence length by 1
- The game ends when the player makes a mistake or completes all 17 rounds

---

## Goal of the Game

The game ends when:
- The player enters an incorrect letter in the sequence
- The player completes all 17 levels (20 letters)

When this happens:
- The correct sequence is revealed (if the player got a sequence wrong)
- The final score (levels completed) is displayed

Try to get the highest score possible or even beat all 17 levels!

---

## Simulator Used

- **LC-3Tools v2.0.2**  
  https://github.com/chiragsakhuja/lc3tools/releases

---

## How to Run

1. Randomize the machine state
2. load (or reload) object files
3. put a breakpoint on halt, at location x30A3 (only need to do this once)

---

## ! Important Notes !

- The machine **must be randomized before each playthrough** (to get relatively consistent "random" letters)
- The program must also be reloaded after this
