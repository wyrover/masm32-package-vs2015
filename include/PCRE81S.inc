;*************************************************
;*      Perl-Compatible Regular Expressions      *
;*************************************************
;
;This is the public header file for the PCRE library, to be #included by
;applications that call the PCRE functions.
;
;           Copyright (c) 1997-2010 University of Cambridge
;
;-----------------------------------------------------------------------------
;Redistribution and use in source and binary forms, with or without
;modification, are permitted provided that the following conditions are met:
;
;    * Redistributions of source code must retain the above copyright notice,
;      this list of conditions and the following disclaimer.
;
;    * Redistributions in binary form must reproduce the above copyright
;      notice, this list of conditions and the following disclaimer in the
;      documentation and/or other materials provided with the distribution.
;
;    * Neither the name of the University of Cambridge nor the names of its
;      contributors may be used to endorse or promote products derived from
;      this software without specific prior written permission.
;
;THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;POSSIBILITY OF SUCH DAMAGE.
;-----------------------------------------------------------------------------


;The current PCRE version information.

PCRE_MAJOR        equ   8
PCRE_MINOR        equ   10
PCRE_DATE         equ   2010-06-25


;Options. Some are compile-time only, some are run-time only, and some are
;both, so we keep them all distinct.

PCRE_CASELESS             equ   00000001h
PCRE_MULTILINE            equ   00000002h
PCRE_DOTALL               equ   00000004h
PCRE_EXTENDED             equ   00000008h
PCRE_ANCHORED             equ   00000010h
PCRE_DOLLAR_ENDONLY       equ   00000020h
PCRE_EXTRA                equ   00000040h
PCRE_NOTBOL               equ   00000080h
PCRE_NOTEOL               equ   00000100h
PCRE_UNGREEDY             equ   00000200h
PCRE_NOTEMPTY             equ   00000400h
PCRE_UTF8                 equ   00000800h
PCRE_NO_AUTO_CAPTURE      equ   00001000h
PCRE_NO_UTF8_CHECK        equ   00002000h
PCRE_AUTO_CALLOUT         equ   00004000h
PCRE_PARTIAL_SOFT         equ   00008000h
PCRE_PARTIAL              equ   00008000h     ;Backwards compatible synonym
PCRE_DFA_SHORTEST         equ   00010000h
PCRE_DFA_RESTART          equ   00020000h
PCRE_FIRSTLINE            equ   00040000h
PCRE_DUPNAMES             equ   00080000h
PCRE_NEWLINE_CR           equ   00100000h
PCRE_NEWLINE_LF           equ   00200000h
PCRE_NEWLINE_CRLF         equ   00300000h
PCRE_NEWLINE_ANY          equ   00400000h
PCRE_NEWLINE_ANYCRLF      equ   00500000h
PCRE_BSR_ANYCRLF          equ   00800000h
PCRE_BSR_UNICODE          equ   01000000h
PCRE_JAVASCRIPT_COMPAT    equ   02000000h
PCRE_NO_START_OPTIMIZE    equ   04000000h
PCRE_NO_START_OPTIMISE    equ   04000000h
PCRE_PARTIAL_HARD         equ   08000000h
PCRE_NOTEMPTY_ATSTART     equ   10000000h
PCRE_UCP                  equ   20000000h


;Exec-time and get/set-time error codes

PCRE_ERROR_NOMATCH        equ   (-1)
PCRE_ERROR_NULL           equ   (-2)
PCRE_ERROR_BADOPTION      equ   (-3)
PCRE_ERROR_BADMAGIC       equ   (-4)
PCRE_ERROR_UNKNOWN_OPCODE equ   (-5)
PCRE_ERROR_UNKNOWN_NODE   equ   (-5)  ;For backward compatibility
PCRE_ERROR_NOMEMORY       equ   (-6)
PCRE_ERROR_NOSUBSTRING    equ   (-7)
PCRE_ERROR_MATCHLIMIT     equ   (-8)
PCRE_ERROR_CALLOUT        equ   (-9)  ;Never used by PCRE itself
PCRE_ERROR_BADUTF8        equ  (-10)
PCRE_ERROR_BADUTF8_OFFSET equ  (-11)
PCRE_ERROR_PARTIAL        equ  (-12)
PCRE_ERROR_BADPARTIAL     equ  (-13)
PCRE_ERROR_INTERNAL       equ  (-14)
PCRE_ERROR_BADCOUNT       equ  (-15)
PCRE_ERROR_DFA_UITEM      equ  (-16)
PCRE_ERROR_DFA_UCOND      equ  (-17)
PCRE_ERROR_DFA_UMLIMIT    equ  (-18)
PCRE_ERROR_DFA_WSSIZE     equ  (-19)
PCRE_ERROR_DFA_RECURSE    equ  (-20)
PCRE_ERROR_RECURSIONLIMIT equ  (-21)
PCRE_ERROR_NULLWSLIMIT    equ  (-22)  ;No longer actually used
PCRE_ERROR_BADNEWLINE     equ  (-23)


;Request types for pcre_fullinfo()

