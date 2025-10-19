// DS1722.c
// Julia Gong
// 10/12/2025
// this file initiates functions for the temperature sensor

#include "DS1722.h"
#include "STM32L432KC.h"

void initTemp(void) {
// initialize temp
// turn on CS
digitalWrite(SPI_CS, PIO_HIGH); 

spiSendReceive(0x80); // write to config register
// spiSendReceive(0xEE); // turn off shutdown mode (SD is default 1), rest is at default

// turn off CS
digitalWrite(SPI_CS, PIO_LOW);

return;

}

char send_bits(uint8_t temp_bit){

// choose bit value to send from temp_bit
uint8_t bit_res = 0b000;
  if (temp_bit == 8) {
    bit_res = 0b11100000;
  }
  else if (temp_bit == 9) {
    bit_res = 0b11100010;
    }
  else if (temp_bit == 10) {
    bit_res = 0b11100100;
    }
  else if (temp_bit == 11) {
    bit_res = 0b11100110;
    }
  else if (temp_bit == 12) {
    bit_res = 0b11101000;
  }

  // turn on CS
  digitalWrite(SPI_CS, PIO_HIGH);
  spiSendReceive(0x80); // write config register
  spiSendReceive(bit_res);
  // turn off CS
  digitalWrite(SPI_CS, PIO_LOW);

}


float read_temp(void){
// turn on CS
digitalWrite(SPI_CS, PIO_HIGH);
spiSendReceive(0x02); // read MSB, which contains the sign

uint8_t msb = spiSendReceive(0x00); // dummy write to receive

spiSendReceive(0x01); // read LSB
uint8_t lsb = spiSendReceive(0x00); // dummy write to receive

// turn off CS
digitalWrite(SPI_CS, PIO_LOW);

float temp = msb + (lsb / 256.0);

return temp;

}

