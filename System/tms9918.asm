;
;**************************************************************
;*
;*      T M S 9 9 1 8   C H A R A C T E R   D E V I C E
;*
;*      This device emulated a VT52 terminal using the
;*      TMS9918A graphics chip. The 2kb font record is
;*      not resident is memory, and must be provided by
;*      a compatable block I/O device.
;* 
;**************************************************************
;

; TMS9918 Configuration
tm_data	equ	0xA0	; TMS9918 data register (mode=0)
tm_latc	equ	0xA1	; TMS9917 latch register (mode=1)

; Driver jump table
tmsdev:	jp	tm_init
	jp	tm_stat
	jp	tm_read
	jp	tm_writ
	
; TMS9918 init
; Load font record, set up terminal
tm_init:call	resgrb

	; Set TMS to text mode
	in	a,(tm_latc)
	ld	a,0x00
	out	(tm_latc),a
	ld	a,0x80
	out	(tm_latc),a
	in	a,(tm_latc)
	ld	a,0xD0
	out	(tm_latc),a
	ld	a,0x81
	out	(tm_latc),a
	
	; Set TMS name table to 0x0800
	in	a,(tm_latc)
	ld	a,0x02
	out	(tm_latc),a
	ld	a,0x82
	out	(tm_latc),a

	
	; Set TMS pattern generator block to 0
	in	a,(tm_latc)
	xor	a
	out	(tm_latc),a
	ld	a,0x84
	out	(tm_latc),a
	
	; Write the GRB
	ld	bc,0x4000
	call	tm_addr
	ld	hl,cbase
	ld	c,tm_data
	ld	a,8	; Transfer 8*256 = 2048
tm_ini0:ld	b,0
	otir
	dec	a
	jr	nz,tm_ini0
	
	; Clear the terminal
	call	tm_cls
	ld	a,0
	ld	(tm_curx),a
	ld	(tm_curx),a

	ret


tm_stat:ret


tm_read:ret


tm_writ:ret

; Clears out all 3 screen buffers
;
; uses: af, bc, de
tm_cls:	ld	bc,0x4800
	call	tm_addr
	ld	c,tm_data
	ld	de,0x0C00
tm_cls0:out	(c),0
	dec	de
	ld	a,d
	or	e
	jr	nz,tm_cls0
	ret

; Sets the TMS address for either reading or writing
; bc = Address 
;
; uses: af, bc
tm_addr:in	a,(tm_latc)
	ld	a,c
	out	(tm_latc),a
	ld	a,b
	out	(tm_latc),a
	ret
	
; Variables
tm_curx:defb	0	; Cursor X
tm_cury:defb	0	; Cursor X