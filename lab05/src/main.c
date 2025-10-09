// main.c

#include <stdio.h> 
#include <stm32l4xx.h> 
#include "STM32L432KC.h"

// counters 
volatile int32_t encoder_count = 0; 
volatile uint32_t time = 0; 

const int16_t lookup[16] = { 0, -1, 1, 0, // 00 {00,01,10,11} 
                            1, 0, 0, -1, // 01 {00,01,10,11} 
                            -1, 0, 0, 1, // 10 {00,01,10,11} 
                            0, 1, -1, 0 }; // 11 {00,01,10,11}

// handles external interrupts for pins 5-9
// triggers for when EXTI lines for pins 6 and 7 detect an event on the rising and falling edges
// has lower priority, interrupt handles multiple pins, interrupt pending bit must be cleared
void EXTI9_5_IRQHandler(void) { 

GPIOA->ODR ^= (1 << 2); // pin toggles

// clear interrupt flags for PA6 and PA7 
if (EXTI->PR1 & (1 << 6)) { 
EXTI->PR1 = (1 << 6); // write 1 to clear 
} 

if (EXTI->PR1 & (1 << 7)) { 
EXTI->PR1 = (1 << 7); // write 1 to clear 
}

// get values of PA6 and PA7 
uint8_t A = (GPIOA->IDR & GPIO_IDR_ID6) ? 1 : 0; // PA6 
uint8_t B = (GPIOA->IDR & GPIO_IDR_ID7) ? 1 : 0; // PA7 
// printf("PA6=%d, PA7=%d\n", A, B);

// current state 
uint8_t curr_state = (A << 1) | B; 
// previous state
static volatile uint8_t prev_state = 0;

uint8_t index = (prev_state << 2) | curr_state; 
encoder_count += lookup[index & 0x0F]; 
// printf("encoder count: %d \n", encoder_count);
prev_state = curr_state; 
// printf("A=%d, B=%d, curr_state=%d, prev_state = %d, \n", A, B, curr_state, prev_state);
}

// has priority over EXTI9_5_IRQHandler
// uses the MCU core clock and interrupts based on clock tick
void SysTick_Handler(void) { 

time++; // count to 1000ms 
static int32_t prev_count = 0;

// previous count 
  if (time >= 1000) { 
  // set current count
  int32_t curr_count = encoder_count;
  // change in count      
  int32_t count_diff = curr_count - prev_count;
  printf("count difference: %d \n", count_diff); 

  float rps = count_diff / 1632.0f; 
  printf("Angular velocity in rev/s: %.3f \n", rps); 
        
  prev_count = curr_count;
  time = 0; 
} 
}

int main(void) { 
// enabling pins are inputs 
gpioEnable(GPIO_PORT_A); 
pinMode(PA6, GPIO_INPUT); // setting PA6 
pinMode(PA7, GPIO_INPUT); // setting PA7 
pinMode(PA2, GPIO_OUTPUT); // sett PA5 to toggle on interrupts 

GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD6, 0b01); // set PA6 as pull-up 
GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD7, 0b01); // set PA7 as pull-up 

// enable SYSCFG clock domain in RCC 
RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN; 

// configure EXTICR for input button interrupt 
SYSCFG->EXTICR[1] |= _VAL2FLD(SYSCFG_EXTICR2_EXTI6, 0b000); // PA6 
SYSCFG->EXTICR[1] |= _VAL2FLD(SYSCFG_EXTICR2_EXTI7, 0b000); // PA7 

// enable interrupts globally 
__enable_irq(); 

// configure interrupts for rising and falling edge of GPIO pin 
// 1. configure mask bit 
EXTI->IMR1 |= (1 << gpioPinOffset(PA6)); 
EXTI->IMR1 |= (1 << gpioPinOffset(PA7)); 
// 2. configure rising edge trigger 
EXTI->RTSR1 |= (1 << gpioPinOffset(PA6)); 
EXTI->RTSR1 |= (1 << gpioPinOffset(PA7)); 
// 3. configure falling edge trigger 
EXTI->FTSR1 |= (1 << gpioPinOffset(PA6)); 
EXTI->FTSR1 |= (1 << gpioPinOffset(PA7)); 
// 4. turn on EXTI interupt in NVIC_ISER 
NVIC_EnableIRQ(EXTI9_5_IRQn); 


// number of clock cycles per ms 
SysTick_Config(SystemCoreClock/1000); 


while(1){ 

} 

}



//// for polling
//int main(void) {
//// gpio inputs and outputs
//    gpioEnable(GPIO_PORT_A); 
//    pinMode(PA6, GPIO_INPUT); 
//    pinMode(PA7, GPIO_INPUT); 
//    pinMode(PA2, GPIO_OUTPUT); 

//    // set pins as pullups
//    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD6, 0b01); // set PA6 as pull-up 
//    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD7, 0b01); // set PA7 as pull-up 

//    // set up timer
//    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
//    TIM2->CR1 = 0;
//    TIM2->CNT = 0;
//    TIM2->PSC = (SystemCoreClock / 1000) - 1;
//    TIM2->ARR = 0xFFFFFFFF;
//    TIM2->EGR = TIM_EGR_UG;
//    TIM2->CR1 |= TIM_CR1_CEN;

//    // variables for encoder
//    int32_t count = 0;
//    int32_t prev_count = 0;
//    uint8_t prev_state = 0;
//    uint32_t prev_time = TIM2->CNT;

//    while (1) {
//        // read encoder pins
//        uint8_t A = digitalRead(PA6);
//        uint8_t B = digitalRead(PA7);
//        // set current state
//        uint8_t curr_state = (A << 1) | B;

//        // add to counter when state change detected
//        if (curr_state != prev_state) {
//            uint8_t index = (prev_state << 2) | curr_state;
//            count += lookup[index & 0x0F];

//            // toggle pin to indicate polling
//            GPIOA->ODR ^= (1 << 2);
//            prev_state = curr_state;
//        }

//        // calculating angular velocity every second
//        uint32_t curr_time = TIM2->CNT;
//        if ((uint32_t)(curr_time - prev_time) >= 1000) {
//            int32_t delta_count = count - prev_count;
//            prev_count = count;
//            prev_time = curr_time;

//            float rps = delta_count / 1632.0f;
//            printf("Angular velocity: %.3f rev/s\n", rps);
//        }
//    }
//}

               