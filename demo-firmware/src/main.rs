#![no_std]
#![no_main]

use defmt::{debug, info, unwrap};
use defmt_rtt as _;
use embassy_executor::{Executor, Spawner};
use embassy_rp::{
    gpio::{Input, Level, Output, OutputOpenDrain, Pull},
    multicore::{spawn_core1, Stack},
    watchdog::Watchdog,
};
use embassy_sync::{blocking_mutex::raw::CriticalSectionRawMutex, channel::Channel};
use embassy_time::{Duration, Ticker, Timer};
use one_wire_bus::OneWire;
#[cfg(feature = "panic-probe")]
use panic_probe as _;
use static_cell::StaticCell;

#[cfg(not(feature = "panic-probe"))]
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    let p = unsafe { embassy_rp::Peripherals::steal() };

    // Blink the on-board LED pretty fast
    let mut led = Output::new(p.PIN_25, Level::Low);
    loop {
        led.toggle();
        embassy_time::block_for(Duration::from_millis(50));
    }
}

static mut CORE1_STACK: Stack<4096> = Stack::new();
static EXECUTOR0: StaticCell<Executor> = StaticCell::new();
static EXECUTOR1: StaticCell<Executor> = StaticCell::new();

static CHANNEL: Channel<CriticalSectionRawMutex, Event, 1> = Channel::new();

enum Event {
    IsolatedInputChanged { num: usize, level: Level },
    GeneralIoChanged { num: usize, level: Level },
}

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    let p = embassy_rp::init(Default::default());

    let mut watchdog = Watchdog::new(p.WATCHDOG);
    watchdog.start(Duration::from_millis(550));

    let io0 = Input::new(p.PIN_0, Pull::Up);
    let io1 = Input::new(p.PIN_1, Pull::Up);
    let io2 = Input::new(p.PIN_2, Pull::Up);
    let io3 = Input::new(p.PIN_3, Pull::Up);
    let io4 = Input::new(p.PIN_4, Pull::Up);
    let io5 = Input::new(p.PIN_5, Pull::Up);

    let in0 = Input::new(p.PIN_15, Pull::Down);
    let in1 = Input::new(p.PIN_14, Pull::Down);
    let in2 = Input::new(p.PIN_13, Pull::Down);
    let in3 = Input::new(p.PIN_12, Pull::Down);
    let in4 = Input::new(p.PIN_11, Pull::Down);
    let in5 = Input::new(p.PIN_10, Pull::Down);
    let in6 = Input::new(p.PIN_9, Pull::Down);
    let in7 = Input::new(p.PIN_8, Pull::Down);

    let relay0 = Output::new(p.PIN_7, Level::Low);
    let relay1 = Output::new(p.PIN_6, Level::Low);
    let relay2 = Output::new(p.PIN_16, Level::Low);
    let relay3 = Output::new(p.PIN_17, Level::Low);
    let relay4 = Output::new(p.PIN_18, Level::Low);
    let relay5 = Output::new(p.PIN_19, Level::Low);
    let relay6 = Output::new(p.PIN_20, Level::Low);
    let relay7 = Output::new(p.PIN_21, Level::Low);

    let led = Output::new(p.PIN_25, Level::Low);

    let mut onewire_bus = {
        let pin = OutputOpenDrain::new(p.PIN_22, Level::Low);
        OneWire::new(pin).unwrap()
    };

    for device_address in onewire_bus.devices(false, &mut embassy_time::Delay) {
        let device_address = device_address.unwrap();
        info!("Found one wire device at address: {}", device_address.0);
    }

    spawn_core1(
        p.CORE1,
        unsafe { &mut *core::ptr::addr_of_mut!(CORE1_STACK) },
        move || {
            let executor1 = EXECUTOR1.init(Executor::new());
            executor1.run(|spawner| {
                unwrap!(spawner.spawn(watchdog_feed(watchdog)));

                unwrap!(spawner.spawn(watch_input(in0, 0)));
                unwrap!(spawner.spawn(watch_input(in1, 1)));
                unwrap!(spawner.spawn(watch_input(in2, 2)));
                unwrap!(spawner.spawn(watch_input(in3, 3)));
                unwrap!(spawner.spawn(watch_input(in4, 4)));
                unwrap!(spawner.spawn(watch_input(in5, 5)));
                unwrap!(spawner.spawn(watch_input(in6, 6)));
                unwrap!(spawner.spawn(watch_input(in7, 7)));

                unwrap!(spawner.spawn(watch_io(io0, 0)));
                unwrap!(spawner.spawn(watch_io(io1, 1)));
                unwrap!(spawner.spawn(watch_io(io2, 2)));
                unwrap!(spawner.spawn(watch_io(io3, 3)));
                unwrap!(spawner.spawn(watch_io(io4, 4)));
                unwrap!(spawner.spawn(watch_io(io5, 5)));

                unwrap!(spawner.spawn(relay_output(
                    relay0, relay1, relay2, relay3, relay4, relay5, relay6, relay7,
                )));
            });
        },
    );

    let executor0 = EXECUTOR0.init(Executor::new());
    executor0.run(|spawner| {
        unwrap!(spawner.spawn(blink_led(led)));
        unwrap!(spawner.spawn(read_temperatures(onewire_bus)));
    });
}

