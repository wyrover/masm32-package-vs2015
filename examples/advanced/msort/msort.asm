comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                    Build as a CONSOLE mode application
;
;                    MASM32 string sort testbed
;
;                This is the testbed that was used to test all of the
;                string sorting algorithms that are now included in the
;                MASM32 library. It was designed for very large capacity
;                so that different sort algorithms could be tested in
;                critical large capacity data situations. It writes the
;                sorted output to STDOUT and can be redirected to a file.
;
;                It reads a file from the command line directly into a
;                buffer, loads the start of each word into an array of
;                pointers and terminates each word with a CRLF plus zero.
;
;                This test bed has been used on 50 million words and
;                a file size of 500 megabytes.
;
;     IMPORTANT: With any of the string sort algorithms, do NOT pass a
;                NULL POINTER in the array of pointers to the algorithms
;                as they are not designed to handle that situation.
;                Ensure that you either filter the input data for the
;                array to prevent a NULL pointer or make provision to
;                append extra data to the string so that the first BYTE
;                is not ascii ZERO.
;
ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

    .486                       ; create 32 bit code
    .model flat, stdcall       ; 32 bit memory model
    option casemap :none       ; case sensitive
 
    include \masm32\include\windows.inc
    include \masm32\include\masm32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\masm32.lib
    
    sortlist PROTO :DWORD,:DWORD
    chfilter PROTO :DWORD

	.data
		buffer	db	128	dup (0)
		msg1	db	"Sorry, cannot find ", 0
		crlf	db	10, 13, 0
		msg2	db	"MSORT MASM32 String Sort Testbed", 10, 13
				db	"Copyright (c) The MASM32 Project 1998-2004", 10, 13, 10, 13
				db	"SYNTAX: MSORT FileName.Ext [0 or NON 0]", 10, 13
				db	"        FileName.Ext is the list to sort", 10, 13
				db	"        Optional second parameter if used.", 10, 13
				db	"            0        = ascending sort", 10, 13
				db	"            NON ZERO = descending sort", 10, 13
				db	"            The default with no second argument is ascending sort.", 10, 13, 10, 13
				db	"        Output is to STDOUT. It can redirected to a file.", 10, 13, 10, 13
				; leave this zero as last
				db	0
		redirmsg	db	"        EXAMPLE: MSORT yourfile.txt 0 > targetfile.ext", 10, 13, 0

    .code

start:
 
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL sortorder :DWORD
   ; LOCAL buffer[128]:BYTE  ; filename buffer
    LOCAL arg2[128]:BYTE    ; buffer for optional 2nd arg
	jmp @debug
    invoke GetCL,1,ADDR buffer
    cmp eax, 1
    jne nocommandline

	push	offset buffer
	call	exist
	or		eax, eax
	jz		filedoesnotexist

    ;.if FUNC(exist,ADDR buffer) == 0
    ;  jmp filedoesnotexist
    ;.endif

    invoke GetCL,2,ADDR arg2
    cmp eax, 1
    jne no2ndarg
    lea eax, arg2
    cmp BYTE PTR [eax], "0"
    je no2ndarg
    mov sortorder, 1    ; descending sort
    jmp orderdetermined
  no2ndarg:
    mov sortorder, 0    ; ascending sort
  orderdetermined:

; д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д

    invoke sortlist, ADDR buffer,sortorder

; д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д

    jmp close

  filedoesnotexist:
	push	offset msg1
	call	StdOut
	push	offset buffer
	call	StdOut
	push	offset crlf
	call	StdOut
	jmp		close


  nocommandline:
	push	offset msg2
	call	StdOut
	push	offset	redirmsg
	call	StdOut

@debug:
	call	sortlist    
  close:
    invoke ExitProcess,0

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

OPTION PROLOGUE:NONE 
OPTION EPILOGUE:NONE 

align 4

chfilter proc lpstr:DWORD

comment * ----------------------------------------------------------
;        Leading character filter reads past blanks and tabs to test
;        1st character. If below 32 or about 126 it returns ZERO,
;        else it returns 1.
        ---------------------------------------------------------- *

    mov eax, [esp+4]            ; lpstr
    sub eax, 1

  @@:
    add eax, 1
    cmp BYTE PTR [eax], 32      ; loop back on space
    je @B
    cmp BYTE PTR [eax], 9       ; loop back on tab
    je @B
    cmp BYTE PTR [eax], 32      ; reject anything with a start char below 32
    jl reject
    cmp BYTE PTR [eax], 126     ; reject anything with a start char above 126
    jg reject
    mov eax, 1                  ; return NON ZERO if not
    ret 4

  reject:
    xor eax, eax                ; return ZERO
    ret 4

chfilter endp

OPTION PROLOGUE:PrologueDef 
OPTION EPILOGUE:EpilogueDef 

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

sortlist proc lpname:DWORD,sortorder:DWORD

