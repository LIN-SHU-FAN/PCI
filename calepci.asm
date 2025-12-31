include inc\Standard.inc
include inc\File.inc
include inc\Struct.inc
.model small
.586
.data
MSG1            db      10,13,'Please input Bus number->$'
MSG2            db      10,13,'Please input Device number->$'
MSG3            db      10,13,'Please input Function number->$'
TransferTable   db      0ah, 0bh, 0ch, 0dh, 0eh, 0fh
TransferTable1  db      'A', 'B', 'C', 'D','E', 'F'
TransferTable2  db      'a', 'b', 'c', 'd','e', 'f'
Data1           DB      31,0,31 DUP(?)
BusData         db      ?
DevData         db      ?
FunData         db      ?
PSP             dw      0

DeviceMsg   db 10,13,"Device ID = "
DeviceData db 4 dup(0),'h','$'

VendorMsg   db 10,13,"Vendor ID = "
VendorData db 4 dup(0),'h','$'
.stack
.code

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
        mov     al, byte ptr TransferTable1
        sub     al, byte ptr TransferTable1
        mov     bl, al
        movzx   bx, bl
        mov     al, TransferTable[bx]
TransferOK:
ENDM
Testa proc far
        push    ds
        xor     ax, ax
        push    ax 
        mov     ax, @data
        mov     ds, ax
        mov     ax, es
        mov     PSP, ax
;        
        Print   MSG1
        INPUT   Data1
        add     dx, 2
int 1
        mov     bx, dx
        mov     ax, [bx]
        cmp     ah, 0dh
        ja      NotThing
        mov     ah, 30h
        xchg    ah, al
NotThing:
        Transfer
        xchg    ah, al
        Transfer
        shl     ah, 4
        or      ah, al
        mov     BusData, ah
;
        Print   MSG2
        INPUT   Data1
        add     dx, 2
        mov     bx, dx
        mov     ax, [bx]
        cmp     ah, 0dh
        ja      NotThing1
        mov     ah, 30h
        xchg    ah, al
NotThing1:
        Transfer
        xchg    ah, al
        Transfer
        shl     ah, 4
        or      ah, al
        mov     DevData, ah
;        
        Print   MSG3
        INPUT   Data1
        add     dx, 2
        mov     bx, dx
        mov     ax, [bx]
        cmp     ah, 0dh
        ja      NotThing2
        mov     ah, 30h
        xchg    ah, al
NotThing2:
        Transfer
        xchg    ah, al
        Transfer
        shl     ah, 4
        or      ah, al
        mov     FunData, ah
;
        mov     edx, 80h
        Shl     edx, 8
        Or      dl, BusData     ; Bus number 
        Shl     edx, 5         
        Or      dl, DevData     ; Device number
        Shl     edx, 3          
        Or      dl, FunData     ; Function number
        Shl     edx, 8
        mov     ebx, edx
        
        
        and     ebx, 0FFFFFF00h     ; offset = 0x00
        mov     eax, ebx
        
        mov     dx, 0CF8h
        out     dx, eax             ; write CONFIG_ADDRESS
        mov     dx, 0CFCh
        in      eax, dx             ; read CONFIG_DATA

        mov     ebx, eax
        call    DisplayError

;       
        ret
Testa endp
;;---------------------------------------------------
DisplayError proc
    push    ebx

    ; =========================
    ; Device ID (high 16 bits)
    ; =========================
    shr     ebx, 16          ; EBX = Device ID

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

    pop     ebx
    push    ebx

    ; =========================
    ; Vendor ID (low 16 bits)
    ; =========================
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

    pop     ebx
    ret
DisplayError endp

;;---------------------------------------------------
HexToAscii     proc
        push    cx
        push    dx
        and     dl, 0fh
        add     dl, 30h
        cmp     dl, 3Ah
        jb      No_Add_Seven
        add     dl, 7
No_Add_Seven:
        mov     cl, dl
        pop     dx
        and     dl, 0f0h
        shr     dl, 4
        add     dl, 30h
        cmp     dl, 3Ah
        jb      No_Add_Seven1
        add     dl, 7
No_Add_Seven1:
        mov     dh, dl
        mov     dl, cl
        pop     cx
        ret
HexToAscii     endp
end Testa
