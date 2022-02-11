;This program acts as a stack based calculator built in LC-3 Assembly. It begins with a simple
;control loop that goes to the corresponding evaluate subroutine after a character is inputed
;and echoed to console. The evaluate subroutine identifies the character that was inputed by comparing
;to corresponding ASCII values and then calls the corresponding subroutine necessary. If the character 
;inputed is not valid, the subroutine will branch to an invalid section that outputs to console an 
;error message. If the inputed character is a number, the program will push the number to the stack, 
;while an equal sign will branch to a location to finish off the program and print the final value in 
;hex using the hex print subroutine. The other operators continue with their subroutines after popping two values,
;which often need to manually save R7 PC so as to not overwrite it when calling a subroutine within a subroutine.
;The power subroutine also calls the muliplication subroutine to simplify the operation. Lastly, we have 
;an extra section of code to check for if there is only one value left when we end the program correctly
;and pop the final value to be outputed.
 
.ORIG x3000

;your code goes here
 
OUTER_LOOP  
GETC                ;Obtains input value and stores in R0
OUT
JSR EVALUATE        ;Evaluate subroutine is called to evaluate the input character
BRnzp OUTER_LOOP    ;Branches to OUTER_LOOP to read next character


FINAL_RESULT
JSR POP         ;Pop final answer
ADD R5, R5, #0  ;Set condition codes based on popped status code
BRp PRINT_INVALID   ;Check if underflow on pop
AND R5, R5, #0  ;Clear R5
ADD R5, R0, #0  ;Shift final answer to output register
JSR PRINT_HEX   ;Jump to print as hex value subroutine

DONE
HALT                ;Halts program

CHECK_STACK
LD R3, STACK_START  ;Loads location of STACK_START into R3
LD R4, STACK_TOP    ;Loads location of STACK_TOP into R4
NOT R4, R4          ;Negates R4
ADD R4, R4, #1
ADD R4, R4, R3      ;Subtracts location of STACK_TOP from STACK_START
ADD R4, R4, #-1     ;Subtracts one from R4
BRz FINAL_RESULT    ;Branch to check if stack has only one value inside it
 
PRINT_INVALID      
LD R0, INVALID_OUT_PTR  ;Loads the invalid message string
PUTS                ;Prints the invalid message string
BRnzp DONE          ;Branches to DONE to halt the program
 
 
INVALID_OUT_PTR .FILL INVALID_OUT
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R4- value to print in hexadecimal
PRINT_HEX
 
ST R5, RESULT
 
ADD R4, R5, #0 ;shift result to R4
AND R5, R5, #0 ;Clear R5
ADD R5, R5, #4 ;initialize outer counter to 4
 
FOUR_LOOP
   AND R0,R0,#0 ;Clear register R0
   AND R6,R6,#0 ;Clear register R6
   ADD R6,R6,#4 ;initialize inner 4 bit counter
 
HEX_LOOP
   ADD R0, R0, R0       ;Bit shift register holding character values
   ADD R4, R4, #0       ;Set condition codes based on value in histogram address
   BRzp NON_NEGATIVE    ;Skip one line based on whether bit to be used is 1 or 0
   ADD R0, R0, #1       ;If R4 isnegative, put the corresponding bit one in the register
NON_NEGATIVE
   ADD R4, R4, R4   ;Bit shift register holding value in histogram address
   ADD R6, R6, #-1  ;Decrement inner loop counter
   BRp HEX_LOOP     ;loop four times by going back to HEX_LOOP
 
 
   ADD R6, R0, #-9  ;Subtracting 9 from R0 and adding to R6
   BRnz NUMBER      ;0-9
   ADD R0, R0, #7   ;Adds 7 to get to where letters are
   BRnzp NUMBER     ;A-F
 
HEX_BACK
   ADD R0, R0, R6   ;adding corresponding offset to R0
   OUT              ;printing out
   ADD R5, R5, #-1  ;decrementing the outer loop counter
   BRnp FOUR_LOOP   ;loop four times by going back to FOUR_LOOP
 
LD R5, RESULT
HALT ;Halt and print result
 
RESULT .FILL xBEEF
 
NUMBER
   LD R6, NUM_OFFSET    ;Load number offset into R6
   BRnzp HEX_BACK       ;Branch to HEX_BACK
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;
;
;your code goes here
EVALUATE
 
ST R7, SaveR7
 