#[embassy_executor::task]
async fn watchdog_feed(mut watchdog: Watchdog) {
    loop {
        watchdog.feed();
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

        if changed {
            self.last
        } else {
            None
        }
    }
}

#[embassy_executor::task(pool_size = 8)]
async fn watch_input(input: Input<'static>, num: usize) {
    let mut detector = PinChangeDetector::default();

    loop {
        Timer::after_micros(10).await;

        if let Some(level) = detector.update(input.get_level()) {
            CHANNEL
                .send(Event::IsolatedInputChanged { num, level })
                .await;
        }
    }
}

#[embassy_executor::task(pool_size = 6)]
async fn watch_io(input: Input<'static>, num: usize) {
    let mut detector = PinChangeDetector::default();

    loop {
        Timer::after_micros(10).await;

        if let Some(level) = detector.update(input.get_level()) {
            CHANNEL.send(Event::GeneralIoChanged { num, level }).await;
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

fn level_as_str(level: Level) -> &'static str {
    match level {
        Level::Low => "low",
        Level::High => "high",
    }
}

#[allow(clippy::too_many_arguments)]
#[embassy_executor::task]
async fn relay_output(
    mut relay0: Output<'static>,
    mut relay1: Output<'static>,
    mut relay2: Output<'static>,
    mut relay3: Output<'static>,
    mut relay4: Output<'static>,
    mut relay5: Output<'static>,
    mut relay6: Output<'static>,
    mut relay7: Output<'static>,
) {
    loop {
        let event = CHANNEL.receive().await;

        let (relay_idx, level) = match event {
            Event::IsolatedInputChanged { num, level } => {
                info!("Input {} is {}", num, level_as_str(level),);
                (num, level)
            }
            Event::GeneralIoChanged { num, level } => {
                info!("IO {} is {}", num, level_as_str(level),);
                (num, level)
            }
        };

        match relay_idx {
            0 => relay0.set_level(level),
            1 => relay1.set_level(level),
            2 => relay2.set_level(level),
            3 => relay3.set_level(level),
            4 => relay4.set_level(level),
            5 => relay5.set_level(level),
            6 => relay6.set_level(level),
            7 => relay7.set_level(level),
            _ => {}
        };
    }
}

#[embassy_executor::task]
async fn read_temperatures(mut bus: OneWire<OutputOpenDrain<'static>>) {
    let mut delay = embassy_time::Delay;

    let mut ticker = Ticker::every(Duration::from_secs(5));

    loop {
        ds18b20::start_simultaneous_temp_measurement(&mut bus, &mut delay).unwrap();

        Timer::after_millis(ds18b20::Resolution::Bits12.max_measurement_time_millis() as u64).await;

        let mut search_state = None;
        while let Some((device_address, state)) = bus
            .device_search(search_state.as_ref(), false, &mut delay)
            .unwrap()
        {
            search_state = Some(state);

            if device_address.family_code() == ds18b20::FAMILY_CODE {
                debug!("Found DS18B20 at address: {}", device_address.0);

                let sensor = ds18b20::Ds18b20::new::<()>(device_address).unwrap();
                let sensor_data = sensor.read_data(&mut bus, &mut delay).unwrap();
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
