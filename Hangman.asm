TITLE Test2.asm
;===================================================================================
; Author:  Tobby Lie
; Date:  9 April 2018
; Description:  TEST 2 Simple game of Hangman
;
; Last updated: 4/10/18 8:40PM
; ====================================================================================

Include Irvine32.inc 

; ====================================================================================
;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
; ====================================================================================
.data
; ====================================================================================

anonWord byte 13d dup(0)						 ;// this is to hold the mixture of underscores and letters
choice dword 0									 ;// to hold choice  
currentWord byte 13d dup(0)						 ;// holds current random word
sizeOfWord dword 0								 ;// holds size of random word
againMessage byte "Do you wish to play again? (Y/N) ", 0h	;// messaged for if you want to play again
errormessage byte "You have entered an invalid option. Please try again.", 0h			;// Error message for invalid option input
invalidOptionInput byte "Invalid input! Your input must be a single letter. Try again." , 0h	;// message for input larger than a character 
emptyOptionInput byte "Invalid input! You did not input a character, try again: " , 0h		;// message for invalid empty input
invalid byte "Invalid input! Try again!", 0h	 ;// general invalid input message
useroption byte 4d dup(0)						 ;// holds user option, length 4d to allow checking for input larger than a single character
thankYou byte    '===============================', 0Ah, 0Dh,		;// Thank you for playing message
				 '*   THANK YOU FOR PLAYING!	*', 0Ah, 0Dh,
				 '===============================', 0h
winCounter byte 0								 ;// counts number of wins
lossCounter byte 0								 ;// counts number of losses
gameCounter byte 0								 ;// counts games played
viewStats byte "Would you like to view your game stats? (Y/N) ", 0h		;// would you like to view game stats?
playGame byte "Would you like to play the game? (Y/N) ", 0h		;// play or quit?

introMessage byte 'WELCOME TO HANGMAN', 0Ah, 0Dh,		;// intro message for game
'=================', 0Ah, 0Dh,
'Rules of the Game:', 0Ah, 0Dh,
'* You will be given a word to guess', 0Ah, 0Dh,
'* You will have 10 chances to guess the word letters', 0Ah, 0Dh,
'* 3 chances to guess the word as a whole', 0Ah, 0Dh, 
'* After you run out of letter chances you still have', 0Ah, 0Dh,
'your remaining word chances', 0h
; ====================================================================================
; ====================================================================================
.code
; ====================================================================================
main PROC
; ====================================================================================
call randomize									 ;// seed random
; ====================================================================================
gameAgain:										 ;// loop for playing game over again
										
call ClearRegisters								 ;// clears registers

call clrscr					
; ====================================================================================
mov edx, offset introMessage					;// print intro message with basic rules of game
call writeString
call crlf
call crlf
call waitmsg
call clrscr
pop edx
; ====================================================================================
optionAgain3:									;// ask user if they would like to play game or not
 
call clrscr

mov edx, offset playGame						;// play game?
call writeString

mov edx, offset userOption					    ;// get user input
mov ecx, sizeof userOption
call readString
mov al, byte ptr [edx]

cmp al, 0										;// check for empty input
jne checkNext3

mov edx, offset emptyOptionInput				;// input is empty
call writestring
call crlf
call waitmsg
jmp optionAgain3

checkNext3:
movzx ecx, byte ptr [edx + 1]
cmp ecx, 0
je nowCheckOption3								;// input is not empty or too large

mov edx, offset invalidOptionInput				;// input is not a single character
call writestring
call crlf
call waitmsg
jmp optionAgain3

nowCheckOption3:

call lowerCaseChar								;// convert character to lowercase

cmp al, 'y'										;// check if input is y or n or otherwise
je begin
cmp al, 'n'
je endItAll										;// user does not want to play game
mov edx, offset errormessage
call writestring
call crlf
call waitmsg
jmp optionAgain3

begin:											;// begin the game
; ====================================================================================
call ClearRegisters

mov edx, offset currentWord						;// randomly generate the random word for the game
call RandomWord
mov sizeOfWord, esi