LD R6, EQUAL_ASCII  ;Loading Ascii value of equal sign into R6
NOT R6, R6          ;Negate R6
ADD R6, R6, #1  
ADD R6, R6, R0      ;Subtracts Ascii value of equal sign from the input Ascii value
BRz CHECK_STACK     ;Checks whether input value is an equal sign
 
LD R6, SPACE_ASCII  ;Loads Ascii value of space character into R6
NOT R6, R6          ;Negate R6  
ADD R6, R6, #1
ADD R6, R6, R0      ;Subtracts Ascii value of space character from the impit Ascii value
BRz OUTER_LOOP      ;Checks whether input value is space character
 
LD R6, ZER0_ASCII   ;Loads Ascii value of 0 into R6
NOT R6, R6          ;NEGATES R6
ADD R6, R6, #1  
ADD R6, R0, R6      ;Checks if input is above the Ascii value 48
BRn SKIPI_POP       ;Branch to Pop two values in stack
LD R6, NINE_ASCII   ;Loads Ascii value of 9 into R6
NOT R6, R6          ;Negates R6
ADD R6, R6, #1
ADD R6, R0, R6      ;Checks if input is under Ascii value 57, ie. Checking if input is a number
BRzp SKIPI_POP      ;Branch to Pop two values in stack
 
LD R6, ZER0_ASCII   ;Loads Ascii value of 0 into R6
NOT R6, R6          ;Negates R6
ADD R6, R6, #1
ADD R0, R6, R0      ;Subtracts offset from Ascii value input to obtain decimal value of number and store it in R6
JSR PUSH            ;Push onto stack
LD R7, SaveR7       ;Loads current PC
RET                 ;Returns back to main loop
 
SKIPI_POP           ;Flag to skip to if not a number    
ST R0, SaveR0       ;Store R0 in a memory address
JSR POP             ;Pop first number assuming we have an operator
ADD R4, R0, #0      ;Shift popped number into R4
ADD R5, R5, #0      ;Check for underflow
BRp PRINT_INVALID   ;If underflow, print error
JSR POP             ;Pop second number assuming we have an operator
ADD R3, R0, #0      ;Shift popped number into R3
ADD R5, R5, #0      ;Check for underflow
BRp PRINT_INVALID   ;If underflow, print error
LD R0, SaveR0       ;Load R0 from the memory address in which we stored previously
 
LD R6, MULT_ASCII   ;Load ascii value for multiplication sign
NOT R6, R6          ;Negate R6
ADD R6, R6, #1  
ADD R6, R6, R0      ;Subtract to check if multiplication sign
BRnp SKIP_MULT      ;If not this sign, skip over
JSR MUL             ;Call MUL Subroutine to perform caclulation
LD R7, SaveR7       ;Load current PC
RET                 ;Returns from subroutine
SKIP_MULT      
 
LD R6, DIV_ASCII    ;Load ascii value for division sign
NOT R6, R6          ;Negate R6
ADD R6, R6, #1  
ADD R6, R6, R0      ;Subtract to check if division sign
BRnp SKIP_DIV       ;If not this sign, skip over
JSR DIV             ;Call DIV Subroutine to perform caclulation
LD R7, SaveR7       ;Load current PC
RET                 ;Returns from subroutine
SKIP_DIV        
 
LD R6, PLUS_ASCII   ;Load ascii value for plus sign
NOT R6, R6          ;Negate R6
ADD R6, R6, #1
ADD R6, R6, R0      ;Subtract to check if plus sign
BRnp SKIP_ADD       ;If not this sign, skip over
JSR PLUS            ;Call PLUS Subroutine to perform caclulation
LD R7, SaveR7       ;Load current PC
RET                 ;Returns from subroutine
SKIP_ADD
 
LD R6, MINUS_ASCII  ;Load ascii value for minus sign
NOT R6, R6          ;Negate R6
ADD R6, R6, #1
ADD R6, R6, R0      ;Subtract to check if minus sign
BRnp SKIP_MINUS     ;If not this sign, skip over
JSR MIN             ;Call MIN Subroutine to perform caclulation
LD R7, SaveR7       ;Load current PC
RET                 ;Returns from subroutine
SKIP_MINUS  
 
