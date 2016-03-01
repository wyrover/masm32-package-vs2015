
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include advapi32.inc


includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib advapi32.lib

include gdiplus.inc
includelib gdiplus.lib
include ole32.inc
includelib ole32.lib
gdiplusLoadBitmapFromResource proto :HMODULE, :LPSTR, :LPSTR, :DWORD

GdiplusStartupInput struc
    GdiplusVersion 				dd ?
    DebugEventCallback 			dd ?
    SuppressBackgroundThread 	BOOL ?
    SuppressExternalCodecs		BOOL ?
GdiplusStartupInput ends

CTEXT macro Text
    local szText
    .data
    szText byte Text, 0
    .code
    exitm <offset szText>   
endm

DlgProc			 PROTO	:HWND,:UINT,:WPARAM,:LPARAM
RedrawCanvas PROTO	:HWND



.const

IDD_DIALOG		  equ 1000



;#########################################################################
.data
gdiplusToken	dd ?
	gdiplusSInput	GdiplusStartupInput <1, NULL, FALSE, FALSE>
	
	pngImage		dd NULL
	pngType			db "RT_RCDATA", 0
	drawPng			BOOL FALSE
.data?
hDlg2 dd ?
hInstance		  dd ?

;#########################################################################

