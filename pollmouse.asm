;----[ pollmouse.a ]--------------------

;Copyright (C) 2019 Gregory Nacu

;1351 Mouse Driver
; - Fully Commented
; - Screen Edge Bounded
; - Accelerated
; - Two Sprites
; - 16-bit Overflow Prevention

irqvec   = $0314
vic      = $d000
sid      = $d400

         *= $c000

         ldx irqvec
         ldy irqvec+1

         stx sysirq+1
         sty sysirq+2

         ldx #<mouseirq
         ldy #>mouseirq

         php
         sei

         stx irqvec
         sty irqvec+1

         plp

         lda #%00000011
         sta vic+$15 ;Enable Sprites

         rts

;---------------------------------------

mouseirq cld

         jsr scanmovs
         jsr boundmus

sysirq   jmp $ffff

;---------------------------------------

potx     = sid+$19
poty     = sid+$1a

xpos     = vic+$00
ypos     = vic+$01
xpos2    = vic+$02
ypos2    = vic+$03

xposmsb  = vic+$10

maxx     = 319 ;Screen Width
maxy     = 199 ;Screen Height

offsetx  = 24 ;Sprite left border edge
offsety  = 50 ;Sprite top  border edge

musposx  .word 320/2
musposy  .word 200/2

boundmus
         ldx musposx+1
         bmi zerox
         beq chky

         ldx #maxx-256
         cpx musposx
         bcs chky

         stx musposx
         bcc chky

zerox    ldx #0
         stx musposx
         stx musposx+1

chky     ldy musposy+1
         bmi zeroy
         beq loychk

         dey musposy+1
         ldy #maxy
         sty musposy
         bne movemus

loychk   ldy #maxy
         cpy musposy
         bcs movemus

         sty musposy
         bcc movemus

zeroy    ldy #0
         sty musposy
         sty musposy+1

movemus  clc
         lda musposx
         adc #offsetx
         sta xpos
         sta xpos2

         lda musposx+1
         adc #0
         beq clearxhi
         
         ;set x sprite pos high
         lda xposmsb
         ora #%00000011         
         bne *+7
         
clearxhi ;set x sprite pos low
         lda xposmsb
         and #%11111100
         
         sta xposmsb

         clc
         lda musposy
         adc #offsety
         sta ypos
         sta ypos2

         rts

;---------------------------------------

scanmovs

         ;--- X Axis ---
         lda potx
oldpotx  ldy #0
         jsr movechk
         beq noxmove

         sty oldpotx+1

         clc
         adc musposx
         sta musposx
         txa            ;upper 8-bits
         adc musposx+1
         sta musposx+1
noxmove

         ;--- Y Axis ---
         lda poty
oldpoty  ldy #0
         jsr movechk
         beq noymov

         sty oldpoty+1

         clc
         eor #$ff       ;Reverse Sign
         adc #1

         clc
         adc musposy
         sta musposy
         txa            ;Upper 8-bits
         eor #$ff       ;Reverse Sign
         adc musposy+1
         sta musposy+1
noymov
         rts

movechk  ;Y -> Old Pot Value
         ;A -> New Pot Value

         sty oldvalue+1
         tay

         sec
oldvalue sbc #$ff
         and #%01111111
         cmp #%01000000
         bcs neg

         lsr a   ;remove noise bit
         beq nomove

         cmp #10 ;Acceleration Speed
         bcc *+3
         asl a   ;X2

         ldx #0
         cmp #0

         ;A > 0
         ;X = 0 (sign extension)
         ;Y = newvalue
         ;Z = 0

         rts

neg      ora #%10000000
         cmp #$ff
         beq nomove

         sec    ;Keep hi negative bit
         ror a  ;remove noise bit

         cmp #256-10 ;Acceleration Speed
         bcs *+3
         asl a       ;X2

         ldx #$ff

         ;A < 0
         ;X = $ff (sign extension)
         ;Y = newvalue
         ;Z = 0

         rts

nomove   ;A = -
         ;X = -
         ;Y = -
         ;Z = 1

         rts