mov ebx, offset currentWord						;// prepare registers for game
mov esi, sizeOfWord
mov edx, offset anonWord
call GameLoop									;// this function handles all gameplay, function calls are made within this function in order to control game play
inc gameCounter	
cmp edi, 0
jne Win											;// determine if the game resulted in a win or loss, game counter incremented either way
inc lossCounter
Win:
cmp edi, 1
jne notWin
inc winCounter
notWin:

mov choice, eax
												
mov eax, offset currentWord						;// after a game is played, the strings used for the random string and string of underscores need to be cleared to be used for a potential next game
mov ebx, offset anonWord
call clearStrings

call waitmsg
; ====================================================================================
optionAgain:									;// determine if user wants to play again

call clrscr

mov edx, offset againMessage					;// do you want to play again?
call writeString

mov edx, offset userOption						;// get input
mov ecx, sizeof userOption
call readString
mov al, byte ptr [edx]

cmp al, 0
jne checkNext

mov edx, offset emptyOptionInput				;// empty string inputted
call writestring
call crlf
call waitmsg
jmp optionAgain

checkNext:
movzx ecx, byte ptr [edx + 1]
cmp ecx, 0
je nowCheckOption

mov edx, offset invalidOptionInput				;// string inputted too large
call writestring
call crlf
call waitmsg
jmp optionAgain

nowCheckOption:

call lowerCaseChar								;// convert char to lower case

cmp al, 'y'										;// determine if user input was y or n or otherwise
je gameAgain
cmp al, 'n'
je endItAll
mov edx, offset errormessage
call writestring
call crlf
call waitmsg
jmp optionAgain
; ====================================================================================
endItAll:										;// end game loop
	
call clrscr
mov edx, offset thankYou
call writeString	
call crlf					
call waitmsg
exit
; ====================================================================================
main ENDP
; ====================================================================================
;// Procedures
; ====================================================================================
;// EXTRA CREDIT
GameStats proc
;// Description:  Displays information regarding games played, games won, and games lost
;// Requires:  eax, ebx, edx
;// Returns:  nothing but stats are displayed
.data
gamesPlayed byte "Games played: ", 0h
gamesWon byte "Games won: ", 0h
gamesLost byte "Games lost: ", 0h
stats byte 'GAME STATS', 0Ah, 0Dh, 
		   '==========', 0h
.code
;// ---------------------------------------------------------------------------------
mov edx, offset stats							;// stats title				
call writeString
call crlf
;// ---------------------------------------------------------------------------------
mov edx, offset gamesPlayed						;// display games played info
call writestring
push eax
movzx eax, bl
call writeDec
call crlf
pop eax
;// ---------------------------------------------------------------------------------
mov edx, offset gamesWon						;// games won info
call writestring
push eax
movzx eax, ah
call writeDec
call crlf
pop eax
;// ---------------------------------------------------------------------------------
mov edx, offset gamesLost						;// games lost info
call writeString
push eax
movzx eax, al
call writeDec
call crlf
pop eax
;// ---------------------------------------------------------------------------------
call waitmsg
ret
GameStats endp
; ====================================================================================
clearStrings proc
;// Description:  Clear string in which offset is in edx
;// Requires:  eax, edx
;// Returns:  nothing but string will be cleared
;// ---------------------------------------------------------------------------------
mov edx, eax				;// will have offset of currentWord
mov ecx, 14d
call clearStrEDX			
;// ---------------------------------------------------------------------------------
mov edx, ebx				;// will have offset of anonWord
mov ecx, 14d
call clearStrEDX
;// ---------------------------------------------------------------------------------
ret
clearStrings endp
; ====================================================================================
lowerCaseChar proc
;// Description:  converts a single character to lower case
;// Requires:  eax
;// Returns:  nothing but character will be converted to lower case
cmp al, 7ah
jbe nextCheck				;// check if character is not lowercase
nextCheck:
cmp al, 61h
jae canStop1

add al, 20h					;// if not lower case then add 20h to letter

