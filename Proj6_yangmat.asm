TITLE Project 6 - String Primitives and Macros     (Proj6_yangmat.asm)

; Author: Matthew Yang
; Last Modified: 12/05/2020
; OSU email address: yangmat@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: Dec. 6, 2020
; Description: Program created to practice using string primitives as well as macros by getting a
;     series of integers from the user as strings, validating and converting them to integer values 
;     before displaying them back to the user along with the sum and the average.

INCLUDE Irvine32.inc

; *************************************************************
; Name: mGetString
;
; Prompts user for input and stores the input string and bytes read in the given arguments
;
; Preconditions: uses EDX, ECX and EAX registers, but restored
;
; Receives:
; prompt    = offset to BYTE character array to display to user
; userInput = offset to BYTE character array to store the users input string
; size      = SDWORD in which to store the BYTE count of the user input
;
; returns: userInput, size
; *************************************************************
mGetString MACRO prompt:REQ, userInput:REQ, size:REQ
  PUSH  EDX
  PUSH  ECX
  PUSH  EAX

  MOV   EDX, prompt
  CALL  WriteString
  MOV   EDX, userInput
  MOV   ECX, 13
  CALL  ReadString
  MOV   size, EAX

  POP   EAX
  POP   ECX
  POP   EDX
ENDM

; *************************************************************
; Name: mDisplayString
;
; Prints the given value as a null terminated string
;
; Preconditions: uses EDX register, but restored
;
; Receives:
; displayVal = a value which will be null terminated then printed as ASCII character
;
; returns: prints value as ASCII character to console
; *************************************************************
mDisplayString MACRO displayVal:REQ
    LOCAL val
  .data
    val SDWORD ?, 0
  .code
    PUSH  EDX

    MOV   val, displayVal
    MOV   EDX, OFFSET val
    CALL  WriteString

    POP   EDX
ENDM

; Number of values to get from the user
INPUT_COUNT = 10

.data
intro1      BYTE    "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10,
                    "Written by: Matthew Yang", 13, 10, 13, 10, "Please provide ",0

intro2      BYTE    " signed decimal integers.", 13, 10, "Each number needs to be small enough ",
                    "to fit inside a 32 bit register. After you have finished inputting the raw ",
                    "numbers I will display a list of the integers, their sum, and their average ",
                    "value.", 13, 10, 13, 10, 0

prompt      BYTE    "Please enter a signed number: ", 0

retryprompt BYTE    "ERROR: You did not enter a signed number or your number was too big.", 13, 10,
                    "Please try again: ", 0

displayMsg  BYTE    "You entered the following numbers:", 13, 10, 0

sumMsg      BYTE    "The sum of these numbers is: ", 0

avgMsg      BYTE    "The rounded average is: ", 0

goodbye     BYTE    "Thanks for playing!", 13, 10, 0

comma       BYTE    ", ", 0

maxStr      BYTE    "2147483647", 0

negMaxStr   BYTE    "2147483648", 0

strVal      BYTE    13 DUP(0)

intVal      SDWORD  ?

userVals    SDWORD  INPUT_COUNT DUP(?)

sum         SDWORD  ?

average     SDWORD  ?

.code
main PROC

  ; ----------------------------------------------------------
  ; Print the introduction messages to the console
  ; ----------------------------------------------------------
  MOV   EDX, OFFSET intro1
  CALL  WriteString
  PUSH  INPUT_COUNT
  CALL  WriteVal
  MOV   EDX, OFFSET intro2
  CALL  WriteString

  ; ----------------------------------------------------------
  ; Prompt user for INPUT_COUNT number of values within the given parameters. Values will be 
  ;     validated for presence, size, as well as only containing number characters. Values will be
  ;     converted from strings to integers and stored in an SDWORD array.
  ; ----------------------------------------------------------
  MOV   ECX, INPUT_COUNT
  MOV   EDI, OFFSET userVals
_getVals:
  PUSH  OFFSET maxStr
  PUSH  OFFSET negMaxStr
  PUSH  OFFSET intVal
  PUSH  OFFSET strVal
  PUSH  OFFSET prompt
  PUSH  OFFSET retryPrompt
  CALL  ReadVal
  MOV   EAX, intVal
  CLD
  STOSD
  LOOP  _getVals
  CALL  CrLf

  ; ----------------------------------------------------------
  ; Prints a message and the users input values to the console, comma separated.
  ; ----------------------------------------------------------
  MOV   EDX, OFFSET displayMsg
  CALL  WriteString
  MOV   ESI, OFFSET userVals
  MOV   ECX, INPUT_COUNT
_printVal:
  CLD
  LODSD
  PUSH  EAX
  CALL  WriteVal
  CMP   ECX, 1
  JE    _printLoop
  MOV   EDX, OFFSET comma
  CALL  WriteString
