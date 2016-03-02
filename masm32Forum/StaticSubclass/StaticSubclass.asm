.586
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\shell32.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\shell32.lib

UrlProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.data?
hInst                       DWORD   ?
hFont                       DWORD   ?
hFontUl                     DWORD   ?
lpOrgStaticProc             DWORD   ?
lpOrgWebProc                DWORD   ?
hBrush                      DWORD   ?
bMouseOver                  DWORD   ?
msg                         MSG     <?>
hEmail                      DWORD   ?
hWeb                        DWORD   ?
hMain                       DWORD   ?

.code
start:
jmp @F
    szWndClsMain                BYTE    "SSC_MAIN", 0
    szWndClsStatic				BYTE	"STATIC", 0
    szAppName                   BYTE    "Static Subclass Example", 0
    szEmailText                 BYTE    "Send Agguro Mail", 0
    szEmailURL                  BYTE    "mailto://admin@agguro.org", 0
    szWebText                   BYTE    "Visit Agguros Webpage", 0
    szWebURL                    BYTE    "http://www.agguro.org", 0
    szShelOpen                  BYTE    "open", 0
    szFontName                  BYTE    "Verdana", 0
@@:
    call    Startup
    
    .while TRUE
	    invoke  GetMessage, addr msg, NULL, 0, 0
	    .break .if !eax
         invoke TranslateMessage, addr msg
		invoke  DispatchMessage, addr msg
    .endw
	mov		eax, msg.message
	invoke  ExitProcess, eax
    
Startup proc uses ebx 
LOCAL   lfnt:LOGFONT
LOCAL   wc:WNDCLASSEX

    invoke  GetModuleHandle, NULL
    mov     hInst, eax
  
    ;#####  Create 2 fonts
    invoke  RtlZeroMemory, addr lfnt, sizeof LOGFONT

    ;#####  Reg font
    mov     lfnt.lfHeight, -11
    mov     lfnt.lfWeight, FW_NORMAL
    invoke  szCatStr, addr lfnt.lfFaceName, offset szFontName
    invoke  CreateFontIndirect, addr lfnt
    mov     hFont, eax

    ;#####  Bold font
    mov     lfnt.lfUnderline, TRUE
    invoke  CreateFontIndirect, addr lfnt
    mov     hFontUl, eax

    ;#####  Register main window class
    invoke  RtlZeroMemory, addr wc, sizeof WNDCLASSEX

    mov     wc.cbSize, sizeof WNDCLASSEX
    mov     wc.style, CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, offset WndProcMain
    push    hInst
    pop     wc.hInstance
    mov     wc.hbrBackground, COLOR_HIGHLIGHT + 1;  COLOR_3DFACE + 1
    mov     wc.lpszClassName, offset szWndClsMain
    invoke  LoadIcon, NULL, IDI_EXCLAMATION
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax
    invoke  LoadCursor, NULL, IDC_ARROW
    mov     wc.hCursor, eax
    invoke  RegisterClassEx, addr wc
    
    ;#####  Coords to center window
    invoke  GetSystemMetrics, SM_CXSCREEN
    sub     eax, 300
    shr     eax, 1
    xchg    eax, ebx
    
    invoke  GetSystemMetrics, SM_CYSCREEN
    sub     eax, 123
    shr     eax, 1

    ;#####  Create main window
    invoke  CreateWindowEx,
                WS_EX_APPWINDOW or WS_EX_CONTROLPARENT,
                offset szWndClsMain,
                offset szAppName,
                WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX or WS_VISIBLE, 
                ebx, eax,
                300, 123,
                HWND_DESKTOP, NULL,
                hInst, NULL
    mov     hMain, eax
    ret
Startup endp

