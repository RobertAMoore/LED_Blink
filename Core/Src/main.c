/*******************************************************
 * @file main.c
 * @author Robert Allen Moore III
 * @brief LED_BLINK main program body
 * 
 * 8 LEDs are toggled on and off simultaneously when
 * SysTick interrupt fires
 * *****************************************************/

#include "main.h"

static void system_clock_config(void);

int main(void)
{
    system_clock_config();
    led_init();
    start_blinking();
    
    while (1)
    {
    }
}

/** @brief Intitialize System clock
 *         The system clock configuration is as follows:
 *          System Clock source         = HSE BYPASS
 *          HSE Frequency(Hz)           = 8000000
 *          SYSCLK(Hz)                  = 8000000
 *          HCLK(Hz)                    = 8000000
 *          AHB Prescaler               = 1
 *          APB1 Prescaler              = 1
 *          APB2 Prescaler              = 1
 * 
 *  @param none
 *  @retval none
 */
static void system_clock_config(void)
{
    SET_BIT(RCC->CR, RCC_CR_CSSON);         //Turn on clock security
    SET_BIT(RCC->CR, RCC_CR_HSEBYP);        //Set HSE Bypass
    SET_BIT(RCC->CR, RCC_CR_HSEON);         //Turn on HSE clock
    
    while (!(READ_BIT(RCC->CR, RCC_CR_HSERDY)))
    {
        //Wait for HSE to be ready
    }
    
    SET_BIT(RCC->CFGR, RCC_CFGR_HPRE_DIV1);         //HCLK max 72Mhz
    SET_BIT(RCC->CFGR, RCC_CFGR_PPRE1_DIV1);        //APB1 max 36Mhz
    SET_BIT(RCC->CFGR, RCC_CFGR_PPRE2_DIV1);        //APB2 max 72Mhz
    
    SET_BIT(RCC->CFGR, RCC_CFGR_SW_HSE);            //Use HSE as system clock
    CLEAR_BIT(RCC->CR, RCC_CR_HSION);               //Turn off HSI
    
    SystemCoreClockUpdate();
}
