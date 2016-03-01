OPTION DOTNAME
include win64.inc
include temphls.inc
include kernel32.inc
includelib kernel32.lib
include user32.inc
includelib user32.lib
include gdi32.inc
includelib gdi32.lib

OPTION PROLOGUE:none
OPTION EPILOGUE:none
IMAGE_BASE      equ 400000h
IDB_MYBITMAP   	equ 100
.code
WinMain proc 
local msg:MSG
      push rbp
      mov rbp,rsp
	sub rsp,sizeof MSG

	xor ebx,ebx     

	push 10029h	;hIconSm        	
	mov edi,offset ClassName
	push rdi	;lpszClassName  	 
	push rbx	;lpszMenuName   	 
	push COLOR_WINDOW;hbrBackground 	 
	push 10005h	;hCursor        	 
	push 10029h        ;hIcon       	 
	mov esi,IMAGE_BASE
	push rsi	;hInstance      	 
	push rbx        ;cbClsExtra & cbWndExtra 
	mov eax,offset WndProc
	push rax	;lpfnWndProc             
	push sizeof WNDCLASSEX;cbSize & style    
	mov rcx,rsp	;addr WNDCLASSEX
	push rbx        
	push rbx                                 
	push rbx                                 
	push rbx                                 
    	call RegisterClassEx
	push rbx                                 
	push rsi	;rsi=400000h             
	shr esi,7;Special CreateWindow position value CW_USEDEFAULT=8000h
	push rbx                                 
	push rbx                                 
	push 320
	push 300
	push rsi                                 
	push rsi                                 
	mov r9d,WS_OVERLAPPEDWINDOW or WS_VISIBLE
	mov r8,rdi	;offset ClassName
	mov edx,edi	;offset ClassName
	xor ecx,ecx                              
	push rbx                                 
	push rbx                                 
	push rbx                                 
	push rbx                                 
    	call CreateWindowEx
	lea edi,msg
@@:   mov ecx,edi
	xor edx,edx
	mov r8,rbx
	mov r9,rbx
      call GetMessage
	mov ecx,edi
      call DispatchMessage
      jmp @b
WinMain endp
;---------------------------------------------------------------
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hMemDC:HDC
   LOCAL rect:RECT

        push rbp
        mov rbp,rsp
        sub rsp,sizeof PAINTSTRUCT+sizeof RECT+8+40h
        
        mov hWnd,rcx
        
        cmp edx,WM_DESTROY
	je wmDESTROY
        cmp edx,WM_CREATE
	je wmCREATE
        cmp edx,WM_PAINT
	je wmPAINT
        leave
        jmp DefWindowProc
wmDESTROY:mov rcx,hBitmap 
        call DeleteObject
        xor ecx,ecx
        call ExitProcess
wmCREATE:mov edx,IDB_MYBITMAP
        mov ecx,IMAGE_BASE
        call LoadBitmap
        mov hBitmap,rax
        jmp wmBYE
wmPAINT:lea edx,ps
        call BeginPaint
        mov rcx,rax
        call CreateCompatibleDC
        mov hMemDC,rax
        mov rdx,hBitmap
        mov rcx,rax
        call SelectObject
        lea edx,rect
        mov rcx,hWnd
        call GetClientRect
        mov qword ptr [rsp+40h],SRCCOPY
        mov [rsp+38h],rbx
        mov [rsp+30h],rbx
        mov rax,hMemDC
        mov [rsp+28h],rax
        mov eax,rect.bottom
        mov [rsp+20h],rax
        mov r9d,rect.right
        mov r8,rbx
        xor edx,edx
        mov rcx,ps.hdc
        call BitBlt
        mov rcx,hMemDC
        call DeleteDC
        lea edx,ps
        mov rcx,hWnd
        call EndPaint        
wmBYE:  leave
        retn
 WndProc endp
;---------------------------------------
ClassName   db 'Win64 Iczelion lesson #25a',0
hBitmap     dq ?
end