#![no_std]
#![no_main]

use assign_resources::assign_resources;
use defmt::{debug, info, unwrap};
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_rp::gpio::{Input, Level, Output, Pull};
use embassy_time::{Delay, Duration, Ticker, Timer};
use panic_probe as _;
use pico_plc_bsp::peripherals;
use portable_atomic as _;

assign_resources! {
    io: IoPinResources {
        io0: IO_0,
        io1: IO_1,
        io2: IO_2,
        io3: IO_3,
        io4: IO_4,
        io5: IO_5,
    },
    inputs: InputPinResources {
        in0: IN_0,
        in1: IN_1,
        in2: IN_2,
        in3: IN_3,
        in4: IN_4,
        in5: IN_5,
        in6: IN_6,
        in7: IN_7,
    },
    relays: RelayResources {
        relay0: RELAY_0,
        relay1: RELAY_1,
        relay2: RELAY_2,
        relay3: RELAY_3,
        relay4: RELAY_4,
        relay5: RELAY_5,
        relay6: RELAY_6,
        relay7: RELAY_7,
    },
    onewire: OnewireResources {
        pin: ONEWIRE,
    },
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = pico_plc_bsp::peripherals::PicoPlc::default();
    let r = split_resources!(p);

    let led = Output::new(p.PIN_25, Level::Low);

    let io0 = Input::new(r.io.io0, Pull::Up);
    let io1 = Input::new(r.io.io1, Pull::Up);
    let io2 = Input::new(r.io.io2, Pull::Up);
    let io3 = Input::new(r.io.io3, Pull::Up);
    let io4 = Input::new(r.io.io4, Pull::Up);
    let io5 = Input::new(r.io.io5, Pull::Up);

    let in0 = Input::new(r.inputs.in0, Pull::Down);
    let in1 = Input::new(r.inputs.in1, Pull::Down);
    let in2 = Input::new(r.inputs.in2, Pull::Down);
    let in3 = Input::new(r.inputs.in3, Pull::Down);
    let in4 = Input::new(r.inputs.in4, Pull::Down);
    let in5 = Input::new(r.inputs.in5, Pull::Down);
    let in6 = Input::new(r.inputs.in6, Pull::Down);
    let in7 = Input::new(r.inputs.in7, Pull::Down);

    unwrap!(spawner.spawn(read_isolated_input(in0, 0)));
    unwrap!(spawner.spawn(read_isolated_input(in1, 1)));
    unwrap!(spawner.spawn(read_isolated_input(in2, 2)));
    unwrap!(spawner.spawn(read_isolated_input(in3, 3)));
    unwrap!(spawner.spawn(read_isolated_input(in4, 4)));
    unwrap!(spawner.spawn(read_isolated_input(in5, 5)));
    unwrap!(spawner.spawn(read_isolated_input(in6, 6)));
    unwrap!(spawner.spawn(read_isolated_input(in7, 7)));

    unwrap!(spawner.spawn(read_io(io0, 0)));
    unwrap!(spawner.spawn(read_io(io1, 1)));
    unwrap!(spawner.spawn(read_io(io2, 2)));
    unwrap!(spawner.spawn(read_io(io3, 3)));
    unwrap!(spawner.spawn(read_io(io4, 4)));
    unwrap!(spawner.spawn(read_io(io5, 5)));

    unwrap!(spawner.spawn(relay_output(r.relays)));

    unwrap!(spawner.spawn(blink_led(led)));

    unwrap!(spawner.spawn(read_temperature_sensors(r.onewire)));
}

#[derive(Default)]
struct PinChangeDetector {
    last: Option<Level>,
}

impl PinChangeDetector {
    fn update(&mut self, new: Level) -> Option<Level> {
        let changed = self.last != Some(new);
        self.last = Some(new);

        if changed {
            self.last
        } else {
            None
        }
    }
}

fn level_as_str(level: Level) -> &'static str {
    match level {
        Level::Low => "low",
        Level::High => "high",
    }
}

#[embassy_executor::task(pool_size = 8)]
async fn read_isolated_input(input: Input<'static>, num: usize) {
    let mut detector = PinChangeDetector::default();

    loop {
        Timer::after_micros(10).await;

        if let Some(level) = detector.update(input.get_level()) {
            info!("Input {} is {}", num, level_as_str(level));
        }
    }
}

#[embassy_executor::task(pool_size = 6)]
async fn read_io(input: Input<'static>, num: usize) {
    let mut detector = PinChangeDetector::default();

    loop {
        Timer::after_micros(10).await;

        if let Some(level) = detector.update(input.get_level()) {
            info!("IO {} is {}", num, level_as_str(level));
        }
    }
}

#[embassy_executor::task]
async fn blink_led(mut led: Output<'static>) {
    loop {
        led.toggle();
        Timer::after_millis(500).await;
    }
}

#[embassy_executor::task]
async fn relay_output(r: RelayResources) {
    let mut relays = [
        Output::new(r.relay0, Level::Low),
        Output::new(r.relay1, Level::Low),
        Output::new(r.relay2, Level::Low),
        Output::new(r.relay3, Level::Low),
        Output::new(r.relay4, Level::Low),
        Output::new(r.relay5, Level::Low),
        Output::new(r.relay6, Level::Low),
        Output::new(r.relay7, Level::Low),
    ];

    let mut ticker = Ticker::every(Duration::from_secs(1));

    loop {
        for (i, relay) in relays.iter_mut().enumerate() {
            info!("Turning relay {} on", i);
            relay.set_high();

            ticker.next().await;

            info!("Turning relay {} off", i);
            relay.set_low();

            ticker.next().await;
        }
    }
}

#[embassy_executor::task]
async fn read_temperature_sensors(r: OnewireResources) {
    let mut bus = pico_plc_bsp::onewire::new(r.pin).unwrap();

    for device_address in bus.devices(false, &mut Delay) {
        let device_address = device_address.unwrap();
        info!("Found one wire device at address: {}", device_address.0);
    }

    let mut ticker = Ticker::every(Duration::from_secs(5));

    loop {
        ds18b20::start_simultaneous_temp_measurement(&mut bus, &mut Delay).unwrap();

        Timer::after_millis(ds18b20::Resolution::Bits12.max_measurement_time_millis() as u64).await;

        let mut search_state = None;
        while let Some((device_address, state)) = bus
            .device_search(search_state.as_ref(), false, &mut Delay)
            .unwrap()
        {
            search_state = Some(state);

            if device_address.family_code() == ds18b20::FAMILY_CODE {
                debug!("Found DS18B20 at address: {}", device_address.0);

                let sensor = ds18b20::Ds18b20::new::<()>(device_address).unwrap();
                let sensor_data = sensor.read_data(&mut bus, &mut Delay).unwrap();
                info!(
                    "DS18B20 {} is {}°C",
                    device_address.0, sensor_data.temperature
                );
            } else {
                info!(
                    "Found unknown one wire device at address: {}",
                    device_address.0
                );
            }
        }

        ticker.next().await;
    }
}
