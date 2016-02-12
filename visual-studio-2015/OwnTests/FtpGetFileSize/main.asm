    include \masm32\include\masm32rt.inc
    include \masm32\include\urlmon.inc
	include \masm32\include\windows.inc
	include \masm32\include\wininet.inc
	includelib wininet.lib
	includelib \masm32\lib\urlmon.lib

	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/aa384166%28v=vs.85%29.aspx

	
	.data
		; *** InternetOpen
		hInternet	dd 0
		lpszAgent	db "ftp",0
		; dwAccessType	=	INTERNET_OPEN_TYPE_DIRECT
		; lpszProxyName	= 0
		; lpszProxyBypass = 0
		; dwFlags		=	0
		
		; *** InternetConnect
		host	db	"ftp.agguro.org", 0
		port	dd	21
		username	db	"ftpagguro", 0
		password	db	"Es661026$", 0
		hConnection	dd 0
		; flag = 0 or INTERNET_FLAG_PASSIVE

		; *** FtpOpenFile
		remoteFile	db	"wwwroot/test.txt", 0
		; dwAccess	=	GENERIC_READ (to write use GENERIC_WRITE but not both)
		; dwFlags = FTP_TRANSFER_TYPE_BINARY or INTERNET_FLAG_HYPERLINK
		; dwContext = 0
		; *** FtpOpenFile
		hFile	dd	0
				
		fSize	dd	0
		buffer	db	1024 dup (0)
		bufferlength dd	1024
		error   dd  0

		context		dd	0		; for internet callback function

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main

    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

	push	0
	push	0
	push	0
	push	INTERNET_OPEN_TYPE_DIRECT
	push	offset lpszAgent
	call	InternetOpen
	mov		hInternet, eax

	push	offset CallBack
	push	hInternet
	call	InternetSetStatusCallback

	push	0
	push	INTERNET_FLAG_PASSIVE
	push	INTERNET_SERVICE_FTP
	push	offset password
	push	offset username
	push	INTERNET_DEFAULT_FTP_PORT
	push	offset host
	push	hInternet
	call	InternetConnect
	mov		hConnection, eax

	;call	GetLastError
	;push	1024
	;push	offset buffer
	;push	eax
	;call InternetGetLastResponseInfo


	push	offset context
	push	FTP_TRANSFER_TYPE_UNKNOWN
	push	GENERIC_READ
	push	offset remoteFile
	push	hConnection
	call	FtpOpenFile
	mov		hFile, eax
	nop

	call	GetLastError
	mov     error, eax
	push	offset bufferlength
	lea		eax, buffer
	push	offset buffer
	push	offset error
	call InternetGetLastResponseInfo

	push	0
	push	hFile
	call	FtpGetFileSize
    mov		fSize, eax
	
	print	"FILESIZE RECEIVED IN EAX", 10, 13

	push	hFile
	call	InternetCloseHandle

	push	hConnection
	call	InternetCloseHandle


	ret

main endp

CallBack proc HInternet:dword, dwContext:dword, internetStatus:dword, statusInformation:dword, statusInformationLength:dword
	mov		eax, internetStatus
	;mov		eax, [eax]
	cmp		eax, INTERNET_STATUS_CLOSING_CONNECTION
	jne		_connected
		; Closing the connection to the server. The lpvStatusInformation parameter is NULL.
	print "Closing the connection to the server. ",10,13,0
	jmp		_endcallback
_connected:
	cmp		eax, INTERNET_STATUS_CONNECTED_TO_SERVER
	jne		_connecting
		; Successfully connected to the socket address (SOCKADDR) pointed to by lpvStatusInformation.
	print	"Successfully connected.",10,13,0
	jmp		_endcallback
_connecting:
	cmp		eax, INTERNET_STATUS_CONNECTING_TO_SERVER
	jne		_closed
		; Connecting to the socket address (SOCKADDR) pointed to by lpvStatusInformation.
	print	"connecting...",10,13,0
	jmp		_endcallback
_closed:
	cmp		eax, INTERNET_STATUS_CONNECTION_CLOSED
	jne		_cookie_history
		; Successfully closed the connection to the server. The lpvStatusInformation parameter is NULL.
	print	"Successfully closed the connection to the server.",10,13,0
	jmp		_endcallback
