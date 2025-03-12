// Non renamed re-exported peripherals
pub use embassy_rp::peripherals::{
    ADC, ADC_TEMP_SENSOR, BOOTSEL, CORE1, DMA_CH0, DMA_CH1, DMA_CH10, DMA_CH11, DMA_CH2, DMA_CH3,
    DMA_CH4, DMA_CH5, DMA_CH6, DMA_CH7, DMA_CH8, DMA_CH9, FLASH, I2C0, I2C1, PIN_23, PIN_24,
    PIN_25, PIN_26, PIN_27, PIN_28, PIN_29, PIN_QSPI_SCLK, PIN_QSPI_SD0, PIN_QSPI_SD1,
    PIN_QSPI_SD2, PIN_QSPI_SD3, PIN_QSPI_SS, PIO0, PIO1, PWM_SLICE0, PWM_SLICE1, PWM_SLICE2,
    PWM_SLICE3, PWM_SLICE4, PWM_SLICE5, PWM_SLICE6, PWM_SLICE7, RTC, SPI0, SPI1, UART0, UART1, USB,
    WATCHDOG,
};

// Renamed IO pins
pub use embassy_rp::peripherals::{
    PIN_0 as IO_0, PIN_1 as IO_1, PIN_2 as IO_2, PIN_3 as IO_3, PIN_4 as IO_4, PIN_5 as IO_5,
};

// Renamed input pins
pub use embassy_rp::peripherals::{
    PIN_10 as IN_5, PIN_11 as IN_4, PIN_12 as IN_3, PIN_13 as IN_2, PIN_14 as IN_1, PIN_15 as IN_0,
    PIN_8 as IN_7, PIN_9 as IN_6,
};

// Renamed relay pins
pub use embassy_rp::peripherals::{
    PIN_16 as RELAY_2, PIN_17 as RELAY_3, PIN_18 as RELAY_4, PIN_19 as RELAY_5, PIN_20 as RELAY_6,
    PIN_21 as RELAY_7, PIN_6 as RELAY_1, PIN_7 as RELAY_0,
};

// Renamed onewire bus pin
pub use embassy_rp::peripherals::PIN_22 as ONEWIRE;

#[allow(non_snake_case)]
pub struct PicoPlc {
    pub IO_0: IO_0,
    pub IO_1: IO_1,
    pub IO_2: IO_2,
    pub IO_3: IO_3,
    pub IO_4: IO_4,
    pub IO_5: IO_5,

    pub IN_0: IN_0,
    pub IN_1: IN_1,
    pub IN_2: IN_2,
    pub IN_3: IN_3,
    pub IN_4: IN_4,
    pub IN_5: IN_5,
    pub IN_6: IN_6,
    pub IN_7: IN_7,

    pub RELAY_0: RELAY_0,
    pub RELAY_1: RELAY_1,
    pub RELAY_2: RELAY_2,
    pub RELAY_3: RELAY_3,
    pub RELAY_4: RELAY_4,
    pub RELAY_5: RELAY_5,
    pub RELAY_6: RELAY_6,
    pub RELAY_7: RELAY_7,

    pub ONEWIRE: ONEWIRE,

    pub PIN_23: PIN_23,
    pub PIN_24: PIN_24,
    pub PIN_25: PIN_25,
    pub PIN_26: PIN_26,
    pub PIN_27: PIN_27,
    pub PIN_28: PIN_28,
    pub PIN_29: PIN_29,
    pub PIN_QSPI_SCLK: PIN_QSPI_SCLK,
    pub PIN_QSPI_SS: PIN_QSPI_SS,
    pub PIN_QSPI_SD0: PIN_QSPI_SD0,
    pub PIN_QSPI_SD1: PIN_QSPI_SD1,
    pub PIN_QSPI_SD2: PIN_QSPI_SD2,
    pub PIN_QSPI_SD3: PIN_QSPI_SD3,
    pub UART0: UART0,
    pub UART1: UART1,
    pub SPI0: SPI0,
    pub SPI1: SPI1,
    pub I2C0: I2C0,
    pub I2C1: I2C1,
    pub DMA_CH0: DMA_CH0,
    pub DMA_CH1: DMA_CH1,
    pub DMA_CH2: DMA_CH2,
    pub DMA_CH3: DMA_CH3,
    pub DMA_CH4: DMA_CH4,
    pub DMA_CH5: DMA_CH5,
    pub DMA_CH6: DMA_CH6,
    pub DMA_CH7: DMA_CH7,
    pub DMA_CH8: DMA_CH8,
    pub DMA_CH9: DMA_CH9,
    pub DMA_CH10: DMA_CH10,
    pub DMA_CH11: DMA_CH11,
    pub PWM_SLICE0: PWM_SLICE0,
    pub PWM_SLICE1: PWM_SLICE1,
    pub PWM_SLICE2: PWM_SLICE2,
    pub PWM_SLICE3: PWM_SLICE3,
    pub PWM_SLICE4: PWM_SLICE4,
    pub PWM_SLICE5: PWM_SLICE5,
    pub PWM_SLICE6: PWM_SLICE6,
    pub PWM_SLICE7: PWM_SLICE7,
    pub USB: USB,
    pub RTC: RTC,
    pub FLASH: FLASH,
    pub ADC: ADC,
    pub ADC_TEMP_SENSOR: ADC_TEMP_SENSOR,
    pub CORE1: CORE1,
    pub PIO0: PIO0,
    pub PIO1: PIO1,
    pub WATCHDOG: WATCHDOG,
    pub BOOTSEL: BOOTSEL,
}

