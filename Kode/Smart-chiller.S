;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main

main:
    RCALL SPI_MAX7219_init
    RCALL MAX7219_display_digit
agn: 
    RCALL HCSR04_read_distance
    CPI R28, 15  
    BRLO activate_dht11
    RJMP deactivate_dht11

activate_dht11:
    SBI PORTD, 2
    RCALL delay_ms
    RCALL DHT11_sensor
    RCALL check
    RJMP agn

deactivate_dht11:
    CBI PORTD, 2
    RCALL delay_ms
    RJMP agn


HCSR04_read_distance:
    SBI   DDRB, 1         ;pin PB1 as o/p (Trigger)
    CBI   DDRB, 0         ;pin PB0 as i/p (Echo)
    SBI   PORTB, 1
    CBI   PORTD, 1
    CBI   PORTD, 0
    RCALL delay_timer0
    CBI   PORTB, 1        ;send 10us high pulse to sensor
    RCALL echo_PW         ;compute Echo pulse width count
    RET

echo_PW:

    LDI   R20, 0b00000000
    STS   TCCR1A, R20     ;Timer 1 normal mode
    LDI   R20, 0b11000101 ;set for rising edge detection &
    STS   TCCR1B, R20     ;prescaler=1024, noise cancellation ON

rising_edge: 
    IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP  rising_edge     ;loop until rising edge is detected
    LDS   R16, ICR1L      ;store count value at rising edge
    OUT   TIFR1, R21      ;clear flag for falling edge detection
    LDI   R20, 0b10000101
    STS   TCCR1B, R20     ;set for falling edge detection

falling_edge: 
    IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP  falling_edge    ;loop until falling edge is detected
    LDS   R28, ICR1L      ;store count value at falling edge
    SUB   R28, R16        ;count diff R22 = R22 - R16
    OUT   TIFR1, R21      ;clear flag for next sensor reading
    RET


DHT11_sensor: 
    RCALL delay_2s      ; wait 2s for DHT11 to get ready
    SBI   DDRD, 7       ; pin PD7 as o/p
    CBI   PORTD, 7      ; first, send low pulse
    RCALL delay_20ms    ; for 20ms
    SBI   PORTD, 7      ; then send high pulse
    CBI   DDRD, 7       ; pin PD7 as i/p

w1: SBIC  PIND, 7
    RJMP  w1                ; wait for DHT11 low pulse

w2: SBIS  PIND, 7
    RJMP  w2                ; wait for DHT11 high pulse
    
w3: SBIC  PIND, 7
    RJMP  w3                ; wait for DHT11 low pulse
    RCALL DHT11_reading     ; read humidity (1st byte of 40-bit data)
    MOV   R25, R24
    RCALL DHT11_reading
    RCALL DHT11_reading     ; read temp (3rd byte of 40-bit data)
    MOV   R28, R24          ; store temperature in R28 for display_digit
    MOV   R31, R24          ; store temperature in R31 for servo and LED condition
    LDI   R29, 0x07         ; MSD temp will be display_digited on digit 6
    LDI   R30, 0x06         ; LSD temp will be display_digited on digit 5
    RCALL binary_to_decimal ; temp in decimal
    MOV   R28, R25
    LDI   R29, 0x02         ; MSD humidity will be display_digited on digit 1
    LDI   R30, 0x01         ; LSD humidity will be display_digited on digit 0
    RCALL binary_to_decimal   ; humidity in decimal
    RET                     ; RETurn to loop

check:
    CPI   R31, 30          ; compare temperature in R31 with 30
    BRLO  servo_off        ; if temperature < 30, servo off
    CBI   PORTD, 5         ; turn off LED
    RCALL servo_on         ; turn on servo

servo_off:  
    CBI   PORTD, 4         ; turn off LED
    CPI   R31, 20          ; compare temperature in R31 with 20
    BRGE  led_off          ; if temperature >= 20, led off
    SBI   PORTD, 5         ; turn on LED
    RET                    ; RETurn to looping

led_off:
    CBI   PORTD, 5         ; turn off LED
    RET                    ; RETurn to looping


DHT11_reading:
    LDI   R16, 8        ; set counter for receiving 8 bits
    CLR   R24           ; clear data register