canStop1:					;// if all checks out then can leave function
ret
lowerCaseChar endp
; ====================================================================================
clearStrEDX proc uses esi
;// Description:  clears the string edx points to 
;// Requires:  edx esi ecx
;// Returns:  string edx points to cleared out
mov esi, 0
clearedxstr:				;// loop through every single element of string and fill with 0
mov byte ptr [edx+esi], 0
inc esi
loop clearedxstr
ret
clearStrEDX endp
; ====================================================================================
checkAnonMatch proc
;// Description:  goes through current string and sees if there are any matches with 
;// user input and if there are, set edi to -1
;// Requires:  eax, edx, ecx, esi, edi
;// Returns:  nothing but edi may or may not be updated
;// ---------------------------------------------------------------------------------
mov ecx, esi				;// prepare registers for loop
dec ecx
mov edi, 0
push eax
push esi
mov eax, 0
mov esi, 0
;// ---------------------------------------------------------------------------------
L1:							;// go through currentWord and find any matches with word inputted
mov al, byte ptr [ebx + edi]
mov ah, byte ptr [edx + edi]
cmp al, ah
jne noMatch
inc esi
noMatch:
inc edi
loop L1
mov edi, esi
pop esi
pop eax
;// ---------------------------------------------------------------------------------
mov ecx, esi				;// if there is a perfect match, set edi to -1
dec ecx
cmp edi, ecx
jne finish
mov edi, -1d
finish:
;// ---------------------------------------------------------------------------------
ret
checkAnonMatch endp
; ====================================================================================
compareLetterGuess proc
;// Description:  goes through current string and sees if there are any matches with 
;// user input and if there are, replace underscore with that character
;// Requires:  edi, eax, ebx, edx
;// Returns:  nothing but underscore string may or may not be updated
mov edi, 0
runThrough:					;// loop through and check if there are any elements in currentWord that matches with user inputted char
mov ah, 0
mov ah, byte ptr [ebx + edi]
cmp ah, al
jne moveon
mov byte ptr [edx + edi], al
moveon:
inc edi
loop runThrough				;// will loop through 13 times, it does not matter if comparison is done on null characters

ret
compareLetterGuess endp
; ====================================================================================
GuessLetter proc
;// Description:  ask user for input of a letter to guess with
;// Requires:  edx, ecx, eax
;// Returns:  al with char input
;// ---------------------------------------------------------------------------------
.data
guessLetterPrompt byte "Guess a letter: ", 0h
letterInput byte 4 dup(0)					;// 4 to see if user inputs more than one letter
invalidLetterInput byte "Invalid input! Your input must be a single letter. Try again." , 0h
emptyLetterInput byte "Invalid input! You did not input a character, try again: " , 0h
.code
;// ---------------------------------------------------------------------------------
push edx
push ecx
;// ---------------------------------------------------------------------------------
inputLetterAgain:							;// validation loop for input letter

mov edx, offset guessLetterPrompt
call writeString

mov edx, offset letterInput
mov ecx, sizeof letterInput
call readString
mov al, byte ptr [edx]

cmp al, 0
jne check2

mov edx, offset emptyLetterInput
call writestring

call crlf
jmp inputLetterAgain
;// ---------------------------------------------------------------------------------
check2:
movzx ecx, byte ptr [edx + 1]				;// check for valid input
cmp ecx, 0
je goAhead

mov edx, offset invalidLetterInput

call writestring
call crlf
jmp inputLetterAgain

goAhead:
;// ---------------------------------------------------------------------------------
cmp al, 7ah									;// convert char to lower case
jbe nextCheck
nextCheck:
cmp al, 61h
jae canStop

add al, 20h

canStop:
pop ecx
pop edx
;// ---------------------------------------------------------------------------------
ret
GuessLetter endp
; ====================================================================================
lowerCase proc uses edx ebx
;// Description:  Convert all elements of string to lower case
;// Requires:  edx  ecx esi 
;// Returns:  edx will have the offset of the original string but now with lower case
mov esi, 0
L2:							;// Loop through all string elements and identify strings that are not lower case
mov al, byte ptr [edx+esi]
cmp al, 41h					;// if element is not a letter then skip over it
jb keepgoing
cmp al, 5ah
ja keepgoing
or al, 20h					;//could use add al, 20h
mov byte ptr [edx+esi], al
keepgoing:
inc esi
loop L2
ret
lowerCase endp
; ====================================================================================
GuessWord proc
;// Description:  Ask user for input of a word to guess random word
;// Requires:  edx  ecx esi 
;// Returns:  edx will have the offset of the original string but now with lower case
;// ---------------------------------------------------------------------------------
.data
guessWordPrompt byte "Guess the word: ", 0h
wordInput byte 13d dup(0)
emptyWord byte "You inputted an empty string! Please try again: ", 0h
.code
;// ---------------------------------------------------------------------------------
push edx
push ecx
push eax
push esi

