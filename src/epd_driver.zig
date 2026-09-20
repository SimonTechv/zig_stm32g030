// EPD_2in9b_V3.zig - Waveshare 2.9inch e-Paper (B) V3 Driver

pub fn Epd2in9bV3(comptime Hal: type) type {
    return struct {
        pub const WIDTH: u16 = 128;
        pub const HEIGHT: u16 = 296;
        pub const WIDTH_BYTES: u16 = (WIDTH + 7) / 8;
        pub const BUFFER_SIZE: usize = @as(usize, WIDTH_BYTES) * HEIGHT;

        pub const Command = enum(u8) {
            panel_setting = 0x00,
            power_off = 0x02,
            power_on = 0x04,
            deep_sleep = 0x07,
            data_start_black = 0x10,
            display_refresh = 0x12,
            data_start_red = 0x13,
            vcom_and_data_interval = 0x50,
            resolution_setting = 0x61,
            get_status = 0x71,
            data_stop = 0x92,
        };

        pub const Layer = enum {
            black,
            red,
        };

        fn delayMs(ms: u32) void {
            Hal.delayUs(ms * 1000);
        }

        fn sendCommand(cmd: Command) void {
            Hal.setDc(false);
            Hal.setCs(false);
            Hal.spiWrite(&[_]u8{@intFromEnum(cmd)});
            Hal.setCs(true);
        }

        fn sendData(data: u8) void {
            Hal.setDc(true);
            Hal.setCs(false);
            Hal.spiWrite(&[_]u8{data});
            Hal.setCs(true);
        }

        fn sendDataSlice(data: []const u8) void {
            Hal.setDc(true);
            Hal.setCs(false);
            Hal.spiWrite(data);
            Hal.setCs(true);
        }

        pub fn reset() void {
            Hal.setRst(true);
            delayMs(200);
            Hal.setRst(false);
            delayMs(5);
            Hal.setRst(true);
            delayMs(200);
        }

        pub fn readBusy() void {
            while (true) {
                sendCommand(.get_status);
                if (Hal.readBusy()) break;
                delayMs(10);
            }
            delayMs(200);
        }

        pub fn init() void {
            reset();

            sendCommand(.power_on);
            readBusy();

            sendCommand(.panel_setting);
            sendData(0x0F);
            sendData(0x89);

            sendCommand(.resolution_setting);
            sendData(0x80);
            sendData(0x01);
            sendData(0x28);

            sendCommand(.vcom_and_data_interval);
            sendData(0x77);
        }

        pub fn clear() void {
            sendCommand(.data_start_black);
            for (0..BUFFER_SIZE) |_| {
                sendData(0xFF);
            }

            sendCommand(.data_start_red);
            for (0..BUFFER_SIZE) |_| {
                sendData(0xFF);
            }

            sendCommand(.display_refresh);
            readBusy();
        }

        pub fn sendLayer(layer: Layer, data: []const u8) void {
            const cmd: Command = switch (layer) {
                .black => .data_start_black,
                .red => .data_start_red,
            };
            sendCommand(cmd);
            sendDataSlice(data);
            sendCommand(.data_stop);
        }

        pub fn refresh() void {
            sendCommand(.display_refresh);
            readBusy();
        }

        pub fn sleep() void {
            sendCommand(.power_off);
            readBusy();
            sendCommand(.deep_sleep);
            sendData(0xA5);
        }
    };
}
