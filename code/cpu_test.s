movhi   r1,1        ; r1 = 1
movhi   r2,4        ; r2 = 4
sfgeu   r1,r4
bf hello
add     r3,r1,r2    ; r3 = 5
addi    r2,r2,0b10     ; r2 = 6
addi    r1,r1,0b01     ; r1 = 2
lw      r4,r1,20    ; r4 = 2
mul     r5,r1,r2    ; r5 = 12
hello: nop                 ; 
movhi   r1,6        ; r1 = 1
movhi   r2,6        ; r2 = 1
sfgeui  r1,6
bf chicken
sfeq    r1,r2       ; f = 1
chicken: movhi   r1,2        ; r1 = 2
nop                 ; 
nop                 ; 
sfeq    r1,r2       ; f = 0
nop                 ; 
nop                 ; 
nop                 ; 
nop                 ; 
movhi   r1,5        ; r1 = 5
sfne    r3,r1       ; f = 1
nop                 ;
nop                 ;
nop                 ;
sfnei   r1,5        ; f = 0
sw      r6,r1,0     ;
