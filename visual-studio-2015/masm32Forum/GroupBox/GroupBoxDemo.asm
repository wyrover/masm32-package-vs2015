; *** minimalistic code to create a window - exactly 100 lines; see also \masm32\examples\exampl01\generic\generic.asm and Iczelion tutorial #3 ***
;useMB=0	 ; put 0 for plain Masm32, 1 for a MasmBasic window ( = Masm32 [url=\Masm32\MasmBasic\MbGuide.rtf]plus 200+ macros[/url])
;if useMB	; window with advanced functionality (search this document for useMB to see details)
;	 include \masm32\MasmBasic\MasmBasic.inc	; [url=http://masm32.com/board/index.php?topic=94.0]download[/url]
;else	 ; simple Masm32 window: this line sets defaults and includes frequently used libraries (Kernel32, User32, CRT, ...)
	 include \masm32\include\Masm32rt.inc
;	 deb MACRO args:VARARG
;	 ENDM
;endif

.data	; initialised data section
	MyWinStyle = CS_HREDRAW or CS_VREDRAW or CS_OWNDC	;#? see [url=http://blogs.msdn.com/b/oldnewthing/archive/2006/06/01/612970.aspx]pros and cons of CS_OWNDC[/url]
wcx	WNDCLASSEX <WNDCLASSEX, MyWinStyle, WndProc, 0, 0, 1, 2, 3, COLOR_BTNFACE+1, 0, txClass, 4>
txClass	db "MyWinClass", 0		; class name, will be registered below
.data?	; uninitialised data - use for handles etc
hEdit	dd ?
pFilename	dd ?
.code
WinMain proc uses ebx		; this is the application's entry point
LOCAL msg:MSG
  mov ebx, offset wcx
  wc equ [ebx.WNDCLASSEX]		; we use an equate for better readability
  mov wc.hInstance, rv(GetModuleHandle, 0)		;#? rv ("return value") is a Masm32 macro
  mov wc.hIcon, rv(LoadIcon, eax, IDI_APPLICATION)	;#? OPT_Icon Globe
  mov wc.hIconSm, eax		;#? the rv macro returns results in eax
  mov wc.hCursor, rv(LoadCursor, NULL, IDC_ARROW)
  invoke RegisterClassEx, addr wc		;#? the window class needs to be registered
  invoke CreateWindowEx, NULL, wc.lpszClassName, chr$("Hello World"),	;#? set window title here
	WS_OVERLAPPEDWINDOW or WS_VISIBLE,
	400, 320, 530, 280,		; window position: x, y, width, height
	NULL, NULL, wc.hInstance, NULL
  .While 1
	invoke GetMessage, ADDR msg, NULL, 0, 0
	.Break .if !eax
	invoke TranslateMessage, ADDR msg
	invoke DispatchMessage, ADDR msg
  .Endw
  exit msg.wParam
WinMain endp

WndProc proc uses esi edi ebx hWnd, uMsg, wParam:WPARAM, lParam:LPARAM
LOCAL hg1, hg2
;if useMB eq 2		; to use the monitoring, set useMB=2 above; you need a console
;	inc msgCount	;#? to see messages, therefore delete the x in OxPT_Susy Console
;	deb 4, "msg", chg:msgCount	; this console deb will only be shown if chg:somevar has changed
;endif
  SWITCH uMsg
  CASE WM_CREATE	; this message serves to initialise your application
	mov esi, rv(CreateMenu)	;#? create the main menu
	mov edi, rv(CreateMenu)	;#? create a sub-menu
	invoke AppendMenu, esi, MF_POPUP, edi, chr$("&File")		;#? add it to the main menu
	invoke AppendMenu, edi, MF_STRING, 101, chr$("&New")		;#? and add
	invoke AppendMenu, edi, MF_STRING, 102, chr$("&Save")		;#? two items
	invoke SetMenu, hWnd, esi				;#? attach menu to main window
	
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("edit"), NULL, WS_CHILD or WS_VISIBLE or WS_BORDER or WS_VSCROLL or ES_MULTILINE, eax, eax, eax, eax, hWnd, 103, wcx.hInstance, NULL		; we have added an edit control
	mov hEdit, eax			;#? you may need this global variable for further processing
	
	xchg eax, ebx			;#1 use a persistent register for the handle
	invoke SendMessage, ebx, WM_SETFONT, rv(GetStockObject, ANSI_FIXED_FONT), 0	;#? SYSTEM_FIXED_FONT is bold and larger

	; TEST Agguro
	;;invoke CreateWindowEx, 0, chr$("button"), NULL, BS_GROUPBOX or WS_CHILD or WS_VISIBLE, 1, 1, 104, 88, hWnd, 104, wcx.hInstance, NULL		; we have added an edit control
	  
	invoke CreateWindowEx, 0, chr$("button"), chr$("button"), BS_GROUPBOX or WS_CHILD or WS_VISIBLE, 1, 1, 104, 88, hWnd, 108, wcx.hInstance, NULL		; we have added an edit control
	mov hg1, eax
	invoke SendMessage, hg1, WM_SETFONT,rv(GetStockObject, ANSI_VAR_FONT), 0	;#? SYSTEM_FIXED_FONT is bold and larger

	; END TEST Agguro

;	  deb 4, "G1", eax, $Err$()
	;invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("button"), NULL, BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE, 7, 17, 90, 20, hg1, 105, wcx.hInstance, NULL		; we have added an edit control
	;invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("button"), NULL, BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE, 7, 37+2, 90, 20, hg1, 106, wcx.hInstance, NULL		; we have added an edit control
	;invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("button"), NULL, BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE, 7, 57+4, 90, 20, hg1, 107, wcx.hInstance, NULL		; we have added an edit control

	
	invoke CreateWindowEx, 0, chr$("button"), NULL, BS_GROUPBOX or WS_CHILD or WS_VISIBLE, 1, 1+100, 104, 88, hWnd, 108, wcx.hInstance, NULL		; we have added an edit control
;	  deb 4, "G2", eax, $Err$()
	  mov hg2, eax
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("button"), NULL, BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE, 7, 17, 90, 20, hg2, 109, wcx.hInstance, NULL		; we have added an edit control
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("button"), NULL, BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE, 7, 37+2, 90, 20, hg2, 110, wcx.hInstance, NULL		; we have added an edit control
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("button"), NULL, BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE, 7, 57+4, 90, 20, hg2, 110, wcx.hInstance, NULL		; we have added an edit control

	invoke SetFocus, ebx			;#? make sure you can start typing right away

; BS_AUTORADIOBUTTON
; BS_GROUPBOX Creates a rectangle in which other controls can be grouped. Any text associated with this style is displayed in the rectangle's upper left corner.

  CASE WM_SIZE	; adjust shape of edit control to main window
	movzx eax, word ptr lParam	;#? width of client area
	movzx edx, word ptr lParam+2	;#? height
	sub eax, 117
	sub edx, 7
	invoke MoveWindow, hEdit, 107, 0, eax, edx, 1
  CASE WM_PARENTNOTIFY	; react to menu clicks
	movzx eax, word ptr wParam+2	;#? the Ids are in the LoWord of wParam
;	deb 4, "ID", eax, lParam
  CASE WM_COMMAND	; react to menu clicks
	movzx eax, word ptr wParam	;#? the Ids are in the LoWord of wParam
	Switch eax
	case 101
		;if useMB	; fill editbox with output from a dir command
		;	Launch "cmd.exe /C dir /S /B \Masm32\Examples\*.asm", SW_HIDE, cb:hEdit
		;else		; show a simple messagebox
			MsgBox 0, "You clicked New", "Hi", MB_OK
		;endif
	case 102
		;if useMB	; save contents of edit control to file
		;	.if !pFilename
		;		.if FileSave$("Source=*.asm|Text=*.txt", "Save content:")
		;		    Let pFilename=FileSave$()
		;		.endif
		;	.endif
		;	.if pFilename
		;		FileWrite pFilename, Win$(hEdit)
		;	.endif
		;else		; show a messagebox
			MsgBox 0, "You clicked Save", "Hi", MB_OK
		;endif
	Endsw
  CASE WM_DESTROY	; quit after WM_CLOSE
	invoke PostQuitMessage, NULL
  CASE WM_CLOSE	; decide whether to close or not
	;ife useMB
	;	MsgBox 0, "Sure to close?", "Hi", MB_YESNO
	;	sub eax, IDNO
	;	je @RetEax	;#2 return eax, in this case zero (i.e. refuse to close)
	;endif
  ENDSW
  invoke DefWindowProc, hWnd, uMsg, wParam, lParam	;#? default processing
@RetEax:
  ret
WndProc endp
end WinMain
;OPT_Susy	Console
;OPT_Wait	0
;OPT_Tmp2Asm	1
