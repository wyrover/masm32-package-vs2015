;////////////////////////////////////////////////////////////////////////////
;//                                                                        //
;// EXCEPT2.ASM - source for Except2.Exe                                   //
;// Complex Demo of Win32 structured exception handling                    //
;// for assembler programmers                                              //
;// See Except1.asm for a simple demo!                                     //
;// COPYRIGHT NOTE - this file is Copyright Jeremy Gordon 1996-2002        //
;//                  [MrDuck Software]                                     //
;//                - e-mail: JG@JGnet.co.uk                                //
;//                - www.GoDevTool.com                                     //
;// LEGAL NOTICE - The author accepts no responsibility for losses         //
;// of any type arising from this file or anything wholly or in part       //
;// created from it                                                        //
;//                                                                        //
;////////////////////////////////////////////////////////////////////////////
;
;The program uses a modal dialog box as its main window, which is why
;there is no message loop (this is dealt with by the system itself)
;A dialog box is created and the user has the choice of exceptions to choose
;from. The exception can be dealt with in handlers 1, 2 or 3; if it would
;normally cause program exit, it goes to the final handler.
;if it is repaired, this can be done either by returning to the place
;of exception or to a safe-place.
;As a final luxory the final handler may also try to recover from the
;exception, unwinding the stack first of course.
;If you decide to let the system deal with the exception, the system then
;unwinds the stack in exactly the same way as the handler does if the
;program is to try to continue running.
;
;Written for GoAsm (Jeremy Gordon). Assemble using:-
;GoAsm except2.asm
;Resources (dialogs, version and bitmap) compiled using GoRC (Jeremy Gordon) use:-
;GoRC except2.rc
;Link using:-
;GoLink except1.obj except2.res /debug coff /console kernel32.dll user32.dll gdi32.dll
;see goseh2.bat for a suitable batch file
;*******************************************************************
;
DATA SECTION
;
;*******************************************************************
MSG DD 7 DUP 0  ;hWnd, +4=message, +8=wParam, +C=lParam, +10h=time, +14h/18h=pt
RECT DD 4 DUP 0         ;rectangle - left, +4 top, +8 right, +0Ch bottom
;****************************** some dwords
lpArguments DD 2 DUP 0  ;holds data when RaiseException called
flOldProtect DD 0       ;holds previous code section access protection
hHeap       DD 0        ;handle to temporary memory areas
hList       DD 0        ;handle to listbox
hDC         DD 0        ;handle to device context of listbox
hCombo      DD 0        ;handle to combo box
hInst       DD 0        ;handle to main process
CINDEX      DD 0        ;index of combobox selection
COUNT       DD 0        ;used in getting a random number
MESSDELAY   DD 100h     ;length of time to keep message on the screen
EBPSAFE_PLACE3 DD 0     ;these are kept solely for
ESPSAFE_PLACE3 DD 0     ;repair by final handler
;******************************* non-doublewords follow
EXC_TYPE    DB 0        ;radio button exception type chosen
HANDLER     DB 0        ;the handler to repair the exception
CONTINUE    DB 0        ;1=continue from handler safe-place
HANDLERFLAG DB 0        ;1=read/write message is new
                        ;2=final handler unwind
