IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    This example is a very simple dialog that uses a RC script file created with the ResEd
    dialog editor.

    It has both a manifest file loaded in the RC script and a version control block so that
    the application is compatible with later versions of Windows.

    NOTE that this example is a MODAL dialog that has no parent window.

    ALSO NOTE : This example uses the direct resource item's numbers, no the equates. This is
                done to simplify this source file by not requiring additional MASM equates to
                match the C equates in the RC script.
                1000 is the ID number of the main dialog.
                1002 is the ID number of the button in the dialog

                The ID for the STATIC control 1001 is unused in this example

ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

    .data?
        hInstance dd ?

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

start:
    ; ----------------------------------------
    ; get the instance handle for THIS process
    ; ----------------------------------------
      mov hInstance, rv(GetModuleHandle,NULL)

    ; ----------------------------------------------------------
    ; display the dialog and pass control to its message handler
    ; ----------------------------------------------------------
      invoke DialogBoxParam,hInstance,1000,0,ADDR DlgProc,0     ; 1000 is the dlg ID in the RC file

    ; -----------------------------------------------------------
    ; terminate the process when the dialog message handler exits
    ; -----------------------------------------------------------
      invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    switch uMsg

      case WM_INITDIALOG
      ; -------------------------
      ; set an icon to the dialog
      ; -------------------------
        invoke SendMessage,hWin,WM_SETICON,1,rv(LoadIcon,NULL,IDI_ASTERISK)

      ; ---------------------------------------------------------------
      ; process the WM_COMMAND message sent by the button in the dialog
      ; ---------------------------------------------------------------
      case WM_COMMAND
        .if wParam == 1002          ; this is the ID for the OK button
          jmp quit_dialog
        .endif

      case WM_CLOSE
        quit_dialog:
         invoke EndDialog,hWin,0    ; this is how the dialog exits

    endsw

    xor eax, eax                    ; this MUST be zero
    ret

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
