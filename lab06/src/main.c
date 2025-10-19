// lab 6 main.c file
// Julia Gong
// 10/12/2025

#include "STM32L432KC.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "DS1722.h"
#include "main.h"

///////////////////////////////////
// Provided Constants and Functions
///////////////////////////////////

//Defining webpage into 2 chunctions: everything before current time, and everything after current time
char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Web Server Demo Webpage</title>\
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
	</head>\
	<body><h1>E155 Web Server Demo Webpage</h1>";
char* ledStr = "<p>LED Control:</p><form action=\"ledon\"><input type=\"submit\" value=\"Turn the LED on!\"></form>\
	<form action=\"ledoff\"><input type=\"submit\" value=\"Turn the LED off!\"></form>";

char* tempStr = "<p>Temperature Bit Control:</p>\
                <form action=\"8bit\"><input type=\"submit\" value=\"8bit\"></form>\
                <form action=\"9bit\"><input type=\"submit\" value=\"9bit\"></form>\
                <form action=\"10bit\"><input type=\"submit\" value=\"10bit\"></form>\
                <form action=\"11bit\"><input type=\"submit\" value=\"11bit\"></form>\
                <form action=\"12bit\"><input type=\"submit\" value=\"12bit\"></form>";

char* webpageEnd   = "</body></html>";

//determines whether a character sequence is in a char array request, returns 1 if present, and -1 if not present
int inString(char request[], char des[]) {
  if (strstr(request, des) != NULL) {return 1;} // strstr searches for occurance of des in request
  return -1;
}

int updateLEDStatus(char request[])
{
  int led_status = 0;
  // process led ON or OFF based on request
  if (inString(request, "ledoff") == 1) {
    digitalWrite(LED_PIN, PIO_LOW); // write 0 value to pin
    led_status = 0;
  }

  else if (inString(request, "ledon") == 1) {
    digitalWrite(LED_PIN, PIO_HIGH); // write 1 value to pin
    led_status = 1;
  }

  return led_status;

}

void updateTemp(char request[])
{
  int temp_bit = 0;
  // determine the number of bits for temp following request
  if (inString(request, "8bit") == 1) {
    send_bits(8);
  }
  else if (inString(request, "9bit") == 1) {
    send_bits(9);
  }
  else if (inString(request, "10bit") == 1) {
    send_bits(10);
  }
  else if (inString(request, "11bit") == 1) {
    send_bits(11);
  }
  else if (inString(request, "12bit") == 1) {
    send_bits(12);
  }
}

// Solution Functions
int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  gpioEnable(GPIO_PORT_C);

  initTIM(TIM15);

  pinMode(PA6, GPIO_OUTPUT);
  digitalWrite(PA6, 0);

  USART_TypeDef * USART = initUSART(USART1_ID, 125000); // pointer to control USART peripheral, set 125000 baud rate

  //initialize SPI
  // from datasheet CPHA must be set to 1
  // tolerates maximum 5MHz
  initSPI(0b100, 0, 1);

  // initialize temp senesor
  initTemp();

  
  while(1) {
  // wait for ESP8266 to send a request
  // requests are in the form '/REQ:<tag>\n, with TAG begin <+ 10 characters
  // request[] array must be able to contain more than 18 characters

  // Receive web request from the ESP
    char request[BUFF_LEN] = "                  "; // initialize to known value
    int charIndex = 0;

    // Keep going until you get end of line character
    while(inString(request, "\n") == -1) {
      // Wait for a complete request to be transmitted before processing
      while(!(USART->ISR & USART_ISR_RXNE));
      request[charIndex++] = readChar(USART);
    }

  // add SPI code to read temperature
   updateTemp(request);
   float temp = read_temp();

  // update string with current LED state
  int led_status = updateLEDStatus(request);

  char ledStatusStr[20];
  if (led_status == 1)
    sprintf(ledStatusStr, "LED is on!");
  else if (led_status == 0)
    sprintf(ledStatusStr, "LED is off!");

   char tempStatusStr[32];
   sprintf(tempStatusStr, "Temperature %.7f", temp);
  
  // trasmit webpage over UART
  sendString(USART, webpageStart); // webpage header code
  sendString(USART, ledStr); // button for controlling LED
  sendString(USART, tempStr); // buttons for controlling temp bits

  //sendString(USART, "<h2>LED Status </h2>");

  //sendString(USART, "<p>");
  //sendString(USART, ledStatusStr);
  //sendString(USART, "</p>");

  sendString(USART, "<p>");
  sendString(USART, tempStatusStr);
  sendString(USART, "</p>");

  sendString(USART, webpageEnd);

  }

}