;********************************* and some strings
BYETEXT    DB 'Have an exceptional day!',0
;********************** combo box messages
COMBO_STRING1 DB 'Deal with the exception in handler  ',0
COMBO_STRING3 DB 'Allow exception to go to final handler',0
;********************** exception messages
EXC_MESS0  DB 'Reading from         h ...  ',0     ;spaces at end to get rub-out
EXC_MESS1  DB 'Writing to         h ...  ',0       ;spaces at end to get rub-out
EXC_MESS2  DB 'ExceptionCode         h now in handler  :',0
EXC_MESS3  DB 'Attempting local repair (no unwind)',0
EXC_MESS4  DB 'Repair appears successful',0
EXC_MESS5  DB '        Flag=        h (continuable exception)',0
EXC_MESS5A DB '        Flag=        h (non-continuable exception)',0
EXC_MESS5B DB '        Flag=        h (unwinding)',0
EXC_MESS5C DB '        Local data=        h',0
EXC_MESS6  DB 'Handler cannot repair this exception',0
EXC_MESS7  DB 'Memory write error at         h',0
EXC_MESS8  DB 'Memory read error at          h',0
EXC_MESS9  DB 'Attempt to corrupt code at         h',0
EXC_MESS10 DB 'ExceptionCode         h in final handler',0
EXC_MESS11 DB 'Handler   clear-up code',0
EXC_MESS11A DB 'Handler   clear-up code - byebye ........',0
EXC_MESS12 DB 'Ready to do voluntary stack unwind',0
EXC_MESS13 DB '        Exception at eip=        h',0
EXC_MESS14 DB 'Hello from safe-place #2!',0
EXC_MESS15 DB 'Hello from safe-place #3!',0
EXC_MESS16 DB 'Hello from safe-place #1!',0
EXC_MESS17 DB 'Key F3=polite end; F5=nasty end; F7=recover',0
EXC_MESS18 DB 'Closing memory heap and dc',0
EXC_MESS19 DB 'There will be an exception in 3rd routine',0
EXC_MESS20 DB '        (protected by handler 3)',0
EXC_MESS21 DB 'Now system will unwind and call ExitProcess ...',0
EXC_MESS22 DB 'Code at        h caused an exception',0
EXC_MESS23 DB 'Now for own unwind then get to safe-place ...',0
EXC_MESS24 DB 'Hello from final handler in safe-place #3!',0
;
;*********************** for HEXWRITE
sHEXb   DB '0123456789ABCDEF'
;
;*******************************************************************
;*  CODE
;*******************************************************************
CODE SECTION
;
CODESTART:              ;label for code corruption test
;
HEXWRITE:               ;write hex number from eax into [esi]
PUSH EAX,EBX,EDX
MOV EBX,ADDR sHEXb
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
ROL EAX,4               ;get high order nibble into al
MOV DL,AL
AND EDX,0Fh             ;use only least sig nibble
MOV DL,[EBX+EDX]
MOV [ESI],DL            ;write the nibble
INC ESI                 ;ready for next
POP EDX,EBX,EAX
RET
;
ADD_LISTBOXSTRING:      ;add a string to listbox, scrolling if required
PUSH EDX,0,180h,[hList] ;LB_ADDSTRING (address in edx)
CALL SendMessageA
PUSH EAX                ;keep item index
DEC EAX                 ;index now one smaller
PUSH 0,EAX              ;string to ensure visible
PUSH 197h,[hList]       ;LB_SETTOPINDEX
CALL SendMessageA       ;scroll listbox now to show string just inserted
PUSH [hList]
CALL UpdateWindow
POP EAX                 ;restore item index
RET
;
WRITE_LISTBOXLINE:      ;write the string in edx to listbox
PUSH EAX
;**************************
CALL ADD_LISTBOXSTRING  ;write to listbox
PUSH [MESSDELAY]        ;256 milliseconds at start
CALL Sleep              ;delay for a while
;**************************
POP EAX
RET
;
WRITE_MEM_ERROR:
PUSH EBX
MOV EDX,ADDR EXC_MESS7  ;correct message if write error
CMP D[EBX+14h],1        ;see if write error flag from 1st part of array
JZ >0                   ;yes (write=1, read=0)
MOV EDX,ADDR EXC_MESS8  ;correct message if read error
0:
MOV EAX,[EBX+18h]       ;get 2nd part of array (inaccessible address)
MOV ESI,EDX
ADD ESI,22D
CALL HEXWRITE           ;write address into message
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
OR B[HANDLERFLAG],1     ;ensure that read/write message is written into listbox
POP EBX
RET
;
WCE23:                  ;write memory read/write number into message
PUSH ESI
MOV ESI,EBX
CALL HEXWRITE           ;write memory read/write number into message at esi
POP ESI
RET
;
WRITE_CURRENT_EDI:      ;correct message in esi
PUSH ECX,EDI
MOV EDX,ADDR EXC_MESS0  ;read message
MOV EBX,13D
CMP B[EXC_TYPE],104D    ;see if read test
JZ >1                   ;yes
SUB EBX,2
MOV EDX,ADDR EXC_MESS1  ;write message
1:
MOV ESI,EDX             ;keep correct message in esi
ADD EBX,EDX             ;and correct write-place in ebx
TEST B[HANDLERFLAG],1   ;see if first read/write message
JZ >2                   ;no
;************ drawtext is used because it is much quicker than lb_insertstring
;************ insert eventual item in listbox but write over it for now
MOV EAX,EDI             ;this message will be displayed at end of test
ADD EAX,1000h           ;so ensure it shows correct place of exception occurance
CALL WCE23              ;write memory read/write number into message
MOV EDX,ESI
CALL ADD_LISTBOXSTRING  ;write item to listbox, returning index in eax
PUSH ADDR RECT,EAX      ;index of last string written (wParam)
PUSH 198h,[hList]       ;LB_GETITEMRECT
CALL SendMessageA       ;get client co-ordinates in RECT for string just written
ADD D[RECT],2           ;allow for lhs border
AND B[HANDLERFLAG],0FEh ;don't come here again
2:
MOV EAX,EDI
CALL WCE23              ;write memory read/write number into message
;*********************
PUSH 100h,ADDR RECT     ;no clipping
PUSH -1,ESI,[hDC]       ;-1=system to count length
CALL DrawTextA
;*********************
POP EDI,ECX
RET
;
WRITE_WHICHADDRESS:     ;eax=code address
MOV ESI,ADDR EXC_MESS22
MOV EDX,ESI
ADD ESI,8
CALL HEXWRITE           ;write code address into message
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
RET
;
WRITE_HANDLERDATA:      ;eax=exception no., ebx=record, dl=handler no.
PUSH EAX,ESI,EDX
MOV ESI,ADDR EXC_MESS10
CMP DL,4                ;see if final handler
PUSHFD                  ;keep flag
JZ >3                   ;yes
MOV ESI,ADDR EXC_MESS2
ADD DL,48D              ;convert handler number to ascii char
MOV [ESI+39D],DL        ;write the handler number
3:
MOV EDX,ESI             ;keep correct message
ADD ESI,14D
CALL HEXWRITE           ;write exception number into message
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
MOV EAX,[EBX+4]         ;get exception flag
MOV ESI,ADDR EXC_MESS5  ;continuable
CMP EAX,1
JB >4
MOV ESI,ADDR EXC_MESS5A ;non-continuable
JZ >4
MOV ESI,ADDR EXC_MESS5B ;unwind
4:
MOV EDX,ESI             ;keep for WRITE_LISTBOXLINE later
ADD ESI,13D
CALL HEXWRITE           ;write exception flag into message
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
POPFD                   ;restore flag
JZ >5                    ;final handler so don't show local data address
MOV ESI,ADDR EXC_MESS5C
MOV EDX,ESI             ;keep for WRITE_LISTBOXLINE later
ADD ESI,19D
MOV EAX,[EBP+0Ch]       ;get pointer to ERR structure
CALL HEXWRITE           ;write as address of local data
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
5:
POP EDX,ESI,EAX
RET
;
CLEARUPCODE_MESS:       ;handler in edx
MOV ESI,ADDR EXC_MESS11
CMP DL,1                ;see if handler 1
JNZ >6
TEST B[HANDLERFLAG],2   ;see if final handler doing unwind, though
JNZ >6                  ;yes, so do ordinary message
MOV D[MESSDELAY],3000D  ;3 seconds
MOV ESI,ADDR EXC_MESS11A
6:
ADD DL,48D              ;convert handler number to ascii char
MOV [ESI+8D],DL         ;write the handler number into message
MOV EDX,ESI             ;keep correct message
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
RET
;
ADD_STRING:
PUSH ESI,0,143h,[hCombo] ;CB_ADDSTRING (uMsg), handle to combobox
CALL SendMessageA
RET
;
INITIALISE_CONTROLS:
MOV ECX,[EBP+14h]       ;get dialog id sent to DialogBoxIndirectParam (lParam)
JCXZ >1                 ;it's main dialog
RET                     ;it must be "about" dialog
1:
;************************* initialise the radio buttons
PUSH 108D               ;button to select
PUSH 109D,104D          ;last,first in group
PUSH [EBP+8]            ;hdlg
CALL CheckRadioButton
;************************* now initialise 2nd lot of radio buttons
PUSH 1                  ;indicate check
PUSH 111D               ;identifier
PUSH [EBP+8]            ;hdlg
CALL CheckDlgButton
;************************* now initialise the list and combo box
PUSH 113D,[EBP+8]       ;list box identifier
CALL GetDlgItem         ;get list box handle
MOV [hList],EAX         ;keep it
PUSH 110D,[EBP+8]       ;combo box identifier
CALL GetDlgItem         ;get combo box handle
MOV [hCombo],EAX        ;keep it
MOV BL,'1'              ;handler number to add to message
MOV ESI,ADDR COMBO_STRING1
2:
MOV [ESI+35D],BL        ;insert number into message
CALL ADD_STRING
INC BL
CMP BL,'4'              ;see if at last message
JNZ 2
MOV [CINDEX],EAX        ;keep the selection for later use
PUSH 0,EAX,14Eh,[hCombo] ;CB_SETCURSEL, handle to combobox
CALL SendMessageA
MOV ESI,ADDR COMBO_STRING3
CALL ADD_STRING         ;no repair message
RET
;
GET_EXC_TYPE:           ;get the chosen exception type
MOV EBX,104D
MOV ESI,6               ;number to do
3:
PUSH EBX,[EBP+8]        ;button identifier, hdlg
CALL IsDlgButtonChecked
CMP AL,1                ;see if button is checked
JZ >4                    ;yes
INC EBX
DEC ESI
JNZ 3
4:
MOV [EXC_TYPE],BL       ;keep type for later tests
RET
;
;***************************************************** PROGRAM START
START:
PUSH 0
CALL GetModuleHandleA
MOV [hInst],EAX
;**************************** establish a handler for the final exit
PUSH ADDR FINAL_HANDLER
CALL SetUnhandledExceptionFilter
;****************************** now create the dialog box
PUSH 0,ADDR DlgProc     ;pointer to dialog procedure (param=0=main dialog)
PUSH 0                  ;this dialog is the main window (no parent)
PUSH 'MainDialog'       ;name of dialog in resource file
PUSH [hInst]           
CALL DialogBoxParamA    ;this does not return until dialog closed
PUSH 0                  ;exit code zero=success if finishes this way
CALL ExitProcess
;****************************************************** PROGRAM END
;
PROCESS_COMMAND:        ;called if WM_COMMAND (eax holds wParam)
CMP EAX,99D             ;see if "about" clicked
JNZ >0                  ;no
PUSH 1,ADDR DlgProc,[EBP+8h]    ;param=1
PUSH 'About'
PUSH [hInst]
CALL DialogBoxParamA    ;create about dialog, borrowing main dlgproc
RET
0:
CMP EAX,101D            ;see if it was "cause exception" button
JZ >1                   ;yes
RET
;************************************************* CAUSE EXCEPTION WAS CLICKED
1:
CALL GET_EXC_TYPE       ;get the chosen exception type
;************************* next see if check button is checked
PUSH 112D,[EBP+8]       ;identifier of safe-place radiobutton
CALL IsDlgButtonChecked
MOV [CONTINUE],AL       ;keep this 1=continue from safe-place
;************************* now get the combo box selection
PUSH 0,0,147h           ;CB_GETCURSEL (uMsg)
PUSH [hCombo]           ;handle to combobox
CALL SendMessageA       ;get current selection
INC AL                  ;handler 1 now = 1
MOV [HANDLER],AL
;***************** clear the listbox
PUSH 0,0,184h           ;LB_RESETCONTENT
PUSH [hList]            ;handle to listbox
CALL SendMessageA
CALL SECOND_ROUTINE     ;run until exception and repair
RET
;
;******************************************************* DIALOG PROCEDURE
;******* The about dialog also comes here, but no static data is re-used
;******* apart from COUNT
DlgProc:
;
PUSH EBP
MOV EBP,ESP
;now [EBP+8]=hDlg, [EBP+0Ch]=uMsg, [EBP+10h]=wParam, [EBP+14h]=lParam
;************************************** create area for local data
SUB ESP,40h             ;make space of 16 dwords on stack for local data
;now addressable as [EBP-4] to [EBP-40h]
;************************************** save registers as required by Windows
PUSH EBX,EDI,ESI
;************************************** install handler_1 and its ERR structure
PUSH EBP                ;ERR+14h save ebp (being ebp at safe-place1)
PUSH 0                  ;ERR+10h area for flags
PUSH ADDR EXC_MESS16    ;ERR+0Ch safe place 1 message
PUSH ADDR SAFE_PLACE1   ;ERR+8h  place for new eip
PUSH ADDR HANDLER_1     ;ERR+4h  address of handler routine
FS PUSH [0]             ;ERR+0h  keep next handler up the chain
FS MOV [0],ESP          ;point to structure just established on the stack
;**************************************
INC D[COUNT]            ;used in getting a random number
MOV EAX,[EBP+0Ch]       ;get uMsg
CMP EAX,136h            ;see if WM_CTLCOLORDLG
JZ >3                   ;yes
CMP EAX,135h            ;see if WM_CTLCOLORBTN
JZ >2                   ;yes
CMP EAX,138h            ;see if WM_CTLCOLORSTATIC
JNZ >4                  ;no
PUSH 120D,[EBP+8]
CALL GetDlgItem         ;get control 120 handle
CMP EAX,[EBP+14h]       ;see if its the static control for bitmap frame
JZ LONG >8              ;must be kept white
2:
PUSH 1,[EBP+10h]        ;1=transparent, wParam
CALL SetBkMode
3:
PUSH 00808040h          ;blue colour from default palette
CALL CreateSolidBrush   ;create brush as an object with handle in EAX
JMP LONG >9             ;return with the brush handle (deleted on program exit)
4:                      ;this is needed because dialog=main window (no IDCANCEL)
CMP EAX,110h            ;see if WM_INITDIALOG
JNZ >5                  ;no
CALL INITIALISE_CONTROLS
JMP >.nonzero           ;return non-zero
5:
CMP EAX,10h             ;see if WM_CLOSE (sent if sysmenu clicked)
JZ >6                   ;yes, so say goodbye and finish
CMP EAX,111h            ;see if WM_COMMAND
JNZ >8                  ;no
TEST B[HANDLERFLAG],2   ;see if in final handler
JNZ >8                  ;yes so ignore command messages
MOV EAX,[EBP+10h]       ;wParam
CMP EAX,102D            ;see if it was quit button
JZ >6                   ;yes, so say goodbye and finish
CMP EAX,100D            ;see if "about" OK button
JZ >7                   ;yes so remove about dialog
CALL PROCESS_COMMAND
JMP >.nonzero
6:
TEST B[HANDLERFLAG],2   ;see if in final handler
JNZ >8                  ;yes so ignore quit/close messages
MOV D[MESSDELAY],1000D  ;one second delay
MOV EDX,ADDR BYETEXT    ;write "Have an exceptional day!"
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
7:
PUSH 0,[EBP+8]
CALL EndDialog          ;end dialog
.nonzero
MOV EAX,1               ;return non-zero (TRUE=message processed)
JMP >9
;****************************************************** HANDLER SAFE-PLACE 1
SAFE_PLACE1:            ;esp/ebp already set to correct values by handler
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox tell user reached here
8:
XOR EAX,EAX             ;return zero (FALSE=message not processed)
9:
FS POP [0]              ;restore original exception handler from stack
ADD ESP,14h             ;throw away remainder of ERR structure made earlier
POP ESI,EDI,EBX
MOV ESP,EBP
POP EBP
RET 10h                 ;automatically does epilogue code to close stack frame
;
ATTEMPT_CORRUPTION:     ;attempt code corruption in random place
MOV ESI,ADDR CODESTART
MOV EDI,ADDR CODEEND
SUB EDI,ESI             ;get how many bytes in the routine
;*****************************
;Note that it is possible the code section has a write attribute from its
;own PE file, so first ensure that this is removed ..
PUSH ADDR flOldProtect
PUSH 20h                ;PAGE_EXECUTE_READ
PUSH EDI,ESI            ;size, start
CALL VirtualProtect
OR EAX,EAX              ;check for success
JZ >.fin                ;no, so too dangerous to do the test
;***************************** get a random number no higher than edi
XOR EBX,EBX
7:
STC
RCL EBX,1
CMP EDI,EBX             ;find how many bits may be looked at
JNB 7
8:
CALL GetTickCount       ;get count since Windows started now
MOV EDX,EAX             ;keep whole tick count
SUB EAX,[COUNT]         ;add another random element
MOV ECX,200D
9:
AND EAX,EBX             ;only look at correct number of bits
CMP EDI,EAX             ;see if number is now too high
JNB >10                 ;no
ROR EDX,5               ;rotate edx 5 times
ADD EAX,EDX             ;add extra random element
LOOP 9                  ;try again 200 times
JMP 8                   ;try again with another tick count
10:
;*********** number now in eax
ADD ESI,EAX             ;get to address to corrupt
PUSH ESI
MOV EAX,ESI             ;get number to write in eax
MOV ESI,ADDR EXC_MESS9
ADD ESI,27D
CALL HEXWRITE           ;write exception flags into message
MOV EDX,ADDR EXC_MESS9  ;write "Attempt to corrupt code at         h"
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
POP ESI
MOV B[ESI],90h          ;attempt to corrupted code (causes exception)
.fin
RET
;
MEM_TEST:               ;its a memory read/write exception
OR B[HANDLERFLAG],1     ;ensure read/write message is written to listbox
;******** get device context and set up correct font and colour
PUSH [hList]
CALL GetDC
MOV [hDC],EAX           ;keep handle of device context of listbox
PUSH 0,0,31h,[hList]    ;WM_GETFONT
CALL SendMessageA       ;get listbox font
PUSH EAX,[hDC]
CALL SelectObject       ;use this font in the dc
PUSH 0FF0000h,[hDC]     ;nice blue colour
CALL SetTextColor
;**************************************************************
OR BL,BL                ;see if write test
JZ >22                  ;yes
;******************************** now for the read test
PUSH 0,1000h,0          ;make "growable" memory, 4K for immediate use
CALL HeapCreate
MOV EDI,EAX
MOV [hHeap],EAX         ;keep heap address
MOV ECX,2001h           ;ready to read from 8K +1
20:
MOV AL,[EDI]            ;read into al
CMP ECX,1               ;unless the last (handler returns to here for last one)
JZ >21                  ;listbox message already written
CALL WRITE_CURRENT_EDI  ;show user current position
21:
INC EDI
LOOP 20                 ;continue so as to cause exception
PUSH [hHeap]
CALL HeapDestroy
JMP >25
;******************************** now for the write test
22:
PUSH 4h                 ;read & write access
PUSH 2000h              ;MEM_RESERVE
PUSH 10000h             ;64K
PUSH 0                  ;system to decide address
CALL VirtualAlloc
MOV [hHeap],EAX
PUSH 4h                 ;read & write access
PUSH 1000h              ;MEM_COMMIT
PUSH 1000h              ;4K
PUSH [hHeap]
CALL VirtualAlloc
MOV EDI,EAX             ;base address of allocated 4K
MOV ECX,2001h           ;ready to write 8K + 1 byte
23:
MOV B[EDI],'X'
CMP ECX,1               ;unless the last (handler returns to here for last one)
JZ >24                  ;listbox message already written
CALL WRITE_CURRENT_EDI  ;show user current position
24:
INC EDI
LOOP 23                 ;continue so as to cause exception
PUSH 4000h,0,[hHeap]    ;MEM_DECOMMIT
CALL VirtualFree        ;decommit memory used
PUSH 8000h,0,[hHeap]    ;MEM_RELEASE
CALL VirtualFree        ;free memory used
25:
;**************************** release the device contact
PUSH [hDC],[hList]
CALL ReleaseDC
RET
;
ERROR_ROUTINE:          ;the exception will occur in this routine
XOR EBX,EBX
MOV BL,[EXC_TYPE]       ;get exception type again
SUB EBX,105D            ;see if memory read/write test
JA >30                  ;no
CALL MEM_TEST
RET
30:
;*********************** own software exception
DEC EBX                 ;see if should do own (continuable) software exception
JZ >31                  ;yes
CMP EBX,1               ;see if should do own (non-continuable) software exception
JNZ >32                 ;no
31:                     ;0=continuable exception, 1=non-continuable exception
MOV EAX,ADDR AVOID      ;get place to restart from
MOV [lpArguments],EAX   ;keep in array in memory
MOV [lpArguments+4],ESP ;keep esp too
PUSH ADDR lpArguments   ;give array to function
PUSH 2                  ;number of arguments in array
PUSH EBX                ;continuable or non-continuable exception flag
PUSH 0E0000100h         ;exception code
CALL RaiseException
AVOID:
RET
32:
DEC EBX,EBX             ;see if divide by zero
JNZ >33                 ;no
;*********************** divide by zero exception
XOR ECX,ECX
MOV EAX,66D
DIV CL                  ;divide by zero to create exception
RET
33:                     ;must be attempt to corrupt code test
CALL ATTEMPT_CORRUPTION ;attempt code corruption in random place in code
RET
;
THIRD_ROUTINE:
;************************************** install handler_3 and its ERR structure
PUSH EBP                ;ERR+14h save ebp (being ebp at safe-place3)
PUSH 0                  ;ERR+10h area for flags
PUSH ADDR EXC_MESS15    ;ERR+0Ch safe place 3 message
PUSH ADDR SAFE_PLACE3   ;ERR+8h  place for new eip
PUSH ADDR HANDLER_3     ;ERR+4h  address of handler routine
FS PUSH [0]             ;ERR+0h  keep next handler up the chain
FS MOV [0],ESP          ;point to structure just established on the stack
;**************************************
MOV [EBPSAFE_PLACE3],EBP ;these are kept solely for
MOV [ESPSAFE_PLACE3],ESP ;repair by final handler
;**************************************
MOV EDX,ADDR EXC_MESS19 ;"exception will occur in level 3 code"
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
MOV EDX,ADDR EXC_MESS20 ;"(protected by exception handler 3)"
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
CALL ERROR_ROUTINE      ;exception will be caused by this routine
JMP >4
;************************************** here is the safe place & code
SAFE_PLACE3:            ;esp/ebp already set to correct values by handler
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox tell user reached here
4:
FS POP [0]              ;restore original exception handler from stack
ADD ESP,14h             ;throw away handler_3
RET
;
SECOND_ROUTINE:
;************************************** install handler_2 and its ERR structure
PUSH EBP                ;ERR+14h save ebp (being ebp at safe-place2)
PUSH 0                  ;ERR+10h area for flags
PUSH ADDR EXC_MESS14    ;ERR+0Ch safe place 2 message
PUSH ADDR SAFE_PLACE2   ;ERR+8h  place for new eip
PUSH ADDR HANDLER_2     ;ERR+4h  address of handler routine
FS PUSH [0]             ;ERR+0h  keep next handler up the chain
FS MOV [0],ESP          ;point to structure just established on the stack
;**************************************
CALL THIRD_ROUTINE
JMP >5
;************************************** here is the safe place & code
SAFE_PLACE2:            ;esp/ebp already set to correct values by handler
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox tell user reached here
5:
FS POP [0]              ;restore original exception handler from stack
ADD ESP,14h             ;throw away remainder of ERR structure made earlier
RET
;
;************ here is the routine to "unwind" the stack and go to safe-place
TRYFOR_SAFEPLACE:       ;EAX=exception
CMP EAX,0C0000005h      ;see if memory read/write exception
JNZ >6                  ;no
CALL WRITE_MEM_ERROR    ;write type and place of error
6:
MOV EDX,ADDR EXC_MESS12
CALL WRITE_LISTBOXLINE  ;write "Ready to do voluntary stack unwind"
;*** now carry out own unwind for other handlers to clear-up using local data
;*** here is the call to the only recently documented API function RtlUnwind
PUSH 0                  ;return value (not needed)
PUSH [EBP+8]            ;send exception_record to per-thread handlers
PUSH ADDR UN23          ;return address
PUSH [EBP+0Ch]          ;pointer to this ERR structure
CALL RtlUnwind
UN23:
;***************************** now change context to suit safe place
;***************************** current context has values as at the exception
MOV ESI,[EBP+10h]       ;get context record in esi
MOV EDX,[EBP+0Ch]       ;get pointer to ERR structure
MOV [ESI+0C4h],EDX      ;insert new esp (happens to be pointer to ERR)
MOV EAX,[EDX+8]         ;get safe place given in ERR structure
MOV [ESI+0B8h],EAX      ;insert new eip
MOV EAX,[EDX+0Ch]       ;get message address in eax
MOV [ESI+0A8h],EAX      ;insert new edx
MOV EAX,[EDX+14h]       ;get ebp at safe place given in ERR structure
MOV [ESI+0B4h],EAX      ;insert new ebp
RET
;***************** here is the routine to try repair an exception
ATTEMPT_LOCAL_REPAIR:   ;EAX=exception, EBX=exception record
MOV EDX,ADDR EXC_MESS3
CALL WRITE_LISTBOXLINE  ;write "Attempting local repair (no unwind)" (saves eax)
CMP EAX,0E0000100h      ;see if own software exception
JZ >11                  ;yes
CMP EAX,0C0000094h      ;see if divide by zero exception
JZ >9                   ;yes
CMP EAX,0C0000005h      ;see if memory read/write exception
JNZ >10                 ;no
CMP B[EXC_TYPE],104D    ;see if memory test
JZ >7                   ;yes
CMP B[EXC_TYPE],105D    ;see if memory test
JNZ >10                 ;no
7:
CALL WRITE_MEM_ERROR    ;write type and place of error
CMP D[EBX+14h],1        ;see if write error flag from 1st part of array
JZ >8                   ;yes (write=1, read=0)
;************** read from memory error - the following will work
PUSH 1000h              ;allocate another 4K
PUSH 4                  ;HEAP_GENERATE_EXCEPTIONS on error=another exception
PUSH [hHeap]            ;normally get this from handler structure
CALL HeapAlloc          ;allocate another 4K
OR EAX,EAX              ;see if error
JZ >10                  ;yes
JMP >12
;******** the above did not work for write error because memory has already
;been written to during exception and is therefore "corrupt".  You get a
;C0000005h access violation.  The way round this is to use the virtual alloc
;function which will permit you to specify the starting place for the new
;memory allocation (which is the same as inaccessible address):-
8:
PUSH 4                  ;read and write access
PUSH 1000h              ;commit more memory
PUSH 1000h              ;another 4K required
PUSH [EBX+18h]          ;inaccessible address sent as 2nd part of array
CALL VirtualAlloc       ;add another 4K using inaccessible address as base
OR EAX,EAX              ;see if error
JZ >10                  ;yes
JMP >12
;********************************
9:                      ;its divide by zero exception
MOV ESI,[EBP+10h]       ;get context record in esi
MOV D[ESI+0ACh],1D      ;replace ecx with 1 to ensure div by 1 next time
JMP >12
10:                     ;error or unexpected exception return
MOV EDX,ADDR EXC_MESS6
CALL WRITE_LISTBOXLINE  ;write "Handler cannot repair this exception"
STC
RET
11:                     ;its an own software exception
MOV ESI,[EBP+10h]       ;get context record in esi
MOV EDX,[EBP+0Ch]       ;get pointer to ERR structure
MOV EAX,[EDX+14h]       ;get ebp at safe place given in ERR structure
MOV [ESI+0B4h],EAX      ;insert new ebp in context
MOV EAX,[EBX+14h]       ;get from exception record the address to jump to
MOV [ESI+0B8h],EAX      ;change eip in context
MOV EAX,[EBX+18h]       ;get from exception record the 2nd part of array
MOV [ESI+0C4h],EAX      ;which is the ESP at repair place
12:
MOV EDX,ADDR EXC_MESS4
CALL WRITE_LISTBOXLINE  ;write "repair appears successful"
CLC
RET                     ;return nc on success, c on failure
;
HEAP_CLOSE:
CMP B[EXC_TYPE],104D    ;see if memory test
JZ >20                  ;yes
CMP B[EXC_TYPE],105D    ;see if memory test
JNZ >23                 ;no
20:
MOV EDX,ADDR EXC_MESS18
CALL WRITE_LISTBOXLINE  ;write "Closing memory heap and dc"
CMP D[EBX+14h],1        ;see if write error flag from 1st part of array
JZ >21                  ;yes (write=1, read=0)
PUSH [hHeap]
CALL HeapDestroy
JMP >22
21:
PUSH 4000h,0,[hHeap]    ;MEM_DECOMMIT
CALL VirtualFree        ;decommit memory used
PUSH 8000h,0,[hHeap]    ;MEM_RELEASE
CALL VirtualFree
22:
PUSH [hDC],[hList]
CALL ReleaseDC
23:
RET
;
HANDLER_3:              ;handler 3
PUSH EBP
MOV EBP,ESP
PUSH EBX,EDI,ESI        ;save registers as required by Windows
MOV EBX,[EBP+8]         ;get exception record in ebx
TEST D[EBX+4],02h       ;see if its EH_UNWINDING (from Unwind)
JNZ >30                 ;yes, so exception address is not useful here
MOV EAX,[EBX+0Ch]       ;get ExceptionAddress
CALL WRITE_WHICHADDRESS
30:
MOV EAX,[EBX]           ;get ExceptionCode
MOV DL,3                ;indicate 3rd handler
CALL WRITE_HANDLERDATA  ;saves edx
TEST D[EBX+4],01h       ;see if its a non-continuable exception
JNZ >34                 ;yes
TEST D[EBX+4],02h       ;see if its EH_UNWINDING (from Unwind)
JZ >31                  ;no
CALL CLEARUPCODE_MESS
CALL HEAP_CLOSE         ;close the memory heap and dc if memory test
JMP >34                 ;must return 1 to go to next handler
31:
CMP [HANDLER],DL        ;see if this handler allowed to deal
JNZ >34                 ;no
CMP B[CONTINUE],1       ;see if 1=continue from safe-place
JNZ >32                 ;no so deal with exception locally
CALL TRYFOR_SAFEPLACE
JMP >33
32:
CALL ATTEMPT_LOCAL_REPAIR
JNC >33                 ;success
CALL TRYFOR_SAFEPLACE
33:
XOR EAX,EAX             ;reload context and return to system
JMP >35
34:                  
MOV EAX,1               ;this handler will not deal with this exception
35:
POP ESI,EDI,EBX
MOV ESP,EBP
POP EBP
RET                     ;ordinary return because was a "C" type call not PASCAL
;
HANDLER_2:              ;second handler
PUSH EBP
MOV EBP,ESP
PUSH EBX,EDI,ESI        ;save registers as required by Windows
MOV EBX,[EBP+8]         ;get exception record in ebx
MOV EAX,[EBX]           ;get ExceptionCode
MOV DL,2                ;indicate 2nd handler
CALL WRITE_HANDLERDATA  ;saves edx
TEST D[EBX+4],01h       ;see if its a non-continuable exception
JNZ >43                 ;yes
TEST D[EBX+4],02h       ;see if its EH_UNWINDING (from Unwind)
JZ >40                  ;no
CALL CLEARUPCODE_MESS
JMP >43                 ;must return 1 to go to next handler
40:
CMP [HANDLER],DL        ;see if this handler allowed to deal
JNZ >43                 ;no
CMP B[CONTINUE],1       ;see if 1=continue from safe-place
JNZ >41                 ;no so deal with exception locally
CALL TRYFOR_SAFEPLACE
JMP >42
41:
CALL ATTEMPT_LOCAL_REPAIR
JNC >42                 ;success
CALL TRYFOR_SAFEPLACE
42:
XOR EAX,EAX             ;exception was repaired - reload context and try again
JMP >44
43:
MOV EAX,1               ;this handler will not deal with this exception
44:
POP ESI,EDI,EBX
MOV ESP,EBP
POP EBP
RET                     ;ordinary return because was a "C" type call not PASCAL
;
HANDLER_1:
PUSH EBP
MOV EBP,ESP
PUSH EBX,EDI,ESI        ;save registers as required by Windows
MOV EBX,[EBP+8]         ;get exception record in ebx
MOV EAX,[EBX]           ;get ExceptionCode
MOV DL,1                ;indicate 1st handler
CALL WRITE_HANDLERDATA  ;saves edx
TEST D[EBX+4],01h       ;see if its a non-continuable exception
JNZ >53                 ;yes
TEST D[EBX+4],02h       ;see if its EH_UNWINDING (from Unwind)
JZ >50                  ;no
CALL CLEARUPCODE_MESS
JMP >53                 ;must return 1 to go to next handler
50:
CMP [HANDLER],DL        ;see if this handler allowed to deal
JNZ >53                 ;no
CMP B[CONTINUE],1       ;see if 1=continue from safe-place
JNZ >51                 ;no so deal with exception locally
CALL TRYFOR_SAFEPLACE
JMP >52
51:
CALL ATTEMPT_LOCAL_REPAIR
JNC >52                 ;success
CALL TRYFOR_SAFEPLACE
52:
XOR EAX,EAX             ;reload context and return to system
JMP >54
53:                  
MOV EAX,1               ;go to next handler
54:
POP ESI,EDI,EBX
MOV ESP,EBP
POP EBP
RET                     ;ordinary return because was a "C" type call not PASCAL
;
FINAL_HANDLER_RECOVERY: ;ebx=exception record, esi=context
MOV EDX,ADDR EXC_MESS23 ;will now do voluntary unwind and safe-place
CALL WRITE_LISTBOXLINE  ;write the string in edx to listbox
;
;-- DO NOT REMOVE ---------------- the following unwind systems are alternative
;************* the final handler does not know the last ERR structure
;************* so find it
;FS MOV EAX,[0]          ;get pointer to very first ERR structure
;L880:
;CMP D[EAX],-1           ;see if the last one
;JZ >L881                ;yes, so finish
;MOV EAX,[EAX]           ;get pointer to next ERR structure
;JMP L880
;L881:
;PUSH ESI                ;cannot rely on RtlUnwind to keep this (context)
;;**********************
;PUSH 0                  ;return value (not used)
;PUSH EBX                ;send exception_record to per-thread handlers
;PUSH ADDR UN25          ;return address
;PUSH EAX                ;pointer to last unwind frame
;CALL RtlUnwind
;UN25:
;;**********************
;POP ESI
;JMP >61
;-- DO NOT REMOVE --------------------------------------------------------
;
;********************************** trying own unwind in final handler
MOV D[EBX+4],02h        ;indicate eh_unwinding flag for termination code
FS MOV EDI,[0]          ;get pointer to very first ERR structure
60:
CMP D[EDI],-1           ;see if the last one
JZ >61                  ;yes, so finish
PUSH EDI,EBX            ;push ERR structure,exception record
CALL [EDI+4]            ;call the associated handler to run clear-up code
ADD ESP,8h              ;remove parameters put on the stack
MOV EDI,[EDI]           ;get pointer to next ERR structure
JMP 60
61:
;*******************************************************************
MOV EAX,[EBPSAFE_PLACE3] ;kept earlier in third_routine
MOV [ESI+0B4h],EAX      ;insert new ebp
MOV EAX,[ESPSAFE_PLACE3] ;in case of this repair
MOV [ESI+0C4h],EAX      ;insert new esp
MOV EAX,ADDR SAFE_PLACE3
MOV [ESI+0B8h],EAX      ;insert new eip
MOV EAX,ADDR EXC_MESS24 ;hello from safe-place 3 message
MOV [ESI+0A8h],EAX      ;insert new edx
RET
;
;*********************** now if exception reached this point it is serious
FINAL_HANDLER:          ;this time the system passes only the pointer
MOV EDX,[ESP+4]         ;to EXCEPTION_POINTERS - get it in edx
PUSH EBX,EDI,ESI        ;save registers as required by Windows
OR B[HANDLERFLAG],2     ;flag that in final handler
;************************** see EXCEPTION_POINTERS structure
MOV ESI,[EDX+4]         ;get context record in esi
MOV EBX,[EDX]           ;get pointer to Exception Record
MOV EAX,[EBX]           ;get exception code
MOV DL,4                ;indicate final handler
CALL WRITE_HANDLERDATA  ;saves esi, ebx
MOV EAX,[ESI+0B8h]      ;get eip from context
PUSH ESI                ;keep context
MOV ESI,ADDR EXC_MESS13 ;Exception at eip=         h
MOV EDX,ESI
ADD ESI,25D
CALL HEXWRITE
CALL ADD_LISTBOXSTRING  ;write the string in edx to listbox
MOV EDX,ADDR EXC_MESS17 ;"Press F3=polite end, F5=nasty end, F7=recover!"
CALL ADD_LISTBOXSTRING  ;write the string in edx to listbox
POP ESI                 ;restore context
;*************************************** flush any key messages in message queue
0:
CALL GetActiveWindow    ;get handle to dialog
PUSH 1                  ;PM_REMOVE remove message if there
PUSH 108h,100h,EAX,ADDR MSG   ;WM_KEYLAST,WM_KEYFIRST key press filter
CALL PeekMessageA
OR EAX,EAX              ;see if there was a key message there
JNZ 0                   ;yes, so ignore it
;**************** now wait for correct keypress but let mouse messages through
1:                      ;note that command messages are sent direct to dlgproc
CALL GetActiveWindow    ;get handle to dialog
PUSH 0,0,EAX,ADDR MSG   ;get all messages
CALL GetMessageA
MOV EAX,[MSG+4]         ;get message
CMP EAX,100h            ;see if below WM_KEYFIRST
JB >2                   ;yes, so send to dlgproc
CMP EAX,108h            ;see if above WM_KEYLAST
JA >2                   ;yes, so send to dlgproc
MOV EAX,[MSG+8]         ;get virtual key
CMP EAX,76h             ;see if F7 pressed
JZ >3                   ;yes
CMP EAX,74h             ;see if F5 pressed
JZ >5                   ;yes
CMP EAX,72h             ;see if F3 pressed
JZ >4                   ;yes
JMP 1                   ;no so ignore and wait for other messages
2:
PUSH ADDR MSG
CALL DispatchMessageA   ;send mouse message to DlgProc
JMP 1
3:
CALL FINAL_HANDLER_RECOVERY
MOV EAX,-1              ;reload context and continue execution
JMP >7
;*****************************************************************************
4:
PUSH 0                  ;ok button only
PUSH 'This is the polite end'
PUSH 'We sincerely offer our grovelling apologies (sic)!'
PUSH [hInst]
CALL MessageBoxA        ;wait till ok pressed
MOV EDX,ADDR EXC_MESS21
CALL WRITE_LISTBOXLINE  ;back to the system for unwind and termination
MOV EAX,1               ;terminate process without showing message box
JMP >6
5:
MOV EDX,ADDR EXC_MESS21
CALL WRITE_LISTBOXLINE  ;back to the system for unwind and termination
MOV EAX,0               ;terminate process showing message box
6:
MOV D[MESSDELAY],1000D  ;greater delay for final messages from the system
7:
;*********************************************************************
AND B[HANDLERFLAG],0FDh ;clear flag that in final handler
POP ESI,EDI,EBX
RET 4h                  ;(for what it's worth) remove parameter from the stack
;
CODEEND:                ;label for attempted code corruption
;
