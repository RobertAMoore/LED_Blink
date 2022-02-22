/*******************************************************
 * @file led.c
 * @author Robert Allen Moore III
 * @brief LED_BLINK LED driver body
 * 
 * This file initializes and controls 8 LEDs 
 * connected to pins 8-15 of GPIO Port E
 * *****************************************************/
 
#include "led.h"

#define PULLDOWN_UNUSED_PINS 	(0x0000AAAAU)	//Pins 0-7 not used
#define SET_OUPUT_PINS 		    (0x55550000U)   //Pins 8-15 to be outputs
#define TICKS                   (SystemCoreClock/2)

/** @brief Enable clock for GPIOE and initialize values of 
 * 	   GPIO control registers appropriately.
 * 
 *  @note GPIOE->OTYPER already has all pins set to "push-pull" 
 * 	  by default and GPIOE->OSPEEDR has all pins set to 
 * 	  "low" speed by default. These registers do not need 
 * 	  to be modified.
 * 
 *  @param none
 *  @retval none
 */
void led_init(void)
{
    SET_BIT(RCC->AHBENR, RCC_AHBENR_GPIOEEN);
    
    WRITE_REG(GPIOE->PUPDR, PULLDOWN_UNUSED_PINS); 
    WRITE_REG(GPIOE->MODER, SET_OUPUT_PINS); 
}

/** @brief Initializes and enables the SysTick to fire an 
 *         interrupt every 500ms. 
 * 
 *  @note The SysTick LOAD register is only 24 bits wide so 
 *        this function's implementation and/or the TICK macro 
 *        may need to change with a faster clock or different 
 *        timing requirements.
 * 
 * @param none
 * @retval none
 */
void start_blinking(void)
{
    SysTick_Config(TICKS); //function defined in core_cm4.h
}
