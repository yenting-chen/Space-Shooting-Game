TITLE asm03 homework

; 
;========================================================
; Student Name: ³¯«Û§Ê
; Student ID: 0216018
; Email: ian9696@kimo.com
;========================================================
; Instructor: Sai-Keung WONG
; Email: cswingo@cs.nctu.edu.tw
; Room: 706
; Assembly Language 
;========================================================

INCLUDE Irvine32.inc
INCLUDE	Macros.inc

.data

CaptionString	BYTE "Student Name: ³¯«Û§Ê",0
MessageString	BYTE "Welcome to Assembly Programming Village!", 0dh, 0ah, 0dh, 0ah
				BYTE "Student Name: ³¯«Û§Ê", 0dh, 0ah
				BYTE "My Student ID is 0216018", 0dh, 0ah, 0dh, 0ah
				BYTE "Control keys: f, h", 0dh, 0ah
				BYTE "Spacebar to fire", 0dh, 0ah
				BYTE "Pause key: p", 0dh, 0ah
				BYTE "ESC: quit", 0dh, 0ah, 0dh, 0ah
				BYTE "Enjoy playing!", 0

WinCaption		BYTE	"Game Message", 0
WinQuestion		BYTE	"Well Done!", 0dh, 0ah
				BYTE	"You are so good! Would you want to try again?", 0

LossCaption		BYTE	"Game Message", 0
LossQuestion	BYTE	"You are 2nd place...", 0dh, 0ah
				BYTE	"Would you want to try again?", 0

MainChar	BYTE	01h, 0
MainCharX	BYTE	20
MainCharY	BYTE	20
OldMainCharX	BYTE	20
OldMainCharY	BYTE	20

BulletFlag	BYTE	0
Bullet		BYTE	' ', 0
BulletX		BYTE	0
BulletY		BYTE	0
OldBulletX		BYTE	0
OldBulletY		BYTE	0

EnemySize	BYTE	6
Enemy	BYTE	' ', 0
EnemyX	BYTE	0
EnemyY	BYTE	5
OldEnemyX	BYTE	0
OldEnemyY	BYTE	5
EnemyDir	BYTE	0	; 1-down, 0-up

LifeMsg		BYTE	"Life :", 0
LifeX	BYTE	2
LifeY	BYTE	0
Life	BYTE	5
InitLife	BYTE	5

ScoreMsg	BYTE	"Score :", 0
ScoreX	BYTE	70
ScoreY	BYTE	0
Score		BYTE	0
WinScore	Byte	3

BgSymbol	BYTE	' ', 0
BgColor		DWORD	blue*16+blue

Row		byte 24
Column	byte 80

QuitFlag	BYTE	0

PauseMode	BYTE	0

DelayDuration	BYTE	50

Bell	BYTE	7, 0

.code

main PROC


	mWrite "Please enter the size of the enemy :"
	call readInt
	cmp al, 0
	je Lsizeskip
	mov EnemySize, al
Lsizeskip:
	mov al, Column
	sub al, EnemySize
	mov EnemyX, al

	call paint

	mov ebx, OFFSET CaptionString
	mov edx, OFFSET MessageString
	call MsgBox

L0:
	call handlekeyevent
	
	call handlebulletmotion
	call handleenemymotion

	call handlehitevent

	call showmainchar
	call showbullet
	call showenemy
	call showlife
	call showscore

	call performdelay

	call clearoldmainchar
	call clearoldbullet
	call clearoldenemy

	call checkscore
	call checklife

	cmp QuitFlag, 1
	je Exit0
	jmp L0
Exit0:

	INVOKE ExitProcess, 0

main ENDP


paint PROC

	mov bl, 0
	movzx ecx, MainCharY
L0:
	push ecx

	mov dl, 0
	mov dh, bl
	call GotoXY
	movzx ecx, Column
L1:
	mov eax, BgColor
	call SetTextColor
	mov edx, offset BgSymbol
	call WriteString
	loop L1

	inc bl
	pop ecx
	loop L0

	movzx ecx, Column
L2:
	mov eax, Black*16+Black
	call SetTextColor
	mov edx, offset BgSymbol
	call WriteString
	loop L2
	ret

paint ENDP


handlekeyevent PROC

	call ReadKey
	jz	L1
L5:
	cmp al, 'p'
	jne L0

	xor PauseMode, 1
	jmp L1
L0:
	cmp al, 'f'
	jne L3
	
	mov al, PauseMode
	cmp al, 1
	je Lfskip
	mov al, MainCharX
	cmp al, 1
	jle Lfskip
	dec MainCharX
	dec MainCharX
Lfskip:
	jmp L1
L3:
	cmp al, 'h'
	jne L2
	
	mov al, PauseMode
	cmp al, 1
	je Lhskip
	mov al, Column
	dec al
	dec al
	cmp al, MainCharX
	jle Lhskip
	inc MainCharX
	inc MainCharX
Lhskip:
	jmp L1
L2:	
	cmp al, ' '
	jne L4
	
	mov al, PauseMode
	cmp al, 1
	je L1
	call activatebullet
	jmp L1
L4:
	cmp al, 27
	jne L1

	mov QuitFlag, 1
	jmp L1
L1:
	ret

handlekeyevent ENDP


handlebulletmotion PROC

	mov al, PauseMode
	cmp al, 1
	je L2
	mov al, BulletY
	cmp al, 1
	jg L1
	mov BulletFlag, 0
	jmp L2
L1:
	dec BulletY
L2:
	ret

handlebulletmotion ENDP


