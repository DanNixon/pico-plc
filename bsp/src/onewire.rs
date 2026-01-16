use crate::peripherals::ONEWIRE;
use core::convert::Infallible;
use embassy_rp::{
    Peri,
    gpio::{Level, OutputOpenDrain},
};
use one_wire_bus::{OneWire, OneWireResult};

pub fn new(
    pin: Peri<'static, ONEWIRE>,
) -> OneWireResult<OneWire<OutputOpenDrain<'static>>, Infallible> {
    let pin = OutputOpenDrain::new(pin, Level::Low);
    OneWire::new(pin)
}