WndProcMain proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;local   rect:RECT
    mov     eax, uMsg
    .if eax == WM_CREATE
        ;#####  Email Hyperlink
        invoke  CreateWindowEx, 
                    NULL, 
                    offset szWndClsStatic, 
                    offset szEmailText, 
                    WS_CHILD or WS_VISIBLE or SS_NOTIFY, 
                    88, 20, 
                    117, 17, 
                    hWin, 0, 
                    hInst, 0
        mov     hEmail, eax
        
        ;#####  URL is dif than text, save URL
        invoke  SetWindowLong, eax, GWL_USERDATA, offset szEmailURL
        ;#####  Subclass control
        invoke  SetWindowLong, hEmail, GWL_WNDPROC, UrlProc
        mov     lpOrgStaticProc, eax
        
        invoke  SendMessage, hEmail, WM_SETFONT, hFont, FALSE
        
        ;#####  Web Hyperlink
        invoke  CreateWindowEx, 
                    NULL, 
                    offset szWndClsStatic, 
                    offset szWebText, 
                    WS_CHILD or WS_VISIBLE or SS_NOTIFY, 
                    76, 60, 
                    137, 17, 
                    hWin, 0, 
                    hInst, 0
        mov     hWeb, eax
        
        ;#####  URL is dif than text, save URL
        invoke  SetWindowLong, eax, GWL_USERDATA, offset szWebURL
        ;#####  Subclass control
        invoke  SetWindowLong, hWeb, GWL_WNDPROC, offset UrlProc
        mov     lpOrgStaticProc, eax
        
        invoke  SendMessage, hWeb, WM_SETFONT, hFont, FALSE
        
        invoke  GetSysColorBrush,COLOR_HIGHLIGHT ; COLOR_3DFACE
        mov     hBrush, eax

	.elseif eax==WM_CTLCOLORSTATIC
		mov     ecx, hEmail
		mov     edx, hWeb
		.if ecx == lParam || edx == lParam
			.if bMouseOver
				mov		eax, Red			
			.else
			    mov     eax, Yellow
			.endif
			invoke  SetTextColor, wParam, eax
			invoke  SetBkMode, wParam, TRANSPARENT
			mov		eax, hBrush
		.endif
		ret
        
    .elseif eax == WM_CLOSE
        invoke  DeleteObject, hFont
        invoke  DeleteObject, hFontUl
        invoke  DeleteObject, hBrush
        invoke  DestroyWindow, hWin
        
    .elseif eax == WM_DESTROY
        invoke  PostQuitMessage, NULL
        
    .else    
        invoke  DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    .endif
    xor     eax, eax
    ret
WndProcMain endp

UrlProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
local   rect:RECT

	mov		eax,uMsg
	.if eax == WM_MOUSEMOVE
	    invoke  GetClientRect, hWin, addr rect
		invoke  GetCapture
		;#####  Make sure the mouse is in our control
		.if eax != hWin
			mov		bMouseOver, TRUE
			invoke  SetCapture, hWin
			invoke  SendMessage, hWin, WM_SETFONT, hFontUl, TRUE
		.endif
		mov		edx,lParam
		movzx	eax,dx
		shr		edx,16
		.if eax > rect.right || edx > rect.bottom
		    ;#####  moved out of control
			mov		bMouseOver, FALSE
			invoke  ReleaseCapture
			invoke  SendMessage, hWin, WM_SETFONT, hFont, TRUE
		.endif

	.elseif eax == WM_LBUTTONUP
		mov		bMouseOver, FALSE
		invoke  ReleaseCapture
		invoke  SendMessage, hWin, WM_SETFONT, hFont, TRUE
		
		;#####  Get URL we stored with the control
		invoke  GetWindowLong, hWin, GWL_USERDATA
		invoke  ShellExecute, hMain, offset szShelOpen, eax, NULL, NULL, SW_SHOWNORMAL

	.elseif eax==WM_SETCURSOR
		invoke  LoadCursor, NULL, IDC_HAND
		invoke  SetCursor, eax
		
	.else
		invoke  CallWindowProc, lpOrgStaticProc, hWin, uMsg, wParam, lParam
		ret
	.endif
	xor		eax,eax
	ret
UrlProc endp

end start