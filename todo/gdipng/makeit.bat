@echo off

set path=d:\masm32

%path%\bin\rc /v "dlgmain.Rc"

%path%\bin\ml /c /coff /Cp /I"%path%\Include" "dlgmain.Asm"

%path%\bin\link /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /LIBPATH:"%path%\Lib" /OUT:"dlgmain.exe" "dlgmain.obj"  "dlgmain.res"
pause