_cookie_history:
	cmp		eax, INTERNET_STATUS_COOKIE_HISTORY
	jne		_cookie_received
		; Retrieving content from the cache. Contains data about past cookie events for the URL such as if cookies were accepted, rejected, downgraded, or leashed. 
		; The lpvStatusInformation parameter is a pointer to an InternetCookieHistory structure.
	print	"Retrieving content from the cache.",10,13,0
	jmp		_endcallback
_cookie_received:
	cmp		eax, INTERNET_STATUS_COOKIE_RECEIVED
	jne		_cookie_sent
		; Indicates the number of cookies that were accepted, rejected, downgraded (changed from persistent to session cookies), or leashed (will be sent out only in 1st party context).
		; The lpvStatusInformation parameter is a DWORD with the number of cookies received.
	print	"Cookies were accepted, rejected, downgraded (changed from persistent to session cookies), or leashed.",10,13,0
	jmp		_endcallback
_cookie_sent:
	cmp		eax, INTERNET_STATUS_COOKIE_SENT
	jne		_proxy_detected
		; Indicates the number of cookies that were either sent or suppressed, when a request is sent.
		; The lpvStatusInformation parameter is a DWORD with the number of cookies sent or suppressed.
	print	"Cookies that were either sent or suppressed",10,13,0
	jmp		_endcallback

					_ctl_response_received:
						cmp		eax, INTERNET_STATUS_CTL_RESPONSE_RECEIVED
						jne		_proxy_detected
						; Not implemented.
						print"ctl response received. (not implemented)",10,13,0
						jmp		_endcallback
	
_proxy_detected:	
	cmp		eax, INTERNET_STATUS_DETECTING_PROXY
	jne		_handle_closing
	; Notifies the client application that a proxy has been detected.
	print	"A proxy has been detected.",10,13,0
	jmp		_endcallback 
_handle_closing:
	cmp		eax, INTERNET_STATUS_HANDLE_CLOSING
	jne		_handle_created
	; This handle value has been terminated. pvStatusInformation contains the address of the handle being closed.
	; The lpvStatusInformation parameter contains the address of the handle being closed.
	print	"This handle value has been terminated.",10,13,0
	jmp		_endcallback
_handle_created:
	cmp		eax, INTERNET_STATUS_HANDLE_CREATED
	jne		_status_code_received
	; Used by InternetConnect to indicate it has created the new handle.
	; This lets the application call InternetCloseHandle from another thread, if the connect is taking too long.
	; The lpvStatusInformation parameter contains the address of an HINTERNET handle.
	print	"New handle created",10,13,0
	jmp		_endcallback
_status_code_received:
	cmp		eax, INTERNET_STATUS_INTERMEDIATE_RESPONSE
	jne		_name_resolved
	; Received an intermediate (100 level) status code message from the server.
	print	"intermediate (100 level) status code message received from server",10,13,0
	jmp		_endcallback
_name_resolved:
	cmp		eax, INTERNET_STATUS_NAME_RESOLVED
	jne		_p3p_header
	; Successfully found the IP address of the name contained in lpvStatusInformation. The lpvStatusInformation parameter points to a PCTSTR containing the host name.
	print	"Successfully found the IP address",10,13,0
	jmp		_endcallback
_p3p_header:
	cmp		eax, INTERNET_STATUS_P3P_HEADER
	jne		_receiving_response
	; The response has a P3P header in it.
	print	"The response has a P3P header in it.",10,13,0
	jmp		_endcallback

					_p3p_policyref:
						cmp		eax, INTERNET_STATUS_P3P_POLICYREF
						jne		_status_prefetch
						; Not implemented.
						print"p3p policy ref (not implemented)",10,13,0
						jmp		_endcallback
					_status_prefetch:
						cmp		eax, INTERNET_STATUS_PREFETCH
						jne		_privacy_impacted
						; Not implemented.
						print"Prefetch. (not implemented)",10,13,0
						jmp		_endcallback
					_privacy_impacted:
						cmp		eax, INTERNET_STATUS_PRIVACY_IMPACTED
						jne		_receiving_response 
						; Not implemented.
						print"Receiving response. (not implemented)",10,13,0
						jmp		_endcallback

