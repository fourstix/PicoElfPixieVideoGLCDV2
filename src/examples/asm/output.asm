; -------------------------------------------------------------------
; Output data byte to port 4
; -------------------------------------------------------------------
; Based on software written by Michael H Riley
; Thanks to the author for making this code available.
; Original author copyright notice:
; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

; Uncomment the line below to assemble a ROM program
; Comment out to assemble a stand alone program
;#DEFINE _ROM_ 1

include bios.inc
include kernel.inc

#IFDEF _ROM_
; ***************************************************
; *** This block generates the ROM package header ***
; ***************************************************
           org     8000h                 ;
           lbr     0ff00h                ; Long branch for Pico/Elf
           db      'output',0               ; Program filename
           dw      9000h                 ; Where in Rom image to find program
           dw      endrom-2000h+9000h    ; last address of image
; *******************************************************
; **** Next block is the execution header, this is   ****
; **** part of the package header and written to the ****
; **** actual file when saved to disk                ****
; *******************************************************
           dw      2000h           ; Exec header, where program loads
           dw      endrom-2000h    ; Length of program to load
           dw      2000h           ; Execution address
           db      0               ; Zero marks end of package header
; *********************************
; ***** End of package header *****
; *********************************

  org     2000h
#ENDIF

#IFNDEF _ROM_
; ************************************************************
; This block generates the Execution header
; It occurs 6 bytes before the program start.
; ************************************************************
        org     02000h-6        ; Header starts at 01ffah
        dw      02000h          ; Program load address
        dw      endrom-2000h    ; Program size
        dw      02000h          ; Program execution address
#ENDIF

        br      start           ; Jump past build information
        ; Build date
date:   db      80H+1           ; Month, 80H offset means extended info
        db      1               ; Day
        dw      2021            ; Year

        ; Current build number
build:  dw      2

        ; Must end with 0 (null)
        db      'Copyright 2021 Gaston Williams',0

start: lda     ra                  ; move past any spaces
       smi     ' '
       lbz     start
       dec     ra                  ; move back to non-space character
       ldn     ra                  ; check for nonzero byte
       lbnz    good                ; jump if non-zero
       sep     scall               ; otherwise display usage
       dw      f_inmsg
       db      'Usage: output hh, where hh is a hexadecimal number',13,10,0
       sep     sret                ; return to os

good:  ghi     ra                  ; copy argument address to rf
       phi     rf
       glo     ra
       plo     rf
       sep     scall               ; convert input to hex value
       dw      f_hexin

       glo     rd                  ; get the hexadecimal byte value
       str     r2                  ; put it on the stack
       out 4                       ; output to port 4, increments stack
       dec     r2                  ; back stack up to old location

       lbr     o_wrmboot           ; return to Elf/OS
        ;------ define end of execution block
endrom: equ     $
