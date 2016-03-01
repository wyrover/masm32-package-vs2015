cls
set masm64_path=\masm64\
set filename=win_25a
%masm64_path%bin\RC /r  %filename%.rc || exit
%masm64_path%bin\ml64 /Cp /c /I"%masm64_path%Include" %filename%.asm || exit
%masm64_path%bin\link /SUBSYSTEM:WINDOWS /LIBPATH:"%masm64_path%Lib" ^
/entry:WinMain %filename%.obj %filename%.res /LARGEADDRESSAWARE:NO ^
/ALIGN:16 /SECTION:.text,W ^
/BASE:0x400000 /STUB:%masm64_path%\bin\stubby.exe || exit
del %filename%.res
del %filename%.obj