comment * --------------------------------------------------------------
;    This algo reads a file into memory, reads each line into a
;    seperate buffer with the CRLF removed then writes the line back
;    to another buffer with an appended CRLF (13,10) and an appended
;    ascii ZERO after it. The appended CRLF garrantees that a NULL
;    pointer is not passed to the string sort algo that is not
;    designed to handle NULL pointers.
;
;    For each line it writes it stores the starting address in an
;    array of pointers so that when the 2nd buffer is loaded, there
;    is a pointers to each zero terminated string in the array.
;
;    The result is an array of pointers that can be passed to the string
;    sort algorithms that sort the pointers into either ascending or
;    descending alphabetical order.
;
;    When the sort algorith has finished, each zero terminated string
;    that is not a blank line is sent to STDOUT.
    ------------------------------------------------------------------ *

    LOCAL hMem  :DWORD      ; buffer handle for file data
    LOCAL hBuf  :DWORD      ; target buffer for formatted data
    LOCAL lBuf  :DWORD      ; buffer to load each line into
    LOCAL parr  :DWORD      ; pointer array handle
    LOCAL flen  :DWORD      ; variable for file length
    LOCAL spos  :DWORD      ; index for line read
    LOCAL wpos  :DWORD      ; index for write position
    LOCAL lcnt  :DWORD      ; line count in file
    LOCAL carr  :DWORD      ; character count array

    push ebx
    push esi
    push edi


    mov hMem, InputFile(lpname)             ; load disk file to memory
    mov flen, ecx                           ; save file length

    mov carr, alloc(1024)                   ; allocate character count array
    invoke byte_count,hMem,flen,carr        ; write byte count to array
    mov eax, carr                           ; array address
    mov ecx, [eax+52]                       ; 52 = ascii 13 * 4
    mov lcnt, ecx                           ; set line count
	push	dword ptr [carr]
	call	GlobalFree

    ;free carr

    mov esi, lcnt
    shl esi, 3                              ; mul by 8
    mov parr, alloc(esi)                    ; allocate pointer array

    mov eax, flen                           ; file length in EAX
    mov ecx, lcnt                           ; line count in ECX
    add ecx, ecx                            ; double it for space for 0 terminators
    add eax, ecx                            ; add it to EAX
    mov hBuf, alloc(eax)                    ; allocate target buffer

    mov lBuf, alloc(65536)                  ; allocate line buffer, limit of 64k

    mov spos, 0                             ; zero the line read index
    mov wpos, 0                             ; zero the line write index

    mov edi, parr

    mov lcnt, -1                            ; reuse lcnt for write count
    jmp jmpin
  @@:
    mov spos, linein$(hMem,lBuf,spos)       ; read line from source into line buffer
    mov ebx, eax                            ; put return in EBX
    mov wpos, lineout$(lBuf,hBuf,wpos,0)    ; write it to buffer with CRLF appended
    add wpos, 1                             ; add 1 so the terminator is not overwritten
  jmpin:
    mov esi, hBuf                           ; load address in ESI
    add esi, wpos                           ; add write position to it
    mov [edi], esi                          ; write address to pointer array
    add edi, 4                              ; set next position in pointer array
    add lcnt, 1                             ; count the number of writes
    test ebx, ebx                           ; test if linein$ returned zero
    jnz @B                                  ; loop back if it did not

	push	dword ptr [hMem]				; source memory no longer required
	call	GlobalFree
    
    invoke GetTickCount
    push eax

	invoke	GetCurrentProcess
    invoke SetPriorityClass, eax ,REALTIME_PRIORITY_CLASS

  ; ***********************************************************************

    .if sortorder == 0
      invoke assort,parr,lcnt,0
    .else
      invoke dssort,parr,lcnt,0
    .endif

    test eax, eax
    jnz @F
	.data
		msgStratOne	db	"Strategy one", 10, 13, 0
		msgStratTwo	db	"Strategy two", 10, 13, 0

	.code
    invoke StdErr, addr	msgStratOne      ; strategy one means the data was quick sorted
    
    jmp nxt
  @@:
    invoke StdErr, addr msgStratTwo      ; strategy two means the data was hybrid comb/insertion sorted
    
  nxt:

  ; ***********************************************************************

	invoke	GetCurrentProcess
    invoke SetPriorityClass,eax,NORMAL_PRIORITY_CLASS

    invoke GetTickCount
    pop ecx
    sub eax, ecx
    mov esi, eax

	.data
		msgTiming	db	"timing = ", 0
		msgMillisecs	db	" milliseconds", 10, 13, 0
	
	.code

    invoke StdErr,addr msgTiming
    invoke StdErr,esi
    invoke StdErr,addr msgMillisecs
    
  ; -----------------------
  ; print results to STDOUT
  ; -----------------------
    mov esi, parr                           ; load the pointer array in ESI
  @@:
    invoke	chfilter, esi

	cmp eax, 0             ; filter the line to test if it should be displayed
    je no_write                             ; jump over if it is
	push	esi
	call	StdOut
    ;print [esi]                             ; send string at that address to STDOUT
  no_write:
    add esi, 4                              ; set pointer address to next string
    sub lcnt, 1
    cmp lcnt, 0
    jne @B

  cleanup:

	push	dword ptr [hBuf]                ; free the buffer memory
	call	GlobalFree
	push	dword ptr [parr]				; free the pointer array memory
	call	GlobalFree
	push	dword ptr [lBuf]				; free the line buffer memory
	call	GlobalFree

    ;free hBuf
    ;free parr                               ;
    ;free lBuf                               ;

    pop edi
    pop esi
    pop ebx

    ret

sortlist endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start