handleenemymotion PROC

	mov al, PauseMode
	cmp al, 1
	je L4
	mov al, EnemyX
	cmp al, 0
	jle L1
	dec EnemyX
	jmp L2
L1:
	dec Life
	mov al, Column
	sub al, EnemySize
	mov EnemyX, al
L2:

	mov al, EnemyDir
	cmp al, 0
	je L3
	mov EnemyDir, 0
	dec EnemyY
	jmp L4
L3:
	mov EnemyDir, 1
	inc EnemyY
L4:
	ret

handleenemymotion ENDP


handlehitevent PROC

	mov al, EnemyY
	cmp al, BulletY
	je L0
	mov al, EnemyY
	inc al
	cmp al, BulletY
	je L1
	jmp Lexit
L1:
	mov al, EnemyDir
	cmp al, 1
	je L0
	jmp Lexit
L0:
	mov al, EnemyX
	cmp al, BulletX
	jg Lexit
	mov al, EnemyX
	add al, EnemySize
	dec al
	cmp al, BulletX
	jl Lexit

	inc Score
	mov BulletFlag, 0
	mov al, Column
	sub al, EnemySize
	mov EnemyX, al
	mov edx, offset Bell
	call WriteString
Lexit:
	ret

handlehitevent ENDP


clearoldmainchar PROC

	mov al, MainCharX
	mov OldMainCharX, al
	mov al, MainCharY
	mov OldMainCharY, al
	mov dl, OldMainCharX
	mov dh, OldMainCharY
	call Gotoxy
	mov eax, Black*16+Black
	call SetTextColor
	mov edx, offset BgSymbol
	call WriteString
	ret

clearoldmainchar ENDP


clearoldbullet PROC

	mov al, BulletX
	mov OldBulletX, al
	mov al, BulletY
	mov OldBulletY, al
	mov dl, OldBulletX
	mov dh, OldBulletY
	call Gotoxy
	mov eax, BgColor
	call SetTextColor
	mov edx, offset BgSymbol
	call WriteString
	ret

clearoldbullet ENDP


clearoldenemy PROC

	mov al, EnemyX
	mov OldEnemyX, al
	mov al, EnemyY
	mov OldEnemyY, al
	mov dl, OldEnemyX
	mov dh, OldEnemyY
	call Gotoxy
	mov eax, BgColor
	call SetTextColor
	movzx ecx, EnemySize
L1:
	mov edx, offset BgSymbol
	call WriteString
	loop L1
	ret

clearoldenemy ENDP


showmainchar PROC
	
	mov eax, green*16+green
	call SetTextColor
	mov dl, MainCharX
	mov dh, MainCharY
	call Gotoxy
	mov edx, offset MainChar
	call WriteString
	ret

showmainchar ENDP


showbullet PROC

	mov al, BulletFlag
	cmp al, 0
	je Lexit

	mov eax, yellow*16+Blue
	call SetTextColor
	mov dl, BulletX
	mov dh, BulletY
	call Gotoxy
	mov edx, offset Bullet
	call WriteString
Lexit:
	ret

showbullet ENDP


showenemy PROC

	mov eax, Red*16+Red
	call SetTextColor
	mov dl, EnemyX
	mov dh, EnemyY
	call Gotoxy
	movzx ecx, EnemySize
L1:
	mov edx, offset Enemy
	call WriteString
	loop L1

	ret

showenemy ENDP


showlife PROC
	
	mov eax, Yellow*16+Black
	call SetTextColor
	mov dl, LifeX
	mov dh, LifeY
	call Gotoxy
	mov edx, offset LifeMsg
	call WriteString
	movzx eax, Life
	call writeInt
	ret

showlife ENDP


showscore PROC
	
	mov eax, Yellow*16+Black
	call SetTextColor
	mov dl, ScoreX
	mov dh, ScoreY
	call Gotoxy
	mov edx, offset ScoreMsg
	call WriteString
	movzx eax, Score
	call writeInt
	ret

showscore ENDP


checkscore PROC

	mov al, Score
	cmp al, WinScore
	jl L1
	mov ebx, offset WinCaption
	mov edx, offset WinQuestion
	call MsgBoxAsk
	cmp eax, 6
	je L2
	mov QuitFlag, 1
	jmp L1
L2:
	call paint
	call resetparameter
L1:
	ret

checkscore ENDP


checklife PROC

	mov al, Life
	cmp al, 0
	jne L1
	mov ebx, offset LossCaption
	mov edx, offset LossQuestion
	call MsgBoxAsk
	cmp eax, 6
	je L2
	mov QuitFlag, 1
	jmp L1
L2:
	call paint
	call resetparameter
L1:
	ret

checklife ENDP


resetparameter PROC

	mov MainCharX, 20
	mov OldMainCharX, 20
	mov BulletFlag, 0
	mov BulletX, 0
	mov BulletY, 0
	mov OldBulletX, 0
	mov OldBulletY, 0
	mov al, Column
	sub al, EnemySize
	mov EnemyX, al
	mov EnemyY, 5
	mov al, EnemyX
	mov OldEnemyX, al
	mov al, EnemyY
	mov OldEnemyY, al
	mov al, InitLife
	mov Life, al
	mov score, 0
	mov PauseMode, 0
	ret

resetparameter ENDP


performdelay PROC

	movzx eax, DelayDuration
	call Delay
	ret

performdelay ENDP


activatebullet PROC

	mov al, BulletFlag
	cmp al, 1
	je Lexit
	
	mov BulletFlag, 1
	mov al, MainCharX
	mov BulletX, al
	mov al, MainCharY
	mov BulletY, al	
Lexit:
	ret

activatebullet ENDP


END main 