_printLoop:
  LOOP  _printVal
  CALL  CrLf

  ; ----------------------------------------------------------
  ; Calculates the sum of all the users input values and stores the sum in an SDWORD
  ; ----------------------------------------------------------
  PUSH  OFFSET sum
  PUSH  OFFSET userVals
  PUSH  INPUT_COUNT
  CALL  CalcSum

  ; ----------------------------------------------------------
  ; Prints a message and the sum of all the users input values to the console
  ; ----------------------------------------------------------
  MOV   EDX, OFFSET sumMsg
  CALL  WriteString
  MOV   EDX, sum
  PUSH  EDX
  CALL  WriteVal
  CALL  CrLf

  ; ----------------------------------------------------------
  ; Calculates the average of all the users input values, rounded down to the nearest full integer
  ;     and stores in an SDWORD
  ; ----------------------------------------------------------
  PUSH  OFFSET average
  PUSH  sum
  PUSH  INPUT_COUNT
  CALL  CalcAverage

  ; ----------------------------------------------------------
  ; Prints a message and the rounded average of all the users input values to the console
  ; ----------------------------------------------------------
  MOV   EDX, OFFSET avgMsg
  CALL  WriteString
  MOV   EDX, average
  PUSH  EDX
  CALL  WriteVal
  CALL  CrLf

  ; ----------------------------------------------------------
  ; Prints a final goodbye message to the console
  ; ----------------------------------------------------------
  CALL  CrLf
  MOV   EDX, OFFSET goodbye
  CALL  WriteString
  CALL  CrLf

  Invoke ExitProcess, 0       ; exit to operating system
main ENDP

; *************************************************************
; Calculates the average of the given sum and count, rounding down
; Receives (from bottom to top of stack):
;     - OFFSET to an SDWORD value to store the average
;     - SDWORD value of the sum
;     - SDWORD value of count
; Returns: Prints message and sum to console
; Preconditions: Input parameters of SDWORD value of sum and another of count, offset to SDWORD to
;     store average
; Registers changed: None (all restored)
; *************************************************************
CalcAverage PROC
  PUSH  EBP
  MOV   EBP, ESP
  PUSH  EAX
  PUSH  EDX

  MOV   EAX, [EBP+12]
  CDQ
  IDIV  SDWORD PTR [EBP+8]

  MOV   EDX, [EBP+16]
  MOV   [EDX], EAX

  POP   EDX
  POP   EAX
  POP   EBP
  RET   12
CalcAverage ENDP

; *************************************************************
; Calculates the sum of the given SDWORD array
; Receives (from bottom to top of stack):
;     - OFFSET to an SDWORD value to store the sum
;     - OFFSET to an SDWORD array of values to sum
;     - SDWORD value of the number of items in the SDWORD array
; Returns: Modified output SDWORD
; Preconditions: Passed offset to an SDWORD array of values, SDWORD value of number of items in
;     the SDWORD array, offset to SDWORD to store sum
; Registers changed: None (all restored)
; *************************************************************
CalcSum PROC
  PUSH  EBP
  MOV   EBP, ESP
  PUSH  ESI
  PUSH  ECX
  PUSH  EBX

  MOV   ESI, [EBP+12]
  MOV   ECX, [EBP+8]
  MOV   EBX, 0

_sum:
  CLD
  LODSD
  ADD   EBX, EAX
  LOOP  _sum

  MOV   EAX, [EBP+16]
  MOV   [EAX], EBX

  POP   EBX
  POP   ECX
  POP   ESI
  POP   EBP
  RET   12
CalcSum ENDP

; *************************************************************
; Prompts user for input, validates that input, converts it to a signed integer and stores in the
;     given value parameter.
; Receives (from bottom to top of stack):
;     - OFFSET to a BYTE array of character representation of max value
;     - OFFSET to a BYTE array of character representation of negative max value
;     - OFFSET to an SDWORD value to store the value
;     - OFFSET to an array to store the value as a string
;     - OFFSET to a user prompt
;     - OFFSET to an error user prompt
; Returns: Validated user value in the given parameter
; Preconditions: Passed output and array offset must be type SDWORD, prompts must be offsets to BYTE
;     strings.
; Registers changed: None (all restored)
; *************************************************************
ReadVal PROC
  LOCAL bytesRead:SDWORD, convertedVal:SDWORD, isNeg:BYTE
  PUSH  EDX
  PUSH  ESI
  PUSH  EAX
  PUSH  EBX
  PUSH  EDI
  PUSH  ECX

  MOV   bytesRead, 0

  ; Prompt the user for an input value
  mGetString [EBP+12], [EBP+16], bytesRead

_start:
  MOV   isNeg, 0
  MOV   convertedVal, 0
  MOV   ESI, [EBP+16]
  MOV   ECX, bytesRead

  CMP   ECX, 0                     ; Check that input was actually given
  JE    _error

  ; ----------------------------------------------------------
  ; Check if a sign was given as part of the user input string. If so iterate ESI to the next value
  ;     after setting the isNeg indicator if necessary
  ; ----------------------------------------------------------
  CMP   BYTE PTR [ESI], 43         ; Plus sign?
  JE    _plus
  CMP   BYTE PTR [ESI], 45         ; Negative sign?
  JE    _negative
  JMP   _validate
_plus:
  ADD   ESI, 1
  DEC   ECX
  JMP   _validate