w4: SBIS  PIND, 7
    RJMP  w4            ; detect data bit (high pulse)
    RCALL delay_timer0  ; wait 50us & then check bit value
    SBIS  PIND, 7       ; if received bit=1, skip next inst
    RJMP  skip           ; else, received bit=0, jump to skip
    SEC                 ; set carry flag (C=1)
    ROL   R24           ; shift in 1 into LSB data register
    RJMP  w5            ; jump & wait for low pulse

skip:LSL   R24           ; shift in 0 into LSB data register
w5: SBIC  PIND, 7
    RJMP  w5            ; wait for DHT11 low pulse
    DEC   R16           ; decrement counter
    BRNE  w4            ; go back & detect next bit
    RET                 ; RETurn to calling subroutine

delay_10us:
    LDI R21, 10

delay_10us_loop:
    NOP
    DEC R21
    BRNE delay_10us_loop
    RET

delay_20ms:             ; delay 20ms
    LDI   R21, 255
l3: LDI   R22, 210
l4: LDI   R23, 2
l5: DEC   R23
    BRNE  l5
    DEC   R22
    BRNE  l4
    DEC   R21
    BRNE  l3
    RET

delay_2s:               ; delay 2s
    LDI   R21, 255
l6: LDI   R22, 255
l7: LDI   R23, 164
l8: DEC   R23
    BRNE  l8
    DEC   R22
    BRNE  l7
    DEC   R21
    BRNE  l6
    RET

delay_timer0:             ; 50 usec delay via Timer 0
    CLR   R20
    OUT   TCNT0, R20      ; initialize timer0 with count=0
    LDI   R20, 100
    OUT   OCR0A, R20      ; OCR0 = 100
    LDI   R20, 0b00001010
    OUT   TCCR0B, R20     ; timer0: CTC mode, prescaler 64

l2: IN    R20, TIFR0      ; get TIFR0 byte & check
    SBRS  R20, OCF0A      ; if OCF0=1, skip next instruction
    RJMP  l2              ; else, loop back & check OCF0 flag
    CLR   R20
    OUT   TCCR0B, R20     ; stop timer0
    LDI   R20, (1<<OCF0A)
    OUT   TIFR0, R20      ; clear OCF0 flag
    RET

SPI_MAX7219_init:
    SBI   DDRD, 4       ; pin PD4 as o/p buzzer 
    SBI   DDRD, 5       ; pin PD5 as o/p LED
    .equ  SCK, 5
    .equ  MOSI, 3
    .equ  SS, 2
    LDI   R17, (1<<MOSI)|(1<<SCK)|(1<<SS)
    OUT   DDRB, R17       ; set MOSI, SCK, SS as o/p
    LDI   R17, (1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<SPR0)
    OUT   SPCR, R17       ; enable SPI as master, fsck=fosc/16
    LDI   R17, 0x0A       ; set segment intensity (0 to 15)
    LDI   R18, 8          ; intensity level = 8
    RCALL send_bytes      ; send command & data to MAX7219
    LDI   R17, 0x09       ; set decoding mode command
    LDI   R18, 0b01100011 ; decoding byte
    RCALL send_bytes      ; send command & data to MAX7219
    LDI   R17, 0x0B       ; set scan limit command
    LDI   R18, 0x07       ; 8 digits connected to MAX7219
    RCALL send_bytes      ; send command & data to MAX7219
    LDI   R17, 0x0C       ; set turn ON/OFF command
    LDI   R18, 0x01       ; turn ON MAX7219
    RCALL send_bytes      ; send command & data to MAX7219
    RET

MAX7219_display_digit:
    LDI   R17, 0x08       ; select digit 7
    LDI   R18, 0x0F       ; data = t (defg) (00001111)
    RCALL send_bytes      ; send command & data to MAX7219
    LDI   R17, 0x05       ; select digit 4
    LDI   R18, 0x4E       ; data = C (adef) (01001110)
    RCALL send_bytes      ; send command & data to MAX7219
    LDI   R17, 0x04       ; select digit 3
    LDI   R18, 0x00       ; data = space
    RCALL send_bytes      ; send command & data to MAX7219
    LDI   R17, 0x03       ; select digit 2
    LDI   R18, 0x17       ; data = h (cefg) (00010111)
    RCALL send_bytes      ; send command & data to MAX7219
    RET

