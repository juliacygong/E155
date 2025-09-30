// Julia Gong
// 9/27/25
// initializing timer for MCU

#include "STM32L432KC_TIM6.h"
#include "STM32L432KC_RCC.h"
#include <math.h>

void init_delay() {
// enable clock for timer
    RCC->APB1ENR1 |= (1 << 4);
// 
// set up prescalar value
    TIM6->PSC = 5000;
// set update generation to reinitialize counter
    TIM6->EGR |= (1 << 0);
// turn on auto-preload enable (TIMx_ARR register is buffered)
    TIM6->CR1 |= (1 << 7);
// turn on counter enable
    TIM6->CR1 |= (1 << 0);

}


void delay(int song_duration) {
// calculating timer frequency
    uint32_t timer_freq = 80000000 / (5000 + 1);
// calculating ARR value for counter
    uint32_t arr_val = (timer_freq / 1000) * song_duration - 1;
// set counter max value
    TIM6->ARR = arr_val;
// set update generation to reinitialize counter
    TIM6->EGR |= (1 << 0);
// set UIF to 0
    TIM6->SR &= ~(1 << 0);
// reset counter
    TIM6->CNT = 0;
// wait for max counter value (UIF = 1)
    while ((TIM6->SR & 1) == 0);
}
