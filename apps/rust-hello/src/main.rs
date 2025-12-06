#![no_std]
#![no_main]

use core::arch::global_asm;
use core::arch::asm;
use core::panic::PanicInfo;

// fetch IOREQ definitions from C header
include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

// startup code
global_asm!(include_str!("../../crt0.s"));

fn println(message: &str) {
    unsafe {
        asm!(
            "csrw {i}, {x}",
            i = const IOREQ_PRINTLN,
            x = in(reg) message.as_ptr(),
        );
    }
}

fn printd(n: u32) {
    unsafe {
        asm!(
            "csrw {i}, {x}",
            i = const IOREQ_PRINTD,
            x = in(reg) n,
        );
    }
}

#[no_mangle]
pub extern "C" fn main() {
    for i in 0..10 {
        printd(i);
    }
    println("Hello, world!");
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    //println("Something went wrong");
    loop {
        continue;
    }
}