impl Default for PicoPlc {
    fn default() -> Self {
        Self::new(Default::default())
    }
}

impl PicoPlc {
    pub fn new(config: embassy_rp::config::Config) -> Self {
        let p = embassy_rp::init(config);
        Self {
            IO_0: p.PIN_0,
            IO_1: p.PIN_1,
            IO_2: p.PIN_2,
            IO_3: p.PIN_3,
            IO_4: p.PIN_4,
            IO_5: p.PIN_5,
            RELAY_1: p.PIN_6,
            RELAY_0: p.PIN_7,
            IN_7: p.PIN_8,
            IN_6: p.PIN_9,
            IN_5: p.PIN_10,
            IN_4: p.PIN_11,
            IN_3: p.PIN_12,
            IN_2: p.PIN_13,
            IN_1: p.PIN_14,
            IN_0: p.PIN_15,
            RELAY_2: p.PIN_16,
            RELAY_3: p.PIN_17,
            RELAY_4: p.PIN_18,
            RELAY_5: p.PIN_19,
            RELAY_6: p.PIN_20,
            RELAY_7: p.PIN_21,
            ONEWIRE: p.PIN_22,
            PIN_23: p.PIN_23,
            PIN_24: p.PIN_24,
            PIN_25: p.PIN_25,
            PIN_26: p.PIN_26,
            PIN_27: p.PIN_27,
            PIN_28: p.PIN_28,
            PIN_29: p.PIN_29,
            PIN_QSPI_SCLK: p.PIN_QSPI_SCLK,
            PIN_QSPI_SS: p.PIN_QSPI_SS,
            PIN_QSPI_SD0: p.PIN_QSPI_SD0,
            PIN_QSPI_SD1: p.PIN_QSPI_SD1,
            PIN_QSPI_SD2: p.PIN_QSPI_SD2,
            PIN_QSPI_SD3: p.PIN_QSPI_SD3,
            UART0: p.UART0,
            UART1: p.UART1,
            SPI0: p.SPI0,
            SPI1: p.SPI1,
            I2C0: p.I2C0,
            I2C1: p.I2C1,
            DMA_CH0: p.DMA_CH0,
            DMA_CH1: p.DMA_CH1,
            DMA_CH2: p.DMA_CH2,
            DMA_CH3: p.DMA_CH3,
            DMA_CH4: p.DMA_CH4,
            DMA_CH5: p.DMA_CH5,
            DMA_CH6: p.DMA_CH6,
            DMA_CH7: p.DMA_CH7,
            DMA_CH8: p.DMA_CH8,
            DMA_CH9: p.DMA_CH9,
            DMA_CH10: p.DMA_CH10,
            DMA_CH11: p.DMA_CH11,
            PWM_SLICE0: p.PWM_SLICE0,
            PWM_SLICE1: p.PWM_SLICE1,
            PWM_SLICE2: p.PWM_SLICE2,
            PWM_SLICE3: p.PWM_SLICE3,
            PWM_SLICE4: p.PWM_SLICE4,
            PWM_SLICE5: p.PWM_SLICE5,
            PWM_SLICE6: p.PWM_SLICE6,
            PWM_SLICE7: p.PWM_SLICE7,
            USB: p.USB,
            RTC: p.RTC,
            FLASH: p.FLASH,
            ADC: p.ADC,
            ADC_TEMP_SENSOR: p.ADC_TEMP_SENSOR,
            CORE1: p.CORE1,
            PIO0: p.PIO0,
            PIO1: p.PIO1,
            WATCHDOG: p.WATCHDOG,
            BOOTSEL: p.BOOTSEL,
        }
    }
}
