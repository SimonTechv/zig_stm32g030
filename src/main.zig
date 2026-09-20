const std = @import("std");
const gpio = @import("gpio.zig");
const rcc = @import("rcc.zig");
const spi = @import("spi.zig");
const epd = @import("epd_driver.zig");
const systick = @import("systick.zig");
const fb = @import("framebuf.zig");

// Responsible for exporting relevant _start and vector table symbols
comptime {
    _ = @import("startup.zig");
    _ = @import("vector_table.zig");
}

const rst = gpio.GPIOA.pin(0);
const bsy = gpio.GPIOA.pin(1);
const cs = gpio.GPIOA.pin(4);
const di = gpio.GPIOA.pin(7);
const clk = gpio.GPIOA.pin(5);
const dc = gpio.GPIOA.pin(8);

const time = systick.Time(16_000_000);

pub const EPDHal = struct {
    /// SPI write for commands and data
    pub fn spiWrite(bytes: []const u8) void {
        spi.Write8(spi.SPI1, bytes);
    }

    /// Chip Select: false = 0 (Active), true = 1 (Deselected)
    pub fn setCs(high: bool) void {
        cs.write(high);
    }

    /// Data / Command: false = 0 (Command), true = 1 (Data)
    pub fn setDc(high: bool) void {
        dc.write(high);
    }

    /// Reset: false = 0 (Reset), true = 1 (Normal)
    pub fn setRst(high: bool) void {
        rst.write(high);
    }

    /// Busy pin: true = busy (1), false = ready (0)
    pub fn readBusy() bool {
        return bsy.read();
    }

    pub fn delayUs(us: u32) void {
        time.SleepUs(us);
    }
};

pub const Epd = epd.Epd2in9bV3(EPDHal);
const canv = fb.Framebuffer(Epd.WIDTH, Epd.HEIGHT);
var buf: [Epd.BUFFER_SIZE]u8 = undefined;

export fn main() callconv(.c) noreturn {

    // Enable GPIOA
    rcc.RCC.IOPENR.GPIOAEN = true;
    rcc.RCC.APBENR2.SPI1EN = true;

    var red = canv.init(&buf);

    // GPIO's init
    rst.init(.{ .mode = .output, .speed = .high });
    dc.init(.{ .mode = .output, .speed = .high });
    bsy.init(.{ .mode = .input, .speed = .high, .pull = .down });
    cs.init(.{ .mode = .output, .speed = .high });
    di.init(.{ .mode = .alternate_function, .speed = .high, .af = .af0 });
    clk.init(.{ .mode = .alternate_function, .speed = .high, .af = .af0 });
    time.init();

    cs.write(true); // CS high
    rst.write(true); // RST high

    // SPI periphery init
    spi.SpiInit(spi.SPI1, .{
        .mode = .master,
        .direction = .full_duplex,
        .baud_rate_div = .div16,
        .cpol = .idle_low,
        .cpha = .first_edge,
        .bit_order = .msb_first,
        .data_size = .bits_8,
        .software_nss = true,
    });

    Epd.init();

    red.clear(.white);
    red.setRotation(.deg270);

    var i: i32 = 0;

    var t: i32 = 3000;

    while (i < 128) : ({
        i += 10;
        t -= 50;
    }) {
        _ = red.drawFixed(0, i, t, 2, 1, .black);
    }

    Epd.sendLayer(.red, &buf);

    @memset(&buf, 0xFF);
    Epd.sendLayer(.black, &buf);
    Epd.refresh();
    Epd.sleep();

    while (true) {}
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = error_return_trace;
    _ = ret_addr;
    _ = msg;

    while (true) {
        @breakpoint(); // Точка останова для отладчика (GDB/LLDB)
    }
}
