bits 64
default rel

segment .data
    msg db "Hello world!", 0xa

segment .text
    global main

extern printf

main:
    lea     rcx, [msg]
    call    printf
    ret