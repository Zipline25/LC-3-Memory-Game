;*****************************************************************************
; Author: Tristan Newey
; Date: 05/13/2026
;
; Description:
;     This program uses a random letter generator and provides the user a string of characters that
;     they must memorize and re-enter to progress to the next level, 
;     user's goal is to get a high score or to level 20.
;
; Register Usage:
; R0 - 
; R1 - 
; R2 - 
; R3 - 
; R4 - 
; R5 - 
; R6 - 
; R7 - 
;*****************************************************************************
    .ORIG x3000

    ADD R0, R1, R2
    AND R0, R0, #7
    AND R1, R1, #7

    LEA R2, seq
    AND R3, R3, #0
    ADD R3, R3, #-15
    ADD R3, R3, #-5

GenerateLetters
    STR R0, R2, #0
    ADD R2, R2, #1
    ADD R4, R0, R1
    LD  R5, neg26
    ADD R6, R4, R5
    BRn GenerateModOk
    ADD R4, R4, R5
    ADD R6, R4, R5
    BRn GenerateModOk
    ADD R4, R4, R5
GenerateModOk
    ADD R1, R0, #0
    ADD R0, R4, #0
    ADD R3, R3, #1
    BRn GenerateLetters

    AND R0, R0, #0
    ADD R0, R0, #3
    ST  R0, len
    AND R0, R0, #0
    ST  R0, firstround

    JSR Menu

GameLoop
    JSR Display
    JSR Input
    BR  GameLoop

HALT

;***********************************Menu**************************************
; Description:
;     Clears the screen, displays the title and prompt,
;     waits for the player to press 1 to begin, then
;     scrolls the menu away before returning.
;
; Register Usage:
; R0 - output character / GETC result / comparison
; R1 - ascii1 for comparison
; R2 - result of input - ascii1
; R3 - loop counter
;*****************************************************************************
Menu
    LD  R3, neg30
MenuClearLoop
    LD  R0, newline
    OUT
    ADD R3, R3, #1
    BRn MenuClearLoop

    LEA R0, menumsg
    PUTS

MenuWait
    GETC
    LD  R1, ascii1
    NOT R1, R1
    ADD R1, R1, #1
    ADD R2, R0, R1
    BRnp MenuWait

    LD  R3, neg30
MenuScrollLoop
    LD  R0, newline
    OUT
    ADD R3, R3, #1
    BRn MenuScrollLoop

    RET

;***********************************SubDisplay********************************
; Description:
;     Clears the screen, prints the correct message if not
;     the first round, prints the remember header, then
;     displays the current sequence with a delay before
;     scrolling it off screen and printing the input prompt.
;
; Register Usage:
; R0 - output character / firstround flag
; R1 - current length
; R2 - pointer into seq
; R3 - loop counter / ascii offset
; R5 - sequence index
; R6 - loop comparison result
; R7 - delay outer counter (saved by JSR, restored on RET)
;*****************************************************************************
Display
    LD  R3, neg30
    
DisplayClearLoop
    LD  R0, newline
    OUT
    ADD R3, R3, #1
    BRn DisplayClearLoop

    LD  R0, newline
    OUT

    LD  R0, firstround
    BRz DisplayHeader
    LEA R0, correctmsg
    PUTS

DisplayHeader
    AND R0, R0, #0
    ADD R0, R0, #1
    ST  R0, firstround
    LEA R0, remembermsg
    PUTS

    AND R5, R5, #0
    LD  R1, len

DisplayLoop
    LEA R2, seq
    ADD R2, R2, R5
    LDR R0, R2, #0
    LD  R3, pos65
    ADD R0, R0, R3
    OUT
    LD  R0, pos32
    OUT
    ADD R5, R5, #1
    NOT R6, R1
    ADD R6, R6, #1
    ADD R6, R5, R6
    BRn DisplayLoop

    LD  R0, newline
    OUT

    ST  R7, savedR7
    LD  R7, delayouter
    
DisplayDelayOuter
    LD  R6, delayinner
    
DisplayDelayInner
    ADD R6, R6, #1
    BRn DisplayDelayInner
    ADD R7, R7, #1
    BRn DisplayDelayOuter
    LD  R7, savedR7

    LD  R3, neg30
    
DisplayScrollLoop
    LD  R0, newline
    OUT
    ADD R3, R3, #1
    BRn DisplayScrollLoop

    LEA R0, promptmsg
    PUTS

    RET

