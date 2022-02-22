/*******************************************************
 * @file led.h
 * @author Robert Allen Moore III
 * @brief LED_BLINK header file for LED driver
 * 
 * 	led_init() must be called before making use of
 * 	the driver.
 * 
 * 	Use the start_blinking() function to blink the 
 * 	LEDs in an interrupt based, non-blocking 
 * 	manner.
 * 
 * 	Alternatively, the TOGGLE_LED() function-like
 * 	macro may be used directly to toggle the state
 * 	of the specified LEDs. 
 * 
 * *****************************************************/
 
#ifndef __LED_H
#define __LED_H

#ifdef __cplusplus
 extern "C" {
#endif /*__cplusplus*/

#include "stm32f3xx.h"

#define LD3			(GPIO_ODR_9)
#define LD4			(GPIO_ODR_8)
#define LD5			(GPIO_ODR_10)
#define LD6			(GPIO_ODR_15)
#define LD7			(GPIO_ODR_11)
#define LD8			(GPIO_ODR_14)
#define LD9			(GPIO_ODR_12)
#define LD10			(GPIO_ODR_13)
#define ALL_LEDS 		(0x0000FF00U)	
#define TOGGLE_LED(LED)		(GPIOE->ODR ^= (LED))

void led_init(void);
void start_blinking(void);

#ifdef __cplusplus
}
#endif /*__cplusplus*/

#endif /* __LED_H */
