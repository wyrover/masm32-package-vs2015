.686
.xmm
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include DlgMain.inc

.code
include gdiplusLoadBitmapFromResource.inc
start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
    ; Initialize GDI+
	invoke	GdiplusStartup, addr gdiplusToken, addr gdiplusSInput, NULL
	
	invoke DialogBoxParam,hInstance,IDD_DIALOG,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################

DlgProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL ps:PAINTSTRUCT
	.if uMsg==WM_INITDIALOG



invoke SetTimer,hWnd,0,100,0
.elseif uMsg == WM_TIMER
	
		invoke	gdiplusLoadBitmapFromResource, hInstance, 5000, addr pngType, addr pngImage
invoke	RedrawCanvas, hWnd
invoke KillTimer,hWnd,0

	.elseif uMsg==WM_CLOSE
; Shutdown GDI+
 invoke	GdipDisposeImage, addr pngImage
	invoke	GdiplusShutdown, gdiplusToken
		invoke EndDialog,hWnd,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret
DlgProc endp

; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Redraw the canvas
; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
RedrawCanvas proc hWnd:HWND
	local	graphics:HANDLE
	local	canvasHwnd:HWND
	local	rect:RECT
	local	whiteBrush:DWORD
	
	invoke	GetDlgItem, hWnd, 9000
	mov		canvasHwnd, eax
	invoke	GetWindowRect, canvasHwnd, addr rect
	invoke	GdipCreateFromHWND, canvasHwnd, addr graphics
	invoke	GdipCreateSolidFill, 0ffffffffh, addr whiteBrush
	invoke	GdipFillRectangleI, graphics, whiteBrush, 0, 0, rect.right, rect.bottom
	invoke	GdipDrawImage, graphics, pngImage, 0, 0
	invoke	GdipDeleteBrush, whiteBrush
	invoke	GdipDeleteGraphics, graphics
	ret
RedrawCanvas endp


end start