;***********************************SubInput*********************************
; Description:
;     Reads player keypresses one at a time, converts to
;     uppercase, strips ASCII offset and compares against
;     the stored sequence. Jumps to SubWrong on mismatch.
;     On full correct sequence, grows length by one,
;     checks for win condition and jumps to SubScore if so,
;     otherwise returns to let GameLoop call SubDisplay again.
;
; Register Usage:
; R0 - input character / comparison
; R1 - current length / comparison
; R2 - pointer into seq
; R3 - expected value / ascii offset
; R4 - uppercase mask
; R5 - sequence index
; R6 - loop comparison result
;****************************************************************************
Input
    LD  R4, uppermask
    AND R5, R5, #0
    LD  R1, len

InputLoop
    IN
    AND R0, R0, R4
    LD  R3, neg65
    ADD R0, R0, R3

    LEA R2, seq
    ADD R2, R2, R5
    LDR R3, R2, #0

    NOT R3, R3
    ADD R3, R3, #1
    ADD R3, R0, R3
    BRnp Wrong

    ADD R5, R5, #1
    NOT R6, R1
    ADD R6, R6, #1
    ADD R6, R5, R6
    BRn InputLoop

    LD  R3, neg30
InputPostScroll
    LD  R0, newline
    OUT
    ADD R3, R3, #1
    BRn InputPostScroll

    LD  R1, len
    ADD R1, R1, #1
    ST  R1, len
    ADD R1, R1, #-15
    ADD R1, R1, #-5
    BRz Win

    RET

;***********************************SubWin************************************
; Description:
;     Prints the win message then falls through to SubScore
;     to display levels completed before halting.
;
; Register Usage:
; R0 - output character
;*****************************************************************************
Win
    LD  R0, newline
    OUT
    LEA R0, winmsg
    PUTS
    JSR Score
    HALT

;***********************************SubWrong**********************************
; Description:
;     Scrolls the screen, prints the fail message, reveals
;     the correct sequence, then falls through to SubScore
;     to display levels completed before halting.
;
; Register Usage:
; R0 - output character / sequence letter
; R1 - current length
; R2 - pointer into seq
; R3 - ascii offset
; R5 - sequence index
; R6 - loop comparison result
;*****************************************************************************
Wrong
    LD  R3, neg30
    
WrongScrollLoop
    LD  R0, newline
    OUT
    ADD R3, R3, #1
    BRn WrongScrollLoop

    LEA R0, failmsg
    PUTS
    LEA R0, revealmsg
    PUTS

    AND R5, R5, #0
    LD  R1, len

WrongRevealLoop
    LEA R2, seq
    ADD R2, R2, R5
    LDR R0, R2, #0
    LD  R3, pos65
    ADD R0, R0, R3
    OUT
    LD  R0, pos32
    OUT
    ADD R5, R5, #1
    NOT R6, R1
    ADD R6, R6, #1
    ADD R6, R5, R6
    BRn WrongRevealLoop

    LD  R0, newline
    OUT
    JSR Score
    HALT

;***********************************Score*************************************
; Description:
;     Prints the levels completed message followed by the
;     number of levels the player completed, calculated
;     as current length minus 3 converted to an ASCII digit.
;
; Register Usage:
; R0 - output character / score digit
; R1 - ascii digit offset
;*****************************************************************************
Score
    LEA R0, scoremsg
    PUTS
    LD  R0, len
    ADD R0, R0, #-3
    LD  R1, pos48
    ADD R0, R0, R1
    OUT
    LD  R0, newline
    OUT
    RET

neg26       .FILL -26
neg65       .FILL -65
neg30       .FILL -30
pos65       .FILL 65
pos32       .FILL 32
pos48       .FILL 48
newline     .FILL 10
delayouter  .FILL -300
delayinner  .FILL -300
uppermask   .FILL -33
ascii1      .FILL 49
savedR7     .BLKW 1
len         .BLKW 1
firstround  .BLKW 1
seq         .BLKW 20
menumsg     .STRINGZ "=== Memory Game === \nPress 1 to start: "
correctmsg  .STRINGZ "Nice job! Next round,"
remembermsg .STRINGZ "Remember this->\n"
promptmsg   .STRINGZ "Your turn: "
winmsg      .STRINGZ "You beat all 20 rounds!"
failmsg     .STRINGZ "Wrong, Game over :( "
revealmsg   .STRINGZ "The sequence was: "
scoremsg    .STRINGZ "Levels completed: "

.END