mov ecx, 13d				;// set up for looping
mov edx, offset wordInput
call clearStrEDX			;// clear wordInput
;// ---------------------------------------------------------------------------------
inputAgain:					;// validation loop
mov edx, offset guessWordPrompt
call writestring

mov edx, offset wordInput
mov ecx, sizeof wordInput
call readString

cmp eax, 0
jne noWorries
mov edx, 0
mov edx, offset emptyWord
call writeString
call crlf
jmp inputAgain

noWorries:
;// ---------------------------------------------------------------------------------
call lowerCase				;// convert entire string to lower case
;// ---------------------------------------------------------------------------------
mov ecx, 13d				;// set up for looping
mov eax, 0
mov edi, 0
mov esi, 0
;// ---------------------------------------------------------------------------------
compare:					;// compare string inputted to game string and see if there is amatch
mov al, [ebx + edi]
mov ah, [edx + edi]
cmp al, ah
jne nextLoop
inc esi
nextLoop:
inc edi
loop compare
mov edi, esi

pop esi
pop eax
pop ecx
pop edx

cmp edi, 12d
jne leaveProc
mov edi, -1					;// if there is a match, set edi to -1
leaveProc:
;// ---------------------------------------------------------------------------------
ret
GuessWord endp
; ====================================================================================
underScoreFill proc
;// Description:  fill anonString with underscores
;// Requires:  edx  ecx esi 
;// Returns:  nothing but string will be filled with underscores
.data
underScore byte "_"
.code
mov edi, 0
dec ecx
fill:						;// fill loop
mov byte ptr [edx + edi], "_"
inc edi
loop fill

ret
underScoreFill endp 
; ====================================================================================
GameLoop proc
;// Description:  This function will control all gameplay and make function calls within itself
;// Requires:  All registers 
;// Returns:  edi will return the status representing win or loss of game
;// ---------------------------------------------------------------------------------
.data
choicePrompt byte "Do you wish to guess a letter or the whole word: ( 1 for letter 2 for word ) ", 0h	;// what would you like to do?
invalidInput byte "Invalid input! Please try again: ( 1 for letter 2 for word ) ", 0h	;// general invalid input statement
wordPrompt1 byte "Word = ", 0h		;// 3 parts to print line with underscores
wordPrompt2 byte " ( ", 0h
wordPrompt3 byte " letter guesses left )", 0h
guessesLeft dword 10d				;// number of letter guesses left
wordGuessesLeft dword 3d			;// number of word guesses left
victoryMessage byte "That is correct. You win.", 0h		;// you won!
outOfLetterGuesses byte "You are out of letter guesses. You have ", 0h		;// you are out of letter guesses but may still have word guesses, 2 parts
outOfLetterGuesses2 byte " word guess(es).", 0h		
outOfWordGuesses byte "You are out of word guesses. You have lost.", 0h		;// you are out of word guesses, you lost!
noMoreLetter dword 0				;// flag for out of letter guesses
noMoreWord dword 0					;// flag for out of word guesses
incorrectWord1 byte "That is incorrect - ", 0h	;// incorrect word prompt, 2 parts
incorrectWord2 byte " word guess(es) remaining", 0h
optionChoice byte 2d dup(0)			;// holds user input for option choice
.code
;// ---------------------------------------------------------------------------------
mov guessesLeft, 10d				;//set up for game, need to reset every time game is played
mov wordGuessesLeft, 3d
mov noMoreLetter, 0
mov noMoreWord, 0
;// ---------------------------------------------------------------------------------
mov ecx, esi						;// fill anonWord with underscores
mov edi, 0
call underScoreFill
;// ---------------------------------------------------------------------------------
again:								;// keep playing game until loss or win

