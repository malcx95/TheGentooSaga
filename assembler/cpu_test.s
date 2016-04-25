movhi   r1,1        ; r1 = 1
movhi   r2,4        ; r2 = 4
add     r3,r1,r2    ; r3 = 5
addi    r2,r2,2     ; r2 = 6
addi    r1,r1,1     ; r1 = 2
lw      r4,r1,20    ; r4 = 2
mul     r5,r1,r2    ; r5 = 12
nop                 ; 
movhi   r1,1        ; r1 = 1
movhi   r2,1        ; r2 = 1
sfeq    r1,r2       ; f = 1
movhi   r1,2        ; r1 = 2
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
sfnei   r1,r2       ; f = 0
sw      r1,r6       ;
