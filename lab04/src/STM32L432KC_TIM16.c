// Julia Gong
// 9/27/25
// initializing timer and PWM for MCU
// STM32L432KC_TIM16.c

#include "STM32L432KC_TIM16.h"
#include <math.h>
#include "STM32L432KC_RCC.h"


void init_PWM(){
    RCC->APB2ENR |= (1 << 17); // enabling TIM16 clk
// set prescalar value for PWM
    TIM16->PSC = 19;
// set CCMR1 output compare mode to 110 so channel 1 is active as long as TIMx_CNT<TIMx_CCR1 else inactive
    TIM16->CCMR1 |= (1 << 6);
    TIM16->CCMR1 |= (1 << 5);
    TIM16->CCMR1 &= ~(1 << 4);

    // TIM16->ARR = 1000;
// set CCMR1 output compare mode preload enable
    TIM16->CCMR1 |= (1 << 3);
// set CCMR1 cc1 as output
    TIM16->CCMR1 |= (0b00 << 0);
// auto reload preload enable
    TIM16->CR1 |= (1 << 7);
// set capture/compare enable register polarity to active high (0)
    TIM16->CCER &= ~(1 << 1);
// set ourput enable
    TIM16->CCER |= (1 << 0);
// set main out enable
    TIM16->BDTR |= (1 << 15);
// set update generation to reinitialize counter
    TIM16->EGR |= (1 << 0);
// set clock enable
    TIM16->CR1 |= (1 << 0);

}

void PWM_freq(int freq){
uint32_t frequency = 0;
if (freq == 0) {
  TIM16->CCR1 = 0;
  TIM16->ARR = 0;
  TIM16->EGR |= (1 << 0);
  }
else {
  frequency = ((80000000 / (19 + 1)) / freq) - 1 ;
  }
// set counter max value
    TIM16->ARR = frequency;
// set duty cycle to 50%
    TIM16->CCR1 = (frequency + 1) / 2 ;
// set update generation to reinitialize counter
    TIM16->EGR |= (1 << 0);
// reset counter
    TIM16->CNT = 0;
}
