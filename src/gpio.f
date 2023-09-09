
HEX

20000000            CONSTANT RPI1_BASE

RPI1_BASE 200000 +  CONSTANT GPIO_BASE

GPIO_BASE           CONSTANT GPFSEL0
GPIO_BASE 04 +      CONSTANT GPFSEL1
GPIO_BASE 08 +      CONSTANT GPFSEL2
GPIO_BASE 1C +      CONSTANT GPSET0
GPIO_BASE 28 +      CONSTANT GPCLR0
GPIO_BASE 34 +      CONSTANT GPLEV0

GPIO_BASE 94 +      CONSTANT GPPUD
GPIO_BASE 98 +      CONSTANT GPPUDCLK0

\ **** Gestione GPIO ****

\ *** Costanti ***

DECIMAL

0   BILS            CONSTANT GPIO0
1   BILS            CONSTANT GPIO1
2   BILS            CONSTANT GPIO2
3   BILS            CONSTANT GPIO3
4   BILS            CONSTANT GPIO4
5   BILS            CONSTANT GPIO5
6   BILS            CONSTANT GPIO6
7   BILS            CONSTANT GPIO7
8   BILS            CONSTANT GPIO8
9   BILS            CONSTANT GPIO9

10  BILS            CONSTANT GPIO10
11  BILS            CONSTANT GPIO11
12  BILS            CONSTANT GPIO12
13  BILS            CONSTANT GPIO13
14  BILS            CONSTANT GPIO14
15  BILS            CONSTANT GPIO15
16  BILS            CONSTANT GPIO16
17  BILS            CONSTANT GPIO17
18  BILS            CONSTANT GPIO18
19  BILS            CONSTANT GPIO19
20  BILS            CONSTANT GPIO20

21  BILS            CONSTANT GPIO21
22  BILS            CONSTANT GPIO22
23  BILS            CONSTANT GPIO23
24  BILS            CONSTANT GPIO24
25  BILS            CONSTANT GPIO25
26  BILS            CONSTANT GPIO26
27  BILS            CONSTANT GPIO27

\ ** Costanti FSEL **

0                   CONSTANT INP
1                   CONSTANT OUT
2                   CONSTANT ALT5
3                   CONSTANT ALT4
4                   CONSTANT ALT0
5                   CONSTANT ALT1
6                   CONSTANT ALT2
7                   CONSTANT ALT3

\ *** Word(s) ***

\ Questa word ha lo scopo di prelevare il valore in cima al TOS, corrispondente alla maschera per il pin GPIO n, e di restituire un numero 
\ decimale corrispondente alla rappresentazione numerica del bit più significativo impostato a 1 nella maschera. È l'inver

( gpio_mask -- gpio_number )
: N_GPIO 
    0 SWAP 
    BEGIN 
        DUP 2 MOD 
        0 = IF 
            1 RSHIFT SWAP 1+ SWAP 
        ELSE 
        THEN 
        DUP 2 = 
    UNTIL 
    DROP 1+ ;

( gpio_mask -- gpio_lsb )
: GPIO_LSB N_GPIO 10 MOD 3 * ;

\ ** Word(s) FSEL **

: FSEL_MASK 
    DUP DUP
    2 + >R
    1 + >R
    BILS
    R> BILS OR
    R> BILS OR ;

: FSEL GPIO_LSB DUP FSEL_MASK ;

: MODE SWAP GPIO_LSB LSHIFT ;

( GPIOn )
: GPFSEL
    N_GPIO 10 / 4 * GPFSEL0 + ;

\ ** Word(s) GPSET & GPCLR ** 

: GPSET N_GPIO 32 / 4 * GPSET0 + ;
: GPCLR N_GPIO 32 / 4 * GPCLR0 + ;

\ ** Word(s) GPLEV **

: GPLEV 32 / 4 * GPLEV0 + ;

: PIN_LEVEL 
    DUP GPLEV @ 
    SWAP 32 MOD 
    BILS AND 
    IF 
        1 
    ELSE 
        0
    THEN ;

\ **** Abilitazione GPIO ****

\ Word(s)

\ QUESTA WORD HA LO SCOPO DI EFFETTUARE UNA SET FUNCTION PER IL PIN GPIOn
\ AD ESEMPIO POSSO SETTARE IL PIN GPIO23 IN MODALITÀ OUTPUT
( GPIOn_FSEL GPIOn_XMODE GPFSELm -- )
: ENABLE_PIN
    DUP                 ( GPIOn_FSEL GPIOn_XMODE GPFSEL2 GPFSEL2 )
    >R @                ( GPIOn_FSEL GPIOn_XMODE GPFSEL2 @ )
    -ROT                ( GPFSEL2 @ GPIOn_FSEL GPIOn_XMODE )
    >R                  ( GPFSEL2 @ GPIOn_FSEL )
    BIC                 
    R>                  ( [ GPFSEL2 @ GPIOn_FSEL BIC ] GPIOn_XMODE )
    OR 
    R> ! ;          

\ QUESTA WORD HA LO SCOPO DI EFFETTUARE UNA CLEAR FUNCTION PER IL PIN GPIOn
( GPIOn_FSEL GPIOn_XMODE GPFSELm -- )
: DISABLE_PIN
    NIP
    DUP >R
    @ SWAP BIC
    R> ! ;

VARIABLE TIMES

: ACTIVATE 
    DEPTH 3 /
    TIMES !
    BEGIN
        ENABLE_PIN
        TIMES @ 1 - TIMES !                 \ DECREMENTO TIMES AD OGNI ITERAZIONE
        TIMES @ 0=                          \ CONDIZIONE DI USCITA
    UNTIL ;

: DEACTIVATE
    DEPTH 3 /
    TIMES !
    BEGIN
        DISABLE_PIN
        TIMES @ 1 - TIMES !                 \ DECREMENTO TIMES AD OGNI ITERAZIONE
        TIMES @ 0=                          \ CONDIZIONE DI USCITA
    UNTIL ;