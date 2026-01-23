include inc\Standard.inc
include inc\File.inc
include inc\Struct.inc

.model small
.586

.data
MSG1            db 10,13,'Please input Bus number->$'
MSG2            db 10,13,'Please input Device number->$'
MSG3            db 10,13,'Please input Function number->$'

TransferTable   db 0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
TransferTable1  db 'A','B','C','D','E','F'
TransferTable2  db 'a','b','c','d','e','f'

Data1           db 31,0,31 dup(?)
BusData         db ?
DevData         db ?
FunData         db ?
PSP             dw 0

DeviceMsg   db 10,13,"Device ID = "
DeviceData db 4 dup(0),'h','$'

VendorMsg   db 10,13,"Vendor ID = "
VendorData db 4 dup(0),'h','$'

.stack
.code

;--------------------------------------------------
Transfer Macro
        local   NotSmall, TransferOK, IsNumber
        cmp     al, 39h
        jbe     IsNumber
        cmp     al, byte ptr TransferTable2
        jb      NotSmall
        sub     al, byte ptr TransferTable2
        mov     bl, al
        movzx   bx, bl
        mov     al, TransferTable[bx]
        jmp     TransferOK
IsNumber:
        and     al, 0fh
        jmp     TransferOK
NotSmall:
        sub     al, byte ptr TransferTable1
        mov     bl, al
        movzx   bx, bl
        mov     al, TransferTable[bx]
TransferOK:
ENDM

;--------------------------------------------------
Testa proc far
        push    ds
        xor     ax, ax
        push    ax

        mov     ax, @data
        mov     ds, ax
        mov     PSP, es

;---------------- Bus ----------------
        Print   MSG1
        INPUT   Data1
        add     dx, 2
        mov     bx, dx
        mov     ax, [bx]

        cmp     ah, 0Dh
        ja      Bus_OK
        mov     ah, '0'
        xchg    ah, al
Bus_OK:
        Transfer
        xchg    ah, al
        Transfer
        shl     ah, 4
        or      ah, al
        mov     BusData, ah

;---------------- Device ----------------
        Print   MSG2
        INPUT   Data1
        add     dx, 2
        mov     bx, dx
        mov     ax, [bx]

        cmp     ah, 0Dh
        ja      Dev_OK
        mov     ah, '0'
        xchg    ah, al
Dev_OK:
        Transfer
        xchg    ah, al
        Transfer
        shl     ah, 4
        or      ah, al
        mov     DevData, ah

;---------------- Function ----------------
        Print   MSG3
        INPUT   Data1
        add     dx, 2
        mov     bx, dx
        mov     ax, [bx]

        cmp     ah, 0Dh
        ja      Fun_OK
        mov     ah, '0'
        xchg    ah, al
Fun_OK:
        Transfer
        xchg    ah, al
        Transfer
        shl     ah, 4
        or      ah, al
        mov     FunData, ah

;--------------------------------------------------
; *** FIXED PCI CONFIG ADDRESS BUILD ***
;--------------------------------------------------
        mov     eax, 80000000h          ; Enable bit (bit31)

        movzx   ecx, BusData
        shl     ecx, 16
        or      eax, ecx               ; Bus

        movzx   ecx, DevData
        shl     ecx, 11
        or      eax, ecx               ; Device

        movzx   ecx, FunData
        shl     ecx, 8
        or      eax, ecx               ; Function

        ; Offset = 0x00

        mov     dx, 0CF8h
        out     dx, eax                ; CONFIG_ADDRESS

        mov     dx, 0CFCh
        in      eax, dx                ; CONFIG_DATA

        call    DisplayError
        ret
Testa endp

;--------------------------------------------------
DisplayError proc
        push    eax
        push    ebx
        push    ecx
        push    edx

        mov     ecx, eax

        ; Device ID [31:16]
        mov     ebx, ecx
        shr     ebx, 16

        mov     dl, bh
        call    HexToAscii
        mov     DeviceData, dh
        mov     DeviceData+1, dl

        mov     dl, bl
        call    HexToAscii
        mov     DeviceData+2, dh
        mov     DeviceData+3, dl

        mov     ah, 9
        mov     dx, offset DeviceMsg
        int     21h

        ; Vendor ID [15:0]
        mov     ebx, ecx
        and     ebx, 0FFFFh

        mov     dl, bh
        call    HexToAscii
        mov     VendorData, dh
        mov     VendorData+1, dl

        mov     dl, bl
        call    HexToAscii
        mov     VendorData+2, dh
        mov     VendorData+3, dl

        mov     ah, 9
        mov     dx, offset VendorMsg
        int     21h

        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret
DisplayError endp

;--------------------------------------------------
HexToAscii proc
        push    cx
        push    dx

        and     dl, 0Fh
        add     dl, '0'
        cmp     dl, '9'+1
        jb      L1
        add     dl, 7
L1:
        mov     cl, dl
        pop     dx

        and     dl, 0F0h
        shr     dl, 4
        add     dl, '0'
        cmp     dl, '9'+1
        jb      L2
        add     dl, 7
L2:
        mov     dh, dl
        mov     dl, cl

        pop     cx
        ret
HexToAscii endp

end Testa
