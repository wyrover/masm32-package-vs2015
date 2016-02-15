; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

  include \masm32\include\masm32rt.inc

  DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

  ; --------------------------------------------------------------------
  ; allocate space for GLOBAL handles in the UN-initialised data section
  ; --------------------------------------------------------------------
  .data?
      hInstance dd ?
      hStatic1  dd ?

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

    switch uMsg

      case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,rv(LoadIcon,NULL,IDI_ASTERISK)

      ; -------------------------------------
      ; get the Window HANDLE for the control
      ; -------------------------------------
        mov hStatic1, rv(GetDlgItem,hWin,1015)

        fn SendMessage,rv(GetDlgItem,hWin,1002),BM_SETCHECK,BST_CHECKED,0
        fn SetWindowText,hStatic1,"Radio button one is set by default"

      case WM_COMMAND
        ; ----------------------------------------------------
        ; each control is identified by its resource ID number
        ; set in the resource script file (RC file).
        ; ----------------------------------------------------

        ; ---------------------
        ; process radio buttons
        ; ---------------------
        .if wParam == 1002
          fn SetWindowText,hStatic1,"Radio button one here"

        .elseif wParam == 1003
          fn SetWindowText,hStatic1,"Radio button number two"

        .elseif wParam == 1004
          fn SetWindowText,hStatic1,"The third Radio button"

        .elseif wParam == 1005
          fn SetWindowText,hStatic1,"Radio button four was clicked"

        ; -------------------
        ; process check boxes
        ; -------------------
        .elseif wParam == 1007
          fn SetWindowText,hStatic1,"Check box one was clicked"

        .elseif wParam == 1008
          fn SetWindowText,hStatic1,"You clicked on check box two"

        .elseif wParam == 1009
          fn SetWindowText,hStatic1,"Check box three was clicked"

        .elseif wParam == 1010
          fn SetWindowText,hStatic1,"Check box four was clicked"

        ; --------------------
        ; process push buttons
        ; --------------------
        .elseif wParam == 1011
          fn SetWindowText,hStatic1,"You clicked button one"

        .elseif wParam == 1012
          fn SetWindowText,hStatic1,"You clicked button two"

        .elseif wParam == 1013
          fn SetWindowText,hStatic1,"You clicked button three"

        .elseif wParam == 1014      ; *** the Close Button ***
          jmp quit_dialog
        .endif

      case WM_CLOSE
        quit_dialog:
         invoke EndDialog,hWin,0    ; terminate dialog with this API.

    endsw

    xor eax, eax
    ret

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
