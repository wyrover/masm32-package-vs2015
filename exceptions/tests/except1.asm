;////////////////////////////////////////////////////////////////////////////
;//                                                                        //
;// EXCEPT1.ASM - source for Except1.Exe                                   //
;// Simple Demo of Win32 structured exception handling                     //
;// for assembler programmers                                              //
;// See Except2 for a more complex demo dealing with voluntary             //
;// stack unwinds and multiple handler levels                              //
;// COPYRIGHT NOTE - this file is Copyright Jeremy Gordon 2002             //
;//                  [MrDuck Software]                                     //
;//                - e-mail: JG@JGnet.co.uk                                //
;//                - www.GoDevTool.com                                     //
;// LEGAL NOTICE - The author accepts no responsibility for losses         //
;// of any type arising from this file or anything wholly or in part       //
;// created from it                                                        //
;//                                                                        //
;////////////////////////////////////////////////////////////////////////////
;
;This program only uses Windows message boxes, which is why there is no
;message loop.
;The program has two exception handlers.  The final exception handler
;is created first, then a procedure is called which has its own 
;per-thread exception handler, capable of swallowing an exception.  
;This it does at the option of the user.
;If the user decides to swallow the exception, the program would be able
;to continue to run, but actually in this case it terminates normally.
;If the user decides that the exception should not be swallowed by the
;handler, then the final exception handler is called (on the way to 
;program closure).  In real life, this handler would be responsible for
;completing logs and records, closing file handles, releasing memory etc.
;But before the program finally finishes, the system calls the per-thread
;exception handler in case there is more clearing up to do in that
;particular stack frame using local data.  This is the system unwind.
;
;Written for GoAsm (Jeremy Gordon). Assemble using:-
;GoAsm except1.asm
;Link using:-
;GoLink except1.obj /debug coff /console kernel32.dll user32.dll
;see goseh1.bat for a suitable batch file
;*******************************************************************
;
DATA SECTION
;
;*******************************************************************
FATALMESS DB "I thoroughly enjoyed it and I have already tidied everything up - "
          DB "you know, completed records, closed filehandles, "
          DB "released memory, that sort of thing .."
          DB "Glad this was by design - bye, bye ..",0Dh,0Ah
          DB ".. but first, I expect the system will do an unwind ..",0
;****************************** 
;
CODE SECTION
;
CLEAR_UP:               ;all clearing up would be done here
RET
;
FINAL_HANDLER:          ;system passes EXCEPTION_POINTERS
PUSH EBX,EDI,ESI        ;save registers as required by Windows
CALL CLEAR_UP
PUSH 40h                ;exclamation sign + ok button only
PUSH "Except1 - well it's all over for now."
PUSH ADDR FATALMESS,0
CALL MessageBoxA        ;wait till ok pressed
MOV EAX,1               ;terminate process without showing system message box
POP ESI,EDI,EBX
RET
;
;********************************* PROGRAM START
START:
;******** first lets make our final handler which would do all clearing up if
;******** the program has to close
PUSH ADDR FINAL_HANDLER
CALL SetUnhandledExceptionFilter
CALL PROTECTED_AREA
CALL CLEAR_UP           ;here the program clears up normally
PUSH 40h                ;exclamation sign + ok button only
PUSH "Except1","This is a very happy ending",0
CALL MessageBoxA        ;wait till ok pressed
PUSH 0                  ;code meaning a succesful conclusion
CALL ExitProcess        ;and finish with aplomb!
;********************************* PROGRAM END
;
PROTECTED_AREA:
PUSH EBP,0,0            ; )create the
PUSH OFFSET SAFE_PLACE  ; )ERR structure
PUSH OFFSET HANDLER     ; )on the 
FS PUSH [0]             ; )stack
FS MOV [0],ESP          ;point to structure just established on the stack
;
;*********************** and now lets cause the exception ..
CLI
XOR ECX,ECX             ;set ecx to zero
DIV ECX                 ;divide by zero, causing exception
;*********************** because of the exception the code never gets to here
;
SAFE_PLACE:             ;but the handler will jump to here ..
FS POP [0]              ;restore original exception handler from stack
ADD ESP,14h             ;throw away remainder of ERR structure made earlier
RET
;
;This simple handler is called by the system when the divide by zero
;occurs.  In this handler the user is given a choice of swallowing the
;exception by jumping to the safe-place, or not dealing with it at all,
;in which case the system will send the exception to the FINAL_HANDLER
;
HANDLER:
PUSH EBX,EDI,ESI        ;save registers as required by Windows
MOV EBX,[EBP+8]         ;get exception record in ebx
MOV EAX,[EBX+4]         ;get flag sent by the system
TEST AL,1h              ;see if its a non-continuable exception
JNZ >.nodeal            ;yes, so not allowed by system to touch it
TEST AL,2h              ;see if its the system unwinding
JNZ >.unwind            ;yes
PUSH 24h                ;question mark + YES/NO buttons
PUSH 'Except1','There was an exception - do you want me to swallow it?',0
CALL MessageBoxA        ;wait till button pressed
CMP EAX,6               ;see if yes clicked
JNZ >.nodeal            ;no
;***************************** go to SAFE_PLACE
MOV ESI,[EBP+10h]       ;get register context record in esi
MOV EDI,[EBP+0Ch]       ;get pointer to ERR structure in edi
MOV [ESI+0C4h],EDI      ;insert new esp (happens to be pointer to ERR)
MOV EAX,[EDI+8]         ;get address of SAFE_PLACE given in ERR structure
MOV [ESI+0B8h],EAX      ;insert that as new eip in register context
MOV EAX,[EDI+14h]       ;get ebp at safe place given in ERR structure
MOV [ESI+0B4h],EAX      ;insert that as new ebp in register context
XOR EAX,EAX             ;eax=0 reload context and return to system
JMP >.fin
.unwind:
PUSH 40h                ;exclamation sign + ok button only
PUSH "Except1"
PUSH "The system calling the handler again for more clearing up (unwinding)"
PUSH 0
CALL MessageBoxA        ;wait till ok pressed, then return eax=1
.nodeal:
MOV EAX,1               ;eax=1 system to go to next handler
.fin:
POP ESI,EDI,EBX
RET
;