_negative:
  MOV   isNeg, 1
  ADD   ESI, 1
  DEC   ECX
  JMP   _validate

  ; ----------------------------------------------------------
  ; Validate that the input given is:
  ; - All numerical characters
  ; - Within the given limits of an SDWORD
  ; ----------------------------------------------------------
_validate:
  CMP   ECX, 10               ; Only need to check each character size if count equals max character
  JE    _checkCharSize        ;     count for an SDWORD
  JL    _checkChars
  JMP   _error

_checkCharSize:
  PUSH  ESI                   ; Preserve registers used later
  PUSH  ECX
  PUSH  EDI
  CMP   isNeg, 1              ; If negative, load negative max for comparison, otherwise load pos
  JE    _loadNeg
  MOV   EDI, [EBP+28]
  JMP   _compareChars
_loadNeg:
  MOV   EDI, [EBP+24]
_compareChars:                ; Iterate the users input string with the max value string, which can
  CLD                         ;     early out if any value is lower (OK), or higher (error)
  LODSB
  CMP   AL, [EDI]
  JL    _exitCheckSize
  JG    _validationError
  ADD   EDI, 1
  LOOP _compareChars
_exitCheckSize:
  POP   EDI
  POP   ECX
  POP   ESI

_checkChars:
  PUSH  ESI                   ; Preserve registers used later
  PUSH  ECX
_nextChar:                    ; Iterate the users input string and error if the character is not
  CLD                         ;     a number character
  LODSB
  CMP   AL, 48
  JL    _validationError
  CMP   AL, 57
  JG    _validationError
  LOOP  _nextChar
  POP   ECX
  POP   ESI
  JMP   _convert

_validationError:
  POP   EDI
  POP   ECX
  POP   ESI
  JMP   _error

  ; ----------------------------------------------------------
  ; Convert the ASCII value of the number to an integer value
  ; ----------------------------------------------------------
_convert:
  CLD
  LODSB
  SUB   AL, 48
  MOVSX EBX, AL
  MOV   EAX, convertedVal
  IMUL  EAX, 10
  MOV   convertedVal, EAX
  ADD   convertedVal, EBX
  LOOP  _convert

  CMP   isNeg, 0              ; If the input value was negative, negate the converted value
  JE    _storeVal
  NEG   convertedVal

_storeVal:
  MOV   EAX, convertedVal
  MOV   EDI, [EBP+20]
  MOV   [EDI], EAX
  JMP   _exit

  ; ----------------------------------------------------------
  ; Resets and gets another value from the user after displaying the error prompt
  ; ----------------------------------------------------------
_error:
  MOV   bytesRead, 0
  mGetString [EBP+8], [EBP+16], bytesRead
  JMP   _start

_exit:
  POP   ECX
  POP   EDI
  POP   EBX
  POP   EAX
  POP   ESI
  POP   EDX
  RET   24
ReadVal ENDP

; *************************************************************
; Procedure to display the given SDWORD integer by first converting to it's ASCII
;     representation value and then printing the value to the screen.
; Receives (from bottom to top of stack):
;     - SDWORD value to be converted and displayed
; Returns: Prints output to console.
; Preconditions: Passed value must be type SDWORD
; Registers changed: None (all restored)
; *************************************************************
WriteVal PROC
  LOCAL val:SDWORD, printZeroes:BYTE
  PUSH  EAX
  PUSH  ECX
  PUSH  EDX
  PUSH  EBX

  ; ----------------------------------------------------------
  ; Compare the value with zero in order to print the '-' sign to the console if necessary. Also if
  ;     the value equals zero, print it and early exit as no more calculation needed
  ; ----------------------------------------------------------
  MOV   EBX, [EBP+8]
  MOV   val, EBX
  CMP   val, 0
  JL    _displayNegative
  JG    _convertAbsolute
  MOV   EAX, val
  ADD   EAX, 48
  mDisplayString EAX
  JMP   _exit

_displayNegative:
  mDisplayString  45

  ; ----------------------------------------------------------
  ; As the '-' symbol has already been printed, convert to absolute (positive) value for easier
  ;     calculations
  ; ----------------------------------------------------------
_convertAbsolute:
  FILD  val
  FABS
  FISTP val

  MOV   EAX, val
  MOV   ECX, 1000000000
  MOV   printZeroes, 0

  ; ----------------------------------------------------------
  ; Displays the value from left to right, using division to calculate the current 'place' value
  ; ----------------------------------------------------------
_findNext:
  CDQ
  IDIV  ECX
  CMP   EAX, 0
  JNE   _display
  CMP   printZeroes, 0
  JE    _setupNext
_display:
  MOV   printZeroes, 1
  ADD   EAX, 48
  mDisplayString EAX
_setupNext:
  PUSH  EDX
  MOV   EAX, ECX
  CDQ
  MOV   EBX, 10               ; Divide counter by 10 in order to move to the next 'place' in the val
  IDIV  EBX
  POP   EDX
  CMP   EAX, 0
  JE    _exit
  MOV   ECX, EAX
  MOV   EAX, EDX
  JMP   _findNext

_exit:
  POP   EBX
  POP   EDX
  POP   ECX
  POP   EAX
  RET   4
WriteVal ENDP

END main