LD R6, EXP_ASCII    ;Load ascii value for exponent sign
NOT R6, R6          ;Negate R6
ADD R6, R6, #1
ADD R6, R6, R0      ;Subtract to check if exponent sign
BRnp SKIP_EXP       ;If not this sign, skip over
JSR EXP             ;Call EXP Subroutine to perform caclulation
LD R7, SaveR7       ;Load current PC
RET                 ;Returns from subroutine
SKIP_EXP
 
 
BRnzp PRINT_INVALID
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
PLUS    
;your code goes here
ST R7, PlusSaveR7   ;Stores current PC
ADD R0, R3, R4      ;Adding R3 and R4
JSR PUSH            ;Push onto stack
LD R7, PlusSaveR7   ;Loads current PC
RET                 ;Returns from subroutine
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN
;your code goes here
ST R7, MinusSaveR7  ;Stores current PC
NOT R4, R4          ;inverting R4 so we can compute R3-R4
ADD R4, R4, #1      ;Add 1 to R4 to make it negative
ADD R0, R3, R4      ;Add R3 and (-R4) and storing in R0
JSR PUSH            ;Push onto stack
LD R7, MinusSaveR7  ;Load Current PC
RET                 ;Returns from subroutine
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MUL
;your code goes here
ST R7, MultSaveR7   ;Loads current PC
ADD R0, R3, #0      ;Putting one of the inputs into R0
ADD R4, R4, #0      ;restate R4 so we can check if negative
BRn SWITCH          ;if R4 is negative, go to switch
ADD R4, R4, #-1     ;Using one of the inputs as a counter, decrement R4
MUL_START1          ;Label representing when R3R4 signs are ++, -+
ADD R3, R3, R0      ;Add R3 to itself once
ADD R4, R4, #-1     ;Using one of the inputs as a counter, decrement R4
BRnp MUL_START1     ;Loop as specified by the input
ADD R0, R3, #0      ;Move calculated output into output register R0
BRnzp MUL_DONE      ;Branch to the end of subroutine
SWITCH              ;make R4 positive so we can use it as a counter when multiplying
ADD R4, R4, #1      ;Using one of the inputs as a counter, decrement R4
NOT R4, R4          ;Invert R4
ADD R4, R4, #1      ;Add 1 to R4 to make R4 = -R4
MUL_START2          ;Label representing when R3R4 signs are --, +-
ADD R3, R3, R0      ;Add R3 to itself once
ADD R4, R4, #-1     ;Using one of the inputs as a counter, decrement R4
BRnp MUL_START2     ;loop as specified by the input
NOT R3, R3          ;we invert since our output will change signs to something not the same as the initial input R3
ADD R3, R3, #1      ;Add 1 to R3 to make R3 = -R4
ADD R0, R3, #0      ;Move calculated output into output register R0
MUL_DONE
JSR PUSH            ;Push onto stack
LD R7, MultSaveR7   ;Load current PC
RET                 ;Returns from subroutine
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV
;your code goes here
ST R7, DivSaveR7    ;Loads current PC
AND R0, R0, #0      ;clear R0
NOT R4, R4          ;negate R4
ADD R4, R4, #1
DIV_LOOP
ADD R0, R0, #1      ;add 1 to quotient
ADD R3, R3, R4      ;subtract the divisor from current dividend
BRzp DIV_LOOP       ;loop until dividend is less than 0
ADD R0, R0, #-1     ;compensate for going over quotient once
NOT R4, R4          ;negate R4
ADD R4, R4, #1  
ADD R1, R3, R4      ;Storing remainder in R1
 
JSR PUSH            ;Push onto stack
LD R7, DivSaveR7    ;Load current PC
RET                 ;Returns from subroutine
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
;your code goes here
ST R7, ExpSaveR7    ;Loads current PC
AND R0, R0, #0      ;Clear R0
 
AND R5, R5, #0      ;initialize R5
ADD R5, R4, #0      ;Set R5 equal to R4 to use as loop counter to see how many times we multiply base by itself
ADD R5, R5, #-2     ;decrement R5 once to correct for exponent correctly
BRn EXP_ONE         ;if exponent is 1 (n^1) = n
ADD R4, R3, #0      ;make both multiplication values the same
MULT_LOOP
ST R4, EXP_SaveR4   ;store R4 in memory before JSR
ST R5, EXP_SaveR5   ;store R5 in memory before JSR
JSR MUL             ;perform multiplication subroutine
JSR POP
LD R4, EXP_SaveR4   ;restore R4 from memory
LD R5, EXP_SaveR5   ;restore R5 from memory
AND R3, R3, #0      ;Clear R3
 