PCRE_INFO_OPTIONS         equ   0
PCRE_INFO_SIZE            equ   1
PCRE_INFO_CAPTURECOUNT    equ   2
PCRE_INFO_BACKREFMAX      equ   3
PCRE_INFO_FIRSTBYTE       equ   4
PCRE_INFO_FIRSTCHAR       equ   4     ;For backwards compatibility
PCRE_INFO_FIRSTTABLE      equ   5
PCRE_INFO_LASTLITERAL     equ   6
PCRE_INFO_NAMEENTRYSIZE   equ   7
PCRE_INFO_NAMECOUNT       equ   8
PCRE_INFO_NAMETABLE       equ   9
PCRE_INFO_STUDYSIZE       equ  10
PCRE_INFO_DEFAULT_TABLES  equ  11
PCRE_INFO_OKPARTIAL       equ  12
PCRE_INFO_JCHANGED        equ  13
PCRE_INFO_HASCRORLF       equ  14
PCRE_INFO_MINLENGTH       equ  15


;Request types for pcre_config(). Do not re-arrange, in order to remain compatible.

PCRE_CONFIG_UTF8                    equ   0
PCRE_CONFIG_NEWLINE                 equ   1
PCRE_CONFIG_LINK_SIZE               equ   2
PCRE_CONFIG_POSIX_MALLOC_THRESHOLD  equ   3
PCRE_CONFIG_MATCH_LIMIT             equ   4
PCRE_CONFIG_STACKRECURSE            equ   5
PCRE_CONFIG_UNICODE_PROPERTIES      equ   6
PCRE_CONFIG_MATCH_LIMIT_RECURSION   equ   7
PCRE_CONFIG_BSR                     equ   8


;Bit flags for the pcre_extra structure. Do not re-arrange or redefine
;these bits, just add new ones on the end, in order to remain compatible.

PCRE_EXTRA_STUDY_DATA               equ   0001h
PCRE_EXTRA_MATCH_LIMIT              equ   0002h
PCRE_EXTRA_CALLOUT_DATA             equ   0004h
PCRE_EXTRA_TABLES                   equ   0008h
PCRE_EXTRA_MATCH_LIMIT_RECURSION    equ   0010h
PCRE_EXTRA_MARK                     equ   0020h


;The structure for passing additional data to pcre_exec(). This is defined in
;such as way as to be extensible. Always add new fields at the end, in order to
;remain compatible.

pcre_extra struct
  flags                 dword   ?   ;Bits for which fields are set
  study_data            dword   ?   ;Opaque data from pcre_study()
  match_limit           dword   ?   ;Maximum number of calls to match()
  callout_data          dword   ?   ;Data passed back in callouts
  tables                dword   ?   ;Pointer to character tables
  match_limit_recursion dword   ?   ;Max recursive calls to match()
  mark                  dword   ?   ;For passing back a mark pointer
pcre_extra ends


;The structure for passing out data via the pcre_callout_function. We use a
;structure so that new fields can be added on the end in future versions,
;without changing the API of the function, thereby allowing old clients to work
;without modification.

pcre_callout_block struct
  version               dword   ?   ;Identifies version of block
  ; ------------------------ Version 0 -------------------------------
  callout_number        dword   ?   ;Number compiled into pattern
  offset_vector         dword   ?   ;The offset vector
  subject               dword   ?   ;The subject being matched
  subject_length        dword   ?   ;The length of the subject
  start_match           dword   ?   ;Offset to start of this match attempt
  current_position      dword   ?   ;Where we currently are in the subject
  capture_top           dword   ?   ;Max current capture
  capture_last          dword   ?   ;Most recently closed capture
  callout_data          dword   ?   ;Data passed in with the call
  ; ------------------- Added for Version 1 --------------------------
  pattern_position      dword   ?   ;Offset to next item in the pattern
  next_item_length      dword   ?   ;Length of next item in the pattern
  ; ------------------------------------------------------------------
pcre_callout_block ends


;Indirection for store get and free functions. These can be set to
;alternative malloc/free functions if required. Special ones are used in the
;non-recursive case for "frames". There is also an optional callout function
;that is triggered by the (?) regex item. For Virtual Pascal, these definitions
;have to take another form.

pcre_malloc_type typedef proto c :DWORD
externdef c pcre_malloc:ptr pcre_malloc_type
pcre_free_type typedef proto c :DWORD
externdef c pcre_free:ptr pcre_free_type
pcre_stack_malloc_type typedef proto c :DWORD
externdef c pcre_stack_malloc:ptr pcre_stack_malloc_type
pcre_stack_free_type typedef proto c :DWORD
externdef c pcre_stack_free:ptr pcre_stack_free_type
pcre_callout_type typedef proto c :DWORD
externdef c pcre_callout:ptr pcre_callout_type


;Exported PCRE functions

pcre_compile proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_compile2 proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_config proto c :DWORD,:DWORD
pcre_copy_named_substring proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_copy_substring proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_dfa_exec proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_exec proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_free_substring proto c :DWORD
pcre_free_substring_list proto c :DWORD
pcre_fullinfo proto c :DWORD,:DWORD,:DWORD,:DWORD
pcre_get_named_substring proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_get_stringnumber proto c :DWORD,:DWORD
pcre_get_stringtable_entries proto c :DWORD,:DWORD,:DWORD,:DWORD
pcre_get_substring proto c :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
pcre_get_substring_list proto c :DWORD,:DWORD,:DWORD,:DWORD
pcre_info proto c :DWORD,:DWORD,:DWORD
pcre_maketables proto c
pcre_refcount proto c :DWORD,:DWORD
pcre_study proto c :DWORD,:DWORD,:DWORD
pcre_version proto c
