	__UNICODE__ 	equ	1

include \masm32\include\masm32rt.inc

include \masm32\include\gdiplus.inc
; includelib \masm32\lib\gdiplus.lib		;;; add gdiplus.lib to linker/input libraries

include DrawGdiPlussBall.Inc



WinMain proto :DWORD,:DWORD,:DWORD,:DWORD



.data
    ClassName db "MainWinClass",0
    AppName  db "Main Window",0
 
.data?
    g_hInstance HINSTANCE ?
	hMainWindow dd ?
 	hParOf dd ?
 	Optic byte ?
	    ptZero POINT <>

.code
main proc
LOCAL CommandLine:LPSTR 
    invoke GetModuleHandle, NULL
    mov    g_hInstance,eax

    invoke GetCommandLine
    mov    CommandLine,eax
    invoke WinMain, g_hInstance,NULL,CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess,eax
    
main endp

.data?
	bitmap	PVOID ?
	bitmap10	PVOID ?
	Hbitmap	HBITMAP ?
    graphics10 PVOID   ?
.code
MainDraw proc hwnd:DWORD,hWParent:DWORD
LOCAL hdc:HDC,memDC:HDC
LOCAL hBmp:HBITMAP
LOCAL blend:BLENDFUNCTION
LOCAL rect:RECT
    
    mov hdc,rv(GetDC,hWParent)    
 
    invoke GetWindowRect,hwnd,ADDR rect
    mov edx,rect.right
    mov ecx,rect.bottom
    sub edx,rect.left
    sub ecx,rect.top
    mov rect.right,edx
    mov rect.bottom,ecx
    
    
    
    invoke GdipCreateBitmapFromScan0,rect.right,rect.bottom,0,PixelFormat32bppPARGB,0,ADDR bitmap
    invoke GdipGetImageGraphicsContext,bitmap,ADDR graphics10
    ;---------------------------------------------------------
	 
	;invoke DrawRoundRect,graphics10,0,0,399,399,6,1,A_rgb(190,0,0,255),TRUE;	 
	;invoke DrawRoundRect,graphics10,0,0,399,399,6,1,A_rgb(255,255,255,255),FALSE;	 
	

	
	invoke DrawFileImage,graphics10,chr$("agguro.png"),0,0,0,0

 	

;		invoke DrawResImage,graphics10,101,0,0,0,0

	invoke GdipCreateBitmapFromGraphics,rect.right,rect.bottom,graphics10,ADDR bitmap10

	;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    mov blend.BlendOp,AC_SRC_OVER
    mov blend.BlendFlags , 0
    mov blend.AlphaFormat,AC_SRC_ALPHA
    mov blend.SourceConstantAlpha, 255
    
    mov memDC,rv(CreateCompatibleDC,hdc)
    invoke GdipCreateHBITMAPFromBitmap,bitmap,ADDR Hbitmap,0
    mov Hbitmap,rv(SelectObject,memDC,Hbitmap)

    invoke UpdateLayeredWindow,hwnd,0  ,ADDR rect,ADDR rect.right, memDC,addr ptZero, 0,addr blend , ULW_ALPHA

    invoke DeleteObject,rv(SelectObject,memDC,hBmp)
    invoke DeleteDC,memDC
    invoke GdipDisposeImage,bitmap
    ret

MainDraw endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
LOCAL wc:WNDCLASSEX
LOCAL msg:MSG;,W:DWORD,H:DWORD
LOCAL gsi:GdiplusStartupInput
LOCAL gtkn:PULONG

push ecx
mov	ecx, hPrevInst
mov	ecx, CmdLine
mov ecx, CmdShow
pop	ecx

    mov gsi.GdiplusVersion,1
    mov gsi.DebugEventCallback,0
    mov gsi.SuppressBackgroundThread,0
    mov gsi.SuppressExternalCodecs,0
    invoke GdiplusStartup,ADDR gtkn,ADDR gsi,0
    
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,0 ;SIZEOF WND_DATA
    push  g_hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground,0
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    
    invoke RegisterClassEx, addr wc 

    INVOKE CreateWindowEx,WS_EX_LAYERED ,\
            ADDR ClassName,ADDR AppName,\
             WS_VISIBLE or WS_POPUP,0,\
            0 ,700,700,NULL,NULL,\
            hInst,NULL
            
    mov hMainWindow,eax

    .WHILE TRUE
        invoke GetMessage, ADDR msg,NULL,0,0
        .BREAK .IF (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage, ADDR msg
    .ENDW
    
    mov     eax,msg.wParam
    ret
WinMain endp

 
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM


    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_CREATE
    	invoke MainDraw,hWnd,0
   	.elseif	uMsg==WM_KEYDOWN
        invoke PostMessage,hWnd,WM_CLOSE,0,0
	.ELSEIF uMsg==WM_PAINT
 			;invoke MainDraw,hWnd,0
 	.ELSEIF uMsg==WM_RBUTTONDOWN 
         invoke  SendMessage,hWnd,WM_CLOSE,wParam,lParam
    .ELSEIF uMsg==WM_LBUTTONDOWN
         invoke  SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,lParam
     	invoke MainDraw,hWnd,0
    .ELSEIF uMsg==WM_RBUTTONUP
     	invoke MainDraw,hWnd,0
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam        
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp

end main
