const std = @import("std");
const gpio = @import("gpio.zig");
const rcc = @import("rcc.zig");
const spi = @import("spi.zig");

// Responsible for exporting relevant _start and vector table symbols
comptime {
    _ = @import("startup.zig");
    _ = @import("vector_table.zig");
}

const led = gpio.GPIOA.pin(4);

fn delay(cycles: u32) void {
    for (0..cycles) |_| {
        asm volatile ("nop");
    }
}

export fn main() callconv(.c) noreturn {
    const clk = rcc.RCC;
    clk.IOPENR.GPIOAEN = true;

    led.init(.{ .mode = .output, .speed = .high });

    while (true) {
        delay(200000);
        led.write(false);
        delay(200000);
        led.write(true);
    }
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = error_return_trace;
    _ = ret_addr;
    _ = msg;

    while (true) {
        @breakpoint(); // Точка останова для отладчика (GDB/LLDB)
    }
}
