#![no_std]
#![no_main]

use assign_resources::assign_resources;
use defmt::{debug, info};
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_rp::{
    Peri,
    gpio::{Input, Level, Output, OutputOpenDrain, Pull},
    peripherals,
};
use embassy_time::{Delay, Duration, Ticker, Timer};
use one_wire_bus::OneWire;
use panic_probe as _;

assign_resources! {
    inputs: InputPinResources {
        in1: PIN_5,
        in2: PIN_6,
        in3: PIN_7,
        in4: PIN_2,
        in5: PIN_3,
        in6: PIN_4,
        in7: PIN_1,
        in8: PIN_0,
    },
    relays: RelayResources {
        relay1: PIN_8,
        relay2: PIN_9,
        relay3: PIN_10,
        relay4: PIN_11,
        relay5: PIN_12,
        relay6: PIN_13,
        relay7: PIN_14,
        relay8: PIN_15,
    },
    onewire: OnewireResources {
        pin: PIN_28,
    },
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_rp::init(Default::default());
    let r = split_resources!(p);

    let led = Output::new(p.PIN_25, Level::Low);

    spawner.must_spawn(blink_led(led));

    let in1 = Input::new(r.inputs.in1, Pull::Down);
    let in2 = Input::new(r.inputs.in2, Pull::Down);
    let in3 = Input::new(r.inputs.in3, Pull::Down);
    let in4 = Input::new(r.inputs.in4, Pull::Down);
    let in5 = Input::new(r.inputs.in5, Pull::Down);
    let in6 = Input::new(r.inputs.in6, Pull::Down);
    let in7 = Input::new(r.inputs.in7, Pull::Down);
    let in8 = Input::new(r.inputs.in8, Pull::Down);

    spawner.must_spawn(read_isolated_input(in1, 1));
    spawner.must_spawn(read_isolated_input(in2, 2));
    spawner.must_spawn(read_isolated_input(in3, 3));
    spawner.must_spawn(read_isolated_input(in4, 4));
    spawner.must_spawn(read_isolated_input(in5, 5));
    spawner.must_spawn(read_isolated_input(in6, 6));
    spawner.must_spawn(read_isolated_input(in7, 7));
    spawner.must_spawn(read_isolated_input(in8, 8));

    spawner.must_spawn(relay_output(r.relays));

    spawner.must_spawn(read_temperature_sensors(r.onewire));
}

#[embassy_executor::task]
async fn blink_led(mut led: Output<'static>) {
    loop {
        led.toggle();
        Timer::after_millis(500).await;
    }
}

#[derive(Default)]
struct PinChangeDetector {
    last: Option<Level>,
}

impl PinChangeDetector {
    fn update(&mut self, new: Level) -> Option<Level> {
        let changed = self.last != Some(new);
        self.last = Some(new);

        if changed { self.last } else { None }
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

#[embassy_executor::task]
async fn relay_output(r: RelayResources) {
    let mut relays = [
        Output::new(r.relay1, Level::Low),
        Output::new(r.relay2, Level::Low),
        Output::new(r.relay3, Level::Low),
        Output::new(r.relay4, Level::Low),
        Output::new(r.relay5, Level::Low),
        Output::new(r.relay6, Level::Low),
        Output::new(r.relay7, Level::Low),
        Output::new(r.relay8, Level::Low),
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
    let pin = OutputOpenDrain::new(r.pin, Level::Low);
    let mut bus = OneWire::new(pin).unwrap();

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
