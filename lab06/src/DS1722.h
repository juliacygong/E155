// DS1722.h
// Julia Gong
// 10/12/2025
// this file includes the headers for the temperature sensor

#ifndef DS1722_H
#define DS1722_H

#include <stdint.h>
#include <stm32l432xx.h>

// initialize temp sensor
void initTemp(void);

char send_bits(uint8_t temp_bit);

float read_temp(void);

#endif