_receiving_response:
	cmp		eax, INTERNET_STATUS_RECEIVING_RESPONSE
	jne		_redirect
	; Waiting for the server to respond to a request. The lpvStatusInformation parameter is NULL.
	print	"Waiting for server",10,13,0
	jmp		_endcallback
_redirect:
	cmp		eax, INTERNET_STATUS_REDIRECT
	jne		_request_complete
	; An HTTP request is about to automatically redirect the request.
	; The lpvStatusInformation parameter points to the new URL. At this point, the application can read any data returned by the server with the redirect response and can query the response headers.
	; It can also cancel the operation by closing the handle. This callback is not made if the original request specified INTERNET_FLAG_NO_AUTO_REDIRECT.
	print	"Redirecting...",10,13,0
	jmp		_endcallback
_request_complete:
	cmp		eax, INTERNET_STATUS_REQUEST_COMPLETE
	jne		_request_sent
	; An asynchronous operation has been completed. The lpvStatusInformation parameter contains the address of an INTERNET_ASYNC_RESULT structure.
	print	"asynchronous operation has been completed.",10,13,0
	jmp		_endcallback
_request_sent:
	cmp		eax, INTERNET_STATUS_REQUEST_SENT
	jne		_resolving_name
	; Successfully sent the information request to the server. The lpvStatusInformation parameter points to a DWORD value that contains the number of bytes sent.
	print	"Successfully sent the information request to the server.",10,13,0
	jmp		_endcallback
_resolving_name:
	cmp		eax, INTERNET_STATUS_RESOLVING_NAME
	jne		_response_received
	; Looking up the IP address of the name contained in lpvStatusInformation. The lpvStatusInformation parameter points to a PCTSTR containing the host name.
	print	"Looking up the IP address of the name.",10,13,0
	jmp		_endcallback
_response_received:
	cmp		eax, INTERNET_STATUS_RESPONSE_RECEIVED
	jne		_sending_request
	; Successfully received a response from the server. 
	print	"Successfully received a response from the server.",10,13,0
	jmp		_endcallback
_sending_request:
	cmp		eax, INTERNET_STATUS_SENDING_REQUEST
	jne		_state_change
	; Sending the information request to the server. The lpvStatusInformation parameter is NULL.
	print	"Sending the information request to the server.",10,13,0
	jmp		_endcallback
_state_change:
	cmp		eax, INTERNET_STATUS_STATE_CHANGE
	jne		_endcallback						; in case we forgot something
	; Moved between a secure (HTTPS) and a nonsecure (HTTP) site. The user must be informed of this change
	; otherwise, the user is at risk of disclosing sensitive information involuntarily.
	; When this flag is set, the lpvStatusInformation parameter points to a status DWORD that contains additional flags.
	print	"!!! Moved between a secure (HTTPS) and a nonsecure (HTTP) site. !!!",10,13,0
	mov		eax, statusInformation
	mov		eax, [eax]
	cmp		eax, INTERNET_STATE_CONNECTED	;Connected state. Mutually exclusive with disconnected state.
	print	"Connected. ",10,13,0
	jmp		_endcallback
	cmp		eax, INTERNET_STATE_DISCONNECTED ;Disconnected state. No network connection could be established.
	print	"Disconnected. ",10,13,0
	jmp		_endcallback
	cmp		eax, INTERNET_STATE_DISCONNECTED_BY_USER  ; Disconnected by user request.
	print	"Disconnected by user request. ",10,13,0
	jmp		_endcallback
	cmp		eax, INTERNET_STATE_IDLE	; No network requests are being made by Windows Internet.
 	print	"Idle. ",10,13,0
	jmp		_endcallback
	cmp		eax, INTERNET_STATE_BUSY	; Network requests are being made by Windows Internet.
 	print	"Busy. ",10,13,0
	jmp		_endcallback
	cmp		eax, INTERNET_STATUS_USER_INPUT_REQUIRED ; The request requires user input to be completed.
	print	"User input required. ",10,13,0
_endcallback:
	ret

CallBack endp

end start