cmp guessesLeft, 0
jne continue
push edx							;// if no more letter guesses, need to notify user
push eax
mov edx, offset outOfLetterGuesses
call writestring
call crlf
mov eax, wordGuessesLeft
call writeDec
mov edx, offset outOfLetterGuesses2
call writeString
mov noMoreLetter, -1d
pop eax
pop edx
call crlf
call waitmsg
continue:

cmp wordGuessesLeft, 0				;// if no word guesses left, need to notif user and also exit funct because it means you have lost
jne continue2
call clrscr
mov noMoreWord, -1d
push edx
mov edx, offset outOfWordGuesses
call writestring
pop edx
mov edi, 0							;// set edi to 0 to show loss resulted
call crlf
jmp endFunct
continue2:

call clrscr

push edx
mov edx, offset wordPrompt1			;// display anonWord string with possible guessed letters
call writestring
pop edx

mov edi, 0
mov ecx, esi
displayAnon:
mov al, byte ptr [edx + edi]
call writeChar
mov al, " "
call writeChar
inc edi
loop displayAnon

cmp guessesLeft, 10					 ;// if player has full letter guesses then no need to show how many letter guesses left
jae fullGuesses
push edx 
push eax
mov edx, offset wordPrompt2
call writeString
mov eax, guessesLeft
call writeDec
mov edx, offset wordPrompt3
call writestring
pop eax
pop edx
fullGuesses:

push edx					 	   	;// format cursor for display
mov dh, 2
call gotoxy
pop edx

push edx
mov edx, offset choicePrompt		;// prompt user for what they would like to guess for
call writeString
pop edx

call readHex						;// get input and compare to possibilities
cmp eax, 1
jb errorPortion
cmp eax, 2
ja errorPortion
jmp over 

errorPortion:						;// error check
push edx
call crlf
mov edx, offset invalidInput
call writeString
call crlf
call waitmsg
call crlf

pop edx
jmp again

over:

cmp eax, 1							;// if no more letters then need to set flag
jne nextGuess
cmp noMoreLetter, -1d
jne goToRest
jmp again
goToRest:
dec guessesLeft						;// decrement number of guesses left
call GuessLetter					;// get letter guess input
mov ecx, esi
call compareLetterGuess
call checkAnonMatch
cmp edi, -1d						;// if  match then set edi to represent that
je endFunct
jmp again

nextGuess:
cmp noMoreWord, -1d					;// if out of word guesses set flag
jne goToRest2
push edx
mov edx, offset outOfWordGuesses	;// notify user out of word guesses
call writestring
pop edx
call crlf
call waitmsg
mov edi, 0							;// edi returns 0 for a loss
jmp endFunct
goToRest2:
dec wordGuessesLeft					;// decrement word guesses
call GuessWord
cmp edi, -1
je endFunct
push edx
push eax
mov edx, offset incorrectWord1		;// tell user the word guess is incorrect
call writestring
mov eax, wordGuessesLeft
call writeDec
mov edx, offset incorrectWord2
call writestring
call crlf
call waitmsg
call crlf
pop eax
pop edx

