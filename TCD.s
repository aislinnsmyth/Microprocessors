
;Step 1: Declare N and F as integer variable.  
;Step 2: Initialize F=1.
;Step 2: Enter the value of N.  
;Step 3: Check whether N>0, if not then F=1.  
;Step 4: If yes then, F=F*N  
;Step 5: Decrease the value of N by 1 .  
;Step 6: Repeat step 4 and 5 until N=0.
;Step 7: Now print the value of F.  
;The value of F will be the factorial of N(number)

;RESULTS: When R0 is 5, R1=0x00000078, C=0
;When R0 is 14, R0=0x00000014, R1=0x4C3B2800, C=0
;When R0 is 20, R0=0x21C3677C, R1=0x82B40000, C=0
;When R0 is 30, R0=0x00000000, R1=0x00000000, C=1


	area	tcd,code,readonly
	export	__main
__main
	
	
	MOV		R0, #20				;initialise values into R0
	MOV		R2, #1				;Declare variable F, F=1
	MOV		R1, #0				;Initialise variale to 0.
	MOV		R4,	#0				;this is where the C bit is in the CSPR
	BL 		fact				;branch to the subroutine
	LDR		R7, =sum			;loading the address of sum into R7
	STR		R0, [R7, #0]		;Storing the value of R0 into the first 4 address bytes of R7
	STR		R1, [R7, #4]		;Storing the value of R1 into the last 4 address bytes of R7
	
	
fin b	fin

fact
	stmfd sp!, {LR}			;storing the registers so we dont damage the contents of them inside the subroutine
	MOV		R5, #0x00000000;
	CMP		R0, #0				;Check whether N > 0
	BEQ		done				;If equal to 0 branch down to done
	UMULL	R2, R3, R0, R2		;converts to 64 bit multiplication - treats R3 as a carry
	UMULL   R1,R4,R0,R1			;using R4 as the carry condition
	ADD     R1,R3,R1			;adding contents into R1 for the MSB
    CMP     R4,#0				;if statement to turn on the C bit
    BEQ     cFlag				; {
	MOV		R5, #0x20000000		;number stored which will turn on the C bit
	MOV		R0, #0x00000000		;if C bit is turned on move 0 to registers 0-2
	MOV		R1, #0x00000000		
	MOV		R2, #0x00000000		
    B       done
cFlag							;deals with setting and turning off the C bit
    MOV    	R5, #0x00000000	    ;setting C to 0 as no errors expected
    SUB 	R0, R0, #1			;N-1
	MSR		CPSR_f, R5			;clearing the C bit
    BL       fact  				;recursive branch
	CMP        R2,#0            ;if(R2!=0){
    BEQ        done             ;{
    MOV        R0,R1            ;moving contents of R1 to R0     
    MOV        R1,R2            ;moving contents of R2 to R1     
    MOV        R2,#0            ;putting R2 back to 0
    MSR    	   CPSR_f,R5        ;turning on the C bit			
done
	MSR		CPSR_f, R5			;turn off C bit
	ldmfd sp!,{LR}				;restore the contents of the used registers for the main program
	BX		LR					; Branch and link
	
	
	area		tcdrodata,data,readonly
nums DCD 5		;DCD is a 32 bit binary value so converts each number to 32 bit
	 DCD 14
	 DCD 20
	 DCD 30
	;UMULLS 	R4, R5, R2, R0		;using Umulls to multiply our factorials and store the least significant bits in R4 and most significant in R5, S set condition flags
		area	tcddata,data,readwrite
sum space	32		;have to be able to write to the data
	
	end