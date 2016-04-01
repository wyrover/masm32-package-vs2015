goasm /l except2.lst except2.asm
gorc /r except2.rc
goLink except2.obj except2.res /debug coff /console kernel32.dll user32.dll gdi32.dll
