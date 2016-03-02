	.code
	DrawResImage PROC USES  ecx edx ebx esi edi  Graphic__:dword,IdRes:dword,X_:DWORD,Y_:DWORD,W_:DWORD,H_:DWORD
		LOCAL _rcRes,_hResData,_sizeOfRes,_hbuffer,_pIStream,_hBitmap

		mov	ecx, _hbuffer
		
		invoke  FindResource	, 0, IdRes, RT_RCDATA
		.if eax
			mov _rcRes, 	eax
			mov _hResData, 	rv(LoadResource		, 0, _rcRes)
			mov _sizeOfRes, rv(SizeofResource	, 0, _rcRes)

			invoke  CreateStreamOnHGlobal, 0, TRUE, addr _pIStream  
			xor 	eax,eax
			push 	eax
			push 	_sizeOfRes
			push 	_hResData
			mov  	edx,_pIStream
			push  	edx
			mov   	edx,[edx]
			call  	dword ptr [edx + 16] 
			invoke  GdipCreateBitmapFromStream, _pIStream,addr _hBitmap
			.if W_
				invoke 	GdipDrawImageRectI	,Graphic__, _hBitmap,X_, Y_ ,W_,H_
			.else
				invoke 	GdipDrawImage		,Graphic__, _hBitmap,X_, Y_ 
			.endif
			invoke GdipDisposeImage,_hBitmap
			mov   edx,_pIStream
			push  edx
			mov   edx,[edx]
			call  dword ptr [edx + 8] 
			mov eax,TRUE
		.else
			xor eax,eax	
		.endif
		ret
	DrawResImage endp		
	DrawFileImage PROC USES  ecx edx ebx esi edi  Graphic__:dword,FileN:dword,X_:DWORD,Y_:DWORD,W_:DWORD,H_:DWORD
		LOCAL _hBitmap
		
		invoke 	GdipCreateBitmapFromFile,FileN,addr _hBitmap 
		.if _hBitmap
			.if W_
				invoke 	GdipDrawImageRectI	,Graphic__, _hBitmap,X_, Y_ ,W_,H_
			.else
				invoke 	GdipDrawImage		,Graphic__, _hBitmap,X_, Y_ 
			.endif
			invoke GdipDisposeImage,_hBitmap
			mov eax,TRUE
		.else
			xor eax,eax	
		.endif
		ret
	DrawFileImage endp		

	A_rgb MACRO a,r,g,b
		  ifndef Argb____1
		
		ARGB2__ UNION
		    D DWORD ?
		    STRUCT
		      B BYTE ?
		      G BYTE ?
		      R BYTE ?
		      A BYTE ?
		    ENDS
		ARGB2__ ENDS
		  
		  .data
		    Argb____1	ARGB2__	<>	
		    align 4
		  .code
		  endif
				mov ah,a
				mov Argb____1.A,ah
				mov ah,r
				mov Argb____1.R,ah
				mov ah,g
				mov Argb____1.G,ah
				mov ah,b
				mov Argb____1.B,ah
		  EXITM <Argb____1.D>
	ENDM		


	SubS proc X:dword,Y:dword
			mov eax,X
			sub eax,Y
		ret
	SubS endp
	AddS proc X:dword,Y:dword
			mov eax,X
			add eax,Y
		ret
	AddS endp
	DrawRoundRect proc graphics:dword,X:dword,\
									  Y:dword,\
									  WIDTH_:dword,\
									  HEIGHT_:dword,\
									  ROUND_:dword,\
									  STCK_:dword,\
									  COLOR_:dword,\
									  Fill_:byte
	LOCAL x1:DWORD,y1:DWORD,x2:DWORD,y2:DWORD
	LOCAL XW:DWORD,YH:DWORD,RR:DWORD
	LOCAL pen:DWORD,path:dword,brush:dword
	
	        Invoke GdipCreatePen1,COLOR_, STCK_, 0, Addr pen	;FP4(1.0)
			invoke GdipCreatePath,FillModeAlternate,ADDR path
			
			mov eax,rv(AddS,X,ROUND_)
			mov x1,eax
			mov eax,rv(AddS,X,WIDTH_)
			mov XW,eax		
			mov eax,rv(SubS,WIDTH_,ROUND_)
			add eax,X
			mov x2,eax
			mov eax,rv(AddS,Y,ROUND_)
			mov y1,eax		
			mov eax,rv(AddS,Y,HEIGHT_)
			mov YH,eax		
			mov eax,rv(SubS,HEIGHT_,ROUND_)
			add eax,Y
			mov y2,eax
			
			.if ROUND_ == 0
				invoke GdipAddPathLineI,path,x1,Y,x2,Y		
				invoke GdipAddPathLineI,path,XW,y1,XW,y2			
				invoke GdipAddPathLineI,path,x2,YH,x1,YH			
			.endif
			invoke GdipAddPathLineI,path,X,y2,X,y1			
	
			mov eax,rv(AddS,y1,ROUND_)
			add eax,1
			mov y1,eax
			
			mov eax,rv(AddS,x1,ROUND_)
			add eax,1
			mov x1,eax
			
			mov eax,rv(SubS,x2,ROUND_)
			sub eax,1
			add eax,1;++++++++++++++++++
			mov x2,eax
			
			mov eax,rv(SubS,y2,ROUND_)
			sub eax,1
			add eax,1;++++++++++++++++++
			mov y2,eax
			
			mov eax,rv(AddS,ROUND_,ROUND_)
			mov RR,eax
			
			invoke GdipAddPathArcI,path,X,Y,RR,RR,FP4(180.0),FP4(90.0) 
			invoke GdipAddPathArcI,path,x2,Y,RR,RR,FP4(270.0),FP4(90.0) 
			invoke GdipAddPathArcI,path,x2,y2,RR,RR,FP4(0.0),FP4(90.0) 
			invoke GdipAddPathArcI,path,X,y2,RR,RR,FP4(90.0),FP4(90.0) 
			.if Fill_
				invoke GdipCreateSolidFill,COLOR_,ADDR brush;ARGB_(130,255,0 ,  255)
				invoke GdipFillPath,graphics,brush,path
				invoke GdipDeleteBrush,brush	
			.endif
			.if STCK_ == 0
			.else
				invoke GdipDrawPath,graphics,pen,path			
			.endif
			
			invoke GdipDeletePen,pen
			invoke GdipDeletePath,path
	
		ret
	DrawRoundRect endp

 