send_bytes:
    CBI   PORTB, SS       ; enable slave device MAX7219
    OUT   SPDR, R17       ; transmit command

wait_transmission1:
    IN    R19, SPSR
    SBRS  R19, SPIF           ; wait for byte transmission
    RJMP  wait_transmission1  ; to complete
    OUT   SPDR, R18           ; transmit data

wait_transmission2:
    IN    R19, SPSR
    SBRS  R19, SPIF           ; wait for byte transmission
    RJMP  wait_transmission2  ; to complete
    SBI   PORTB, SS           ; disable slave device MAX7219
    RET

binary_to_decimal:
    CLR   R26             ; set counter1, initial value 0
    CLR   R27             ; set counter2, initial value 0

convert_100:  CPI   R28, 100      ; compare R28 with 100
RET:  BRMI  convert_10            ; jump when R28 < 100
    INC   R26                     ; increment counter1 by 1
    SUBI  R28, 100                ; R28 = R28 - 100
    RJMP  convert_100

convert_10:CPI   R28, 10       ; compare R28 with 10
    BRMI  display_digit        ; jump when R28 < 10
    INC   R27                  ; increment counter2 by 1
    SUBI  R28, 10              ; R28 = R28 - 10
    RJMP  convert_10

display_digit:  
    MOV   R18, R27
    MOV   R17, R29        ; select digit
    RCALL send_bytes      ; send command & data to MAX7219
    MOV   R18, R28
    MOV   R17, R30        ; select digit
    RCALL send_bytes      ; send command & data to MAX7219    
    RET

servo_on:
    CPI   R31, 40     ; compare temperature in R31 with 40
    BRLO  buzzer_Off  ; if temperature < 40, buzzer off 
    SBI   PORTD, 4    ; turn on buzzer

buzzer_Off:
    LDI   R17, 0          
    OUT   SPCR, R17       ; enable SPI as master, fsck=fosc/16
    SBI   DDRB, 4         ; pin PB4 o/p for servo control

again_servo:     
    LDI   R26, 8          ; counter for # of rotation pos
    LDI   ZL, lo8(rotate)
    LDI   ZH, hi8(rotate)

ls1: LPM   R24, Z+         ; load rotation pos
    RCALL rotate_servo     ; & rotate servo
    DEC   R26
    BRNE  ls1              ; go back & get another rotate pos
    RJMP SPI_MAX7219_init  ; go back & repeat

rotate:
    .byte 40,70,90,110,180,110,90,70

rotate_servo:
    LDI   R20, 10         
    SBI DDRB, 1

ls2: SBI   PORTB, 4
    RCALL delay_timer0_servo
    CBI   PORTB, 4              ; send msec pulse to rotate servo
    RCALL delay_20ms_servo      ; wait 20ms before re-sending pulse
    DEC   R20
    BRNE  ls2                   ; go back & repeat PWM signal

bak:RCALL delay_ms        ; 0.5s delay
    RET                   ; & RETurn to main subroutine

delay_timer0_servo:       ; delay via Timer0
    CLR   R21
    OUT   TCNT0, R21      ; initialize timer0 with count=0
    MOV   R21, R24
    OUT   OCR0A, R21
    LDI   R21, 0b00001100
    OUT   TCCR0B, R21     ; timer0: CTC mode, prescaler 256
  
ls3: IN    R21, TIFR0     ; get TIFR0 byte & check
    SBRS  R21, OCF0A      ; if OCF0=1, skip next instruction
    RJMP  ls3             ; else, loop back & check OCF0 flag
    CLR   R21
    OUT   TCCR0B, R21     ; stop timer0
    LDI   R21, (1<<OCF0A)
    OUT   TIFR0, R21      ; clear OCF0 flag
    RET

delay_20ms_servo:               ; delay 20ms 
    LDI   R21, 255
ls4: LDI   R22, 210
ls5: LDI   R23, 2
ls6: DEC   R23
    BRNE  ls6
    DEC   R22
    BRNE  ls5
    DEC   R21
    BRNE  ls4
    RET

delay_ms:                 ; delay 0.5s 
    LDI   R21, 255
ls7 :LDI   R22, 255
ls8 :LDI   R23, 41
ls9 :DEC   R23
    BRNE  ls9
    DEC   R22
    BRNE  ls8
    DEC   R21
    BRNE  ls7
    RET