ADD R3, R0, #0      ;Load the result for MUL subrountine to R3
ADD R5, R5, #-1     ;Decrement R5 Counter
BRzp MULT_LOOP
AND R0, R0, #0      ;clearing R0 again since we used it in JSR MUL
ADD R0, R3, #0      ;store R3 in R0 as output
BRnzp EXP_DONE      ;branch to end of subroutine
 
EXP_ONE
ADD R0, R3, #0      ;exponent is one so output is the same as the base  
 
EXP_DONE
JSR PUSH            ;Push onto stack
LD R7, ExpSaveR7    ;Load current PC
RET                 ;Returns from subroutine
 
EXP_SaveR4  .BLKW #1    ;Address to save R4
   
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH    
    ST R3, PUSH_SaveR3  ;save R3
    ST R4, PUSH_SaveR4  ;save R4
    AND R5, R5, #0      ;
    LD R3, STACK_END    ;
    LD R4, STACk_TOP    ;
    ADD R3, R3, #-1     ;
    NOT R3, R3          ;
    ADD R3, R3, #1      ;
    ADD R3, R3, R4      ;
    BRz OVERFLOW        ;stack is full
    STR R0, R4, #0      ;no overflow, store value in the stack
    ADD R4, R4, #-1     ;move top of the stack
    ST R4, STACK_TOP    ;store top of stack pointer
    BRnzp DONE_PUSH     ;
OVERFLOW
    ADD R5, R5, #1      ;
DONE_PUSH
    LD R3, PUSH_SaveR3  ;
    LD R4, PUSH_SaveR4  ;
    RET                
 
 
PUSH_SaveR3 .BLKW #1    ;
PUSH_SaveR4 .BLKW #1    ;
 
 
;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
 
POP
    ST R3, POP_SaveR3   ;save R3
    ST R4, POP_SaveR4   ;save R3
    AND R5, R5, #0      ;clear R5
    LD R3, STACK_START  ;
    LD R4, STACK_TOP    ;
    NOT R3, R3      ;
    ADD R3, R3, #1      ;
    ADD R3, R3, R4      ;
    BRz UNDERFLOW       ;
    ADD R4, R4, #1      ;
    LDR R0, R4, #0      ;
    ST R4, STACK_TOP    ;
    BRnzp DONE_POP      ;
UNDERFLOW
    ADD R5, R5, #1      ;
DONE_POP
    LD R3, POP_SaveR3   ;
    LD R4, POP_SaveR4   ;
    RET
 
 
POP_SaveR3  .BLKW #1    ;
POP_SaveR4  .BLKW #1    ;
STACK_END   .FILL x3FF0 ;
STACK_START .FILL x4000 ;
STACK_TOP   .FILL x4000 ;
 
EQUAL_ASCII .FILL #61   ;Ascii of Equal sign to be loaded into memory address  
PLUS_ASCII  .FILL #43   ;Ascii of plus sign to be loaded into memory address
MINUS_ASCII .FILL #45   ;Ascii of minus sign to be loaded into memory address
MULT_ASCII  .FILL #42   ;Ascii of asterisk sign to be loaded into memory address
DIV_ASCII   .FILL #47   ;Ascii of forward slash sign to be loaded into memory address
EXP_ASCII   .FILL #94   ;Ascii of caret sign to be loaded into memory address
SPACE_ASCII .FILL #32   ;Ascii of space to be loaded into memory address
ZER0_ASCII  .FILL #48   ;Ascii of the number zero to be loaded into memory addess
NINE_ASCII  .FILL #58   ;Ascii of the number nine to be loaded into memory address
 
NUM_OFFSET  .FILL x0030 ;memory address stores number offset
 
SaveR7      .BLKW #1    ;Memory address to save location of R7 to return main loop
PlusSaveR7  .BLKW #1    ;Memory address to save location of R7 to return Evaluate subroutine
MinusSaveR7 .BLKW #1    ;Memory address to save location of R7 to return Evaluate subroutine
MultSaveR7  .BLKW #1    ;Memory address to save location of R7 to return Evaluate subroutine
DivSaveR7   .BLKW #1    ;Memory address to save location of R7 to return Evaluate subroutine
ExpSaveR7   .BLKW #1    ;Memory address to save location of R7 to return Evaluate subroutine
EXP_SAVER5  .BLKW #1    ;Memory address to save location of R7 to return Evaluate subroutine
 
SaveR0      .BLKW #1    ;Memory address to save R0 to later load
 
INVALID_OUT .STRINGZ "Invalid Expression" ;Value of string to be loaded when there is an invalid expression
 
 
 
 
.END
