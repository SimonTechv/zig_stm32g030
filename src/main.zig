const std = @import("std");
const gpio = @import("gpio.zig");
const rcc = @import("rcc.zig");
const spi = @import("spi.zig");

// Responsible for exporting relevant _start and vector table symbols
comptime {
    _ = @import("startup.zig");
    _ = @import("vector_table.zig");
}

const cs = gpio.GPIOA.pin(4);
const mosi = gpio.GPIOA.pin(7);
const miso = gpio.GPIOA.pin(6);
const clk = gpio.GPIOA.pin(5);

fn delay(cycles: u32) void {
    for (0..cycles) |_| {
        asm volatile ("nop");
    }
}

export fn main() callconv(.c) noreturn {

    // Enable GPIOA
    rcc.RCC.IOPENR.GPIOAEN = true;
    rcc.RCC.APBENR2.SPI1EN = true;

    // GPIO's init
    cs.init(.{ .mode = .output, .speed = .high });
    mosi.init(.{ .mode = .alternate_function, .speed = .high, .af = .af0 });
    miso.init(.{ .mode = .alternate_function, .speed = .high, .af = .af0 });
    clk.init(.{ .mode = .alternate_function, .speed = .high, .af = .af0 });

    cs.write(true); // CS high

    // SPI periphery init
    spi.SpiInit(spi.SPI1, .{
        .mode = .master,
        .direction = .full_duplex,
        .baud_rate_div = .div8,
        .cpol = .idle_low,
        .cpha = .first_edge,
        .bit_order = .msb_first,
        .data_size = .bits_8,
        .software_nss = true,
    });

    while (true) {
        delay(1000);
        _ = spi.TransferByte(spi.SPI1, 0x55);
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