jmp again
;// ---------------------------------------------------------------------------------
endFunct:
cmp edi, -1d						;// if edi is set to -1 then a victory has been achieved
jne nope
call crlf
mov edx, offset victoryMessage
mov edi, 1d							;// edi returns 1 if won
call writestring
call crlf
nope:
ret
GameLoop endp
; ====================================================================================
copyStrEBXtoEDX proc
;// Description:  copy string in ebx to edx 
;// Requires:  eax ebx esi ecx - edx must also be cleared
;// Returns:  edx now containing string of ebx
mov esi, 0
copy:						;// loop through every element of ebx and then copy to edx
mov al, byte ptr [ebx+esi]
mov byte ptr [edx+esi], al
inc esi
loop copy
ret
copyStrEBXtoEDX endp
; ====================================================================================
RandomWord proc
;// Description:  Randomly chooses word for game out of list of words
;// Requires:  ebx, ecx, edx
;// Returns:  randomly chosen word in offset of currentWord in edx
.data
;// ---------------------------------------------------------------------------------
;// Strings
String0 byte "kiwi", 0h
String1 byte "canoe", 0h
String2 byte "doberman", 0h
String3 byte "puppy", 0h
String4 byte "banana", 0h
String5 byte "orange", 0h
String6 byte "frigate", 0h
String7 byte "ketchup", 0h
String8 byte "postal", 0h
String9 byte "basket", 0h
String10 byte "cabinet", 0h
String11 byte "mutt", 0h
String12 byte "machine", 0h
String13 byte "mississippian", 0h
String14 byte "destroyer", 0h
String15 byte "zoomies", 0h
String16 byte "body", 0h
String17 byte "syzygy", 0h			;// three chosen words
String18 byte "ephemeral", 0h
String19 byte "facetious", 0h
randVal dword 0
;// ---------------------------------------------------------------------------------
.code
;// ---------------------------------------------------------------------------------
call Random32			;// randomly generate integer
;// ---------------------------------------------------------------------------------
push edx				;// divide generated number
mov edx, 0
mov ebx, 20d
div ebx
;// ---------------------------------------------------------------------------------
mov randVal, edx		;// user remainder to choose string
pop edx
;// ---------------------------------------------------------------------------------
cmp randVal, 0			;// use compare statements to choose a string and copy it into currentWord
jne str1
mov ecx, lengthof String0
mov ebx, offset String0
call copyStrEBXtoEDX
str1:
cmp randVal, 1
jne str2
mov ecx, lengthof String1
mov ebx, offset String1
call copyStrEBXtoEDX
str2:
cmp randVal, 2
jne str3
mov ecx, lengthof String2
mov ebx, offset String2
call copyStrEBXtoEDX
str3:
cmp randVal, 3
jne str4
mov ecx, lengthof String3
mov ebx, offset String3
call copyStrEBXtoEDX
str4:
cmp randVal, 4
jne str5
mov ecx, lengthof String4
mov ebx, offset String4
call copyStrEBXtoEDX
str5:
cmp randVal, 5
jne str6
mov ecx, lengthof String5
mov ebx, offset String5
call copyStrEBXtoEDX
str6:
cmp randVal, 6
jne str7
mov ecx, lengthof String6
mov ebx, offset String6
call copyStrEBXtoEDX
str7:
cmp randVal, 7
jne str8
mov ecx, lengthof String6
mov ebx, offset String6
call copyStrEBXtoEDX
str8:
cmp randVal, 8
jne str9
mov ecx, lengthof String8
mov ebx, offset String8
call copyStrEBXtoEDX
str9:
cmp randVal, 9
jne str10
mov ecx, lengthof String9
mov ebx, offset String9
call copyStrEBXtoEDX
str10:
cmp randVal, 10
jne str11
mov ecx, lengthof String10
mov ebx, offset String10
call copyStrEBXtoEDX
str11:
cmp randVal, 11
jne str12
mov ecx, lengthof String11
mov ebx, offset String11
call copyStrEBXtoEDX
str12:
cmp randVal, 12
jne str13
mov ecx, lengthof String12
mov ebx, offset String12
call copyStrEBXtoEDX
str13:
cmp randVal, 13
jne str14
mov ecx, lengthof String13
mov ebx, offset String13
call copyStrEBXtoEDX
str14:
cmp randVal, 14
jne str15
mov ecx, lengthof String14
mov ebx, offset String14
call copyStrEBXtoEDX
str15:
cmp randVal, 15
jne str16
mov ecx, lengthof String15
mov ebx, offset String15
call copyStrEBXtoEDX
str16:
cmp randVal, 16
jne str17
mov ecx, lengthof String16
mov ebx, offset String16
call copyStrEBXtoEDX
str17:
cmp randVal, 17
jne str18
mov ecx, lengthof String17
mov ebx, offset String17
call copyStrEBXtoEDX
str18:
cmp randVal, 18
jne str19
mov ecx, lengthof String18
mov ebx, offset String18
call copyStrEBXtoEDX
str19:
cmp randVal, 19
jne skipOver
mov ecx, lengthof String19
mov ebx, offset String19
call copyStrEBXtoEDX

skipOver:

ret
RandomWord endp
; ====================================================================================
ClearRegisters Proc
;// Description:  Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;// Requires:  Nothing
;// Returns:  Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP
; ====================================================================================

; ====================================================================================
END main
; ====================================================================================