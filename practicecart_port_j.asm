.gba

.open "KatAM_J.gba","KatAM_J_practice.gba",0x08000000 




//Defines

EntityDataP1 EQU 0x2020EE0
AREA_START EQU 0x08D86AF0
BTN_RIGHT EQU 0x10
BTN_LEFT EQU 0x20
BTN_SELECT EQU 0x4
BTN_A EQU 0x1

.org 0x08F9FFE0
	.ascii "KatAM Practice Cart"
	.db 0xf, 0x0

//Patches

.org 0x0803EAB6 //begin with 99 lives
	mov r0, #99

.org 0x0804A91E //no damage
	strb r2,[r1]

.org 0x0804F826 //make death fast
	mov r1, #0xEF

.org 0x0804F994 //no ability reset on death
	nop
.org 0x0804F9A2
	nop 
	nop
.org 0x08007F6A
	nop
	nop


.org 0x0804FFAA //don't lose lives
	sub r0, r1, #0


//Custom Code

//Function pointer to hook
.org 0x08056D8C
initChooseAbilityHook:
.dw org(InitChooseAbility)+1


.org AREA_START

.area 0x1300
.align 4

//Init Choose Ability

InitChooseAbility:
	push {r4-r7,lr}
	ldr r7, =EntityDataP1+0x103 //current ability
	ldrb r4, [r7,0x0]
	ldr r7, =EntityDataP1+0xDD //next ability
	strb r4, [r7,0x0]

	ldr r7, =EntityDataP1
	ldr r4, =org(ChooseAbility)+1
	str r4, [r7,0x78] //code pointer
	pop {r4-r7}
	pop r0
	bx r0


ChooseAbility:
	push {r4-r7,lr}

	//Show Ability Icon
	ldr r7, =0x03003AD0
	mov r4, #0x06
	strb r4, [r7,0x0]
	ldr r7, =0x03003AC0
	mov r4, 0x0C
	strb r4, [r7,0x0]

	//Restore ability (magic)
	ldr r7, =EntityDataP1+0xF //Mystery Flags
	mov r4, 0
	strb r4, [r7,0x0]

	ldr r7,=EntityDataP1+0x11A // buttons
	ldrb r4,[r7,0x0]
	cmp r4, 0x10
	beq pressright
	cmp r4, 0x20
	beq pressleft
	cmp r4, 0x04
	beq pressselect
	cmp r4, 0x01
	beq preparereturn
	b done

	pressleft:
		ldr r7,=EntityDataP1+0xDD //queued ability
		ldrb r4, [r7,0x0]

		cmp r4, 0x0
		bne no_wrap_left
		mov r4,0x1A
		strb r4, [r7,0x0]
		b updateGraphics
	no_wrap_left:
		sub r4, r4, #1
		strb r4,[r7,0]
		b updateGraphics

	pressright:
		ldr r7,=EntityDataP1+0xDD //queued ability
		ldrb r4, [r7,0x0]
		add r4, r4, #1
		cmp r4, 0x1B
		bcc no_wrap_right
		mov r4,0x0
	no_wrap_right:
		strb r4,[r7,0]
		b updateGraphics

	pressselect: 
		mov r4, #0
		ldr r7, =EntityDataP1+0x100
		strb r4,[r7,0]
		ldr r7, =0x03000514
		strb r4,[r7,0] 
		//b preparereturn


	prepareReturn:
		ldr r7, =0x02020F58
		ldr r4, =0x0806E465
		str r4, [r7,0]

		ldr r7, =0x0203AD20
		mov r4, 0x0
		str r4,[r7,0]


		ldr r0, =EntityDataP1
		ldr r5, =0x0806E465
		ldr r6, =org(chooseReturn)+1
		mov lr, r6
		push {r1-r3}
		bx r5

		done:
		pop {r4-r7}
		pop {r0}
		bx r0




updateGraphics:
	ldrb r0,[r7,0]
	ldr r5, =0x08035DD5
	ldr r6, =org(chooseReturn)+1
	mov lr, r6
	push {r1-r3}
	bx r5	



chooseReturn:
	pop {r1-r3}
	b done


.pool

.endarea

.close

//Notes from the original practice hack:

/*
@ 0x02020F58 = pointer to routine to run every frame
@            - 0x0803FEDD - default, idle
@            - 0x0805C591 - get an ability (update graphics)
@            - 0x0805C331 - mix roulette
@ 0x02020FBD = next ability
@ 0x02020FE3 = current ability
@ 0x02020FB8 = speed of mix roulette
@ 0x02020EE4 = counter for roulette image
@ 0x02020EE5 = current mix roulette image
@ 0x02020EEF = set to 0x02 to kill ability after this room
@ 0x03000514 = sprite lock if bit0 set
@ 0x03003AC0 = timer for ability image
@ 0x03003AD0 = ability image state
*/
