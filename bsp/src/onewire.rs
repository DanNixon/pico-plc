use crate::peripherals::ONEWIRE;
use core::convert::Infallible;
use embassy_rp::{
    gpio::{Level, OutputOpenDrain},
    Peri,
};
use one_wire_bus::{OneWire, OneWireResult};

pub fn new(
    pin: Peri<'static, ONEWIRE>,
) -> OneWireResult<OneWire<OutputOpenDrain<'static>>, Infallible> {
    let pin = OutputOpenDrain::new(pin, Level::Low);
    OneWire::new(pin)
}
