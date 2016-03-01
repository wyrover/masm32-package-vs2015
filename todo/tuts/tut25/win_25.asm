OPTION DOTNAME
option casemap:none
include temphls.inc
include win64.inc
include kernel32.inc
includelib kernel32.lib
include user32.inc
includelib user32.lib
include gdi32.inc
includelib gdi32.lib
OPTION PROLOGUE:rbpFramePrologue
OPTION EPILOGUE:rbpFrameEpilogue
.code
WinMain proc 
msg	equ [rbp-sizeof MSG]

	enter 90h,0;sizeof MSG+sizeof WNDCLASSEX+20h,0;90h,0
	xor ebx,ebx
        mov esi,400000h
	lea rdi,ClassName
        mov qword ptr [rsp+28h],LR_LOADFROMFILE
        mov [rsp+20h],rbx
        mov r9,rbx
        mov r8,rbx
        mov edx,edi
        mov ecx,esi
        call LoadImage
        mov rcx,rax
        call CreatePatternBrush
	push 10029h	;hIconSm
	push rdi	;lpszClassName
	push rbx	;lpszMenuName
	push rax	;hbrBackground
	push 10005h	;hCursor
	push 10029h     ;hIcon	
	push rsi	;hInstance
	push rbx        ;cbClsExtra & cbWndExtra
	lea eax,WndProc
	push rax	;lpfnWndProc
	push sizeof WNDCLASSEX;cbSize & style
	mov rcx,rsp	;addr WNDCLASSEX
	push rbx
	push rbx
	push rbx
	push rbx
    	call RegisterClassEx	
	add rsp,sizeof WNDCLASSEX+20h
	push rbx
	push rsi	;rsi=400000h
	shl esi,9	;rsi=CW_USEDEFAULT
	push rbx
	push rbx
	push 305
	push 286
	push rsi
	push rsi
	mov r9d,WS_OVERLAPPED or WS_VISIBLE or WS_CAPTION or \
        WS_SYSMENU or WS_MINIMIZEBOX
	mov r8,rdi	;offset ClassName
	mov edx,edi	;offset ClassName
	xor ecx,ecx
	push rbx
	push rbx
	push rbx
	push rbx
    	call CreateWindowEx
    	lea edi,msg
@@:     mov ecx,edi
	xor edx,edx
	mov r8,rbx
	mov r9,rbx
        call GetMessage
	mov ecx,edi
        call DispatchMessage
        jmp @b
WinMain endp
WndProc:cmp  edx,WM_DESTROY
        je   wmDESTROY
        jmp DefWindowProc
wmDESTROY: xor ecx,ecx
        call ExitProcess
;---------------------------------------
ClassName db 'Images\tweety78.bmp',0
end