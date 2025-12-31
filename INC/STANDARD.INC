;**************************************************
@PUSH MACRO A,B,C,D,E,F,G,H,I
        IRP CHAR,<A,B,C,D,E,F,G,H,I>
        IFNB <CHAR>
        PUSH    CHAR
        ENDIF
        ENDM
ENDM
;**************************************************
@POP MACRO A,B,C,D,E,F,G,H,I
        IRP CHAR,<I,H,G,F,E,D,C,B,A>
        IFNB <CHAR>
        POP     CHAR
        ENDIF
        ENDM
ENDM
;***************************************************
;* DOS FUNCTION CALL 02H:¦L¦r¦Ü¿Ã¹õ                *
;***************************************************
OUTCHAR MACRO OutCharData
        @PUSH   ax, dx
        xor     dh, dh
        mov     ah, 2h
        mov     dl, OutCharData
        int     21h
        @POP    ax, dx
ENDM
;**************************************************
;    ¿é¥X¦r¦ê
;**************************************************
PRINT MACRO WORD
        @PUSH   ax, dx
        mov     dx, offset WORD
        mov     ah, 9h
        int     21h
        @POP    ax, dx
ENDM
;**************************************************
;    µ¥«Ý«öÁä
;**************************************************
WAITKEY MACRO
        xor     ax, ax
        int     16h
ENDM
;***************************************************
;* DOS FUNCTION CALL 0AH ¦b¿Ã¹õ¤W¿é¤J¤@¦r¦ê        *
;***************************************************
INPUT MACRO INDATA
        mov     dx, offset INDATA
        mov     ah, 0Ah
        int     21h
     ENDM
;****************************************************************************
;*  GetStringLength                                                         *
;*  Entry:                                                                  *
;*  DS:SI= Buffer for search                                                *
;*  AX=String Length                                                        *
;*  None                                                                    *
;****************************************************************************
GetStringLength MACRO SegChar
        Local   SearchSegChar, GetLength
        @PUSH   cx, si
        pushf
        CLD
        push    si
        mov     cx, -1
SearchSegChar:
        cmp     byte ptr ds:[si], SegChar
        jz      GetLength
        inc     si
        jmp     SearchSegChar
GetLength:
        pop     cx
        mov     ax, si
        sub     ax, cx
        popf
        @POP    cx, si
ENDM
