; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
;   The control that receives the bitmap image is a ResEd image control which is effectively
;   a STATIC control set to the SS_CENTERIMAGE|SS_BITMAP style so that it can be loaded with
;   a resource bitmap.
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

    .data?
        hInstance dd ?
        hImage    dd ?

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

start:
  ; ------------------------------------------------------------
  ; some Windows versions require the common control library
  ; initialised if a manifest file is included in the resources.
  ; ------------------------------------------------------------
    invoke InitCommonControls

    mov hInstance, rv(GetModuleHandle,NULL)                   ; get the instance handle

  ; ----------------------------------------------
  ; create a dialog from the resource template and
  ; process its messages in the DlgProc procedure.
  ; ----------------------------------------------
    invoke DialogBoxParam,hInstance,1000,0,ADDR DlgProc,0     ; 1000 is the dlg ID in the RC file

    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL hImg  :DWORD

    .if uMsg == WM_INITDIALOG
      invoke SendMessage,hWin,WM_SETICON,1,rv(LoadIcon,NULL,IDI_ASTERISK)

    ; -----------------------------------------------
    ; Get the bitmap handle from the resource section
    ; -----------------------------------------------
      mov hImage, rv(LoadImage,hInstance,100,IMAGE_BITMAP,0,0,LR_DEFAULTSIZE)

    ; ------------------------------------
    ; get the handle for the image control
    ; ------------------------------------
      mov hImg, rv(GetDlgItem,hWin,1001)

    ; ------------------------------------
    ; set the image into the image control
    ; ------------------------------------
      fn PostMessage,hImg,STM_SETIMAGE,IMAGE_BITMAP,hImage

    .elseif uMsg == WM_COMMAND
      .if wParam == 1002            ; the OK button
        jmp quit_dialog
      .endif

    .elseif uMsg == WM_CLOSE
      quit_dialog:
       invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
