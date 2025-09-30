// Julia Gong
// 9/27/25
// initializing timer and PWM for MCU

#include "STM32L432KC_TIM16.h"
#include <math.h>


void init_PWM(){
// set prescalar value for PWM
    TIM16->PSC = 16;
// set CCMR1 output compare mode to 110 so channel 1 is active as long as TIMx_CNT<TIMx_CCR1 else inactive
    TIM16->CCMR1 |= (1 << 6);
    TIM16->CCMR1 |= (1 << 5);
    TIM16->CCMR1 &= ~(1 << 4);
// set CCMR1 output compare mode preload enable
    TIM16->CCMR1 |= (1 << 3);
// set capture/compare output enable
    TIM16->CCER |= (1 << 0);
// set capture/compare enable register polarity to active high (0)
    TIM16->CCER |= (1 << 1);
// set main out enable
    TIM16->BDTR |= (1 << 15);
// set update generation to reinitialize counter
    TIM16->EGR |= (1 << 0);
// set clock enable
    TIM16->CR1 |= (1 << 0);
}

void PWM_freq(int freq){

// calculate ARR value for frequency
uint32_t arr_val = 0;
if (freq == 0) {
    arr_val = 0;
}
else {
    arr_val = (((80000000) / (5000 + 1)) / freq) - 1;
}
// set counter max value
    TIM16->ARR = arr_val;
// set duty cycle to 50%
    TIM16->CCR1 = arr_val/2;
// set update generation to reinitialize counter
    TIM16->EGR |= (1 << 0);
// reset counter
    TIM16->CNT = 0;
}