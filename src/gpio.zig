const std = @import("std");

// =====================================================================
// Per-field register layouts (2 bits per pin, 16 pins => 32-bit register)
// =====================================================================

pub const ModeReg = packed struct(u32) {
    pub const Mode = enum(u2) {
        input,
        output,
        alternate_function,
        analog,
    };

    pin0: Mode = .input,
    pin1: Mode = .input,
    pin2: Mode = .input,
    pin3: Mode = .input,
    pin4: Mode = .input,
    pin5: Mode = .input,
    pin6: Mode = .input,
    pin7: Mode = .input,
    pin8: Mode = .input,
    pin9: Mode = .input,
    pin10: Mode = .input,
    pin11: Mode = .input,
    pin12: Mode = .input,
    pin13: Mode = .input,
    pin14: Mode = .input,
    pin15: Mode = .input,
};

pub const SpeedReg = packed struct(u32) {
    pub const Speed = enum(u2) {
        low,
        medium,
        high,
        very_high,
    };

    pin0: Speed = .low,
    pin1: Speed = .low,
    pin2: Speed = .low,
    pin3: Speed = .low,
    pin4: Speed = .low,
    pin5: Speed = .low,
    pin6: Speed = .low,
    pin7: Speed = .low,
    pin8: Speed = .low,
    pin9: Speed = .low,
    pin10: Speed = .low,
    pin11: Speed = .low,
    pin12: Speed = .low,
    pin13: Speed = .low,
    pin14: Speed = .low,
    pin15: Speed = .low,
};

pub const PullReg = packed struct(u32) {
    pub const Pull = enum(u2) {
        none,
        up,
        down,
        _reserved,
    };

    pin0: Pull = .none,
    pin1: Pull = .none,
    pin2: Pull = .none,
    pin3: Pull = .none,
    pin4: Pull = .none,
    pin5: Pull = .none,
    pin6: Pull = .none,
    pin7: Pull = .none,
    pin8: Pull = .none,
    pin9: Pull = .none,
    pin10: Pull = .none,
    pin11: Pull = .none,
    pin12: Pull = .none,
    pin13: Pull = .none,
    pin14: Pull = .none,
    pin15: Pull = .none,
};

pub const OTypeReg = packed struct(u32) {
    pin0: bool = false,
    pin1: bool = false,
    pin2: bool = false,
    pin3: bool = false,
    pin4: bool = false,
    pin5: bool = false,
    pin6: bool = false,
    pin7: bool = false,
    pin8: bool = false,
    pin9: bool = false,
    pin10: bool = false,
    pin11: bool = false,
    pin12: bool = false,
    pin13: bool = false,
    pin14: bool = false,
    pin15: bool = false,
    _reserved: u16 = 0,
};

/// 4 bits per pin, 8 pins per register (AFR[0] = pins 0-7, AFR[1] = pins 8-15)
pub const AfrReg = packed struct(u32) {
    pub const AF = enum(u4) {
        af0 = 0,
        af1 = 1,
        af2 = 2,
        af3 = 3,
        af4 = 4,
        af5 = 5,
        af6 = 6,
        af7 = 7,
        af8 = 8,
        af9 = 9,
        af10 = 10,
        af11 = 11,
        af12 = 12,
        af13 = 13,
        af14 = 14,
        af15 = 15,
    };

    pin0: AF = .af0,
    pin1: AF = .af0,
    pin2: AF = .af0,
    pin3: AF = .af0,
    pin4: AF = .af0,
    pin5: AF = .af0,
    pin6: AF = .af0,
    pin7: AF = .af0,
};

pub const PinConfig = struct {
    mode: ModeReg.Mode = .input,
    speed: SpeedReg.Speed = .low,
    pull: PullReg.Pull = .none,
    open_drain: bool = false,
    af: AfrReg.AF = .af0,
};

// =====================================================================
// Peripheral
// =====================================================================

const GPIO_TypeDef = extern struct {
    MODER: ModeReg,
    OTYPER: OTypeReg,
    OSPEEDR: SpeedReg,
    PUPDR: PullReg,
    IDR: u32,
    ODR: u32,
    BSRR: u32,
    LCKR: u32,
    AFR: [2]AfrReg,
    BRR: u32,

    pub fn pin(gpio: *volatile GPIO_TypeDef, number: u4) Pin {
        return .{ .port = gpio, .number = number };
    }
};

pub const Pin = struct {
    port: *volatile GPIO_TypeDef,
    number: u4,

    pub fn init(pin: Pin, cfg: PinConfig) void {
        switch (pin.number) {
            inline 0...15 => |i| {
                const field = std.fmt.comptimePrint("pin{d}", .{i});

                // 1. Alternate function must be selected before the pin is
                //    switched into AF mode, to avoid a glitch on the line.
                const afr_index = if (i < 8) 0 else 1;
                const afr_field = std.fmt.comptimePrint("pin{d}", .{if (i < 8) i else i - 8});
                @field(pin.port.AFR[afr_index], afr_field) = cfg.af;

                // 2. Output type, speed and pull, ahead of the mode switch.
                @field(pin.port.OTYPER, field) = cfg.open_drain;
                @field(pin.port.OSPEEDR, field) = cfg.speed;
                @field(pin.port.PUPDR, field) = cfg.pull;

                // 3. Mode last: this is what actually activates the pin
                //    function selected by the fields above.
                @field(pin.port.MODER, field) = cfg.mode;
            },
        }
    }

    /// Atomic pin set/reset via BSRR (no read-modify-write race).
    pub fn write(pin: Pin, value: bool) void {
        const mask: u32 = @as(u32, 1) << pin.number;
        pin.port.BSRR = if (value) mask else (mask << 16);
    }

    pub fn read(pin: Pin) bool {
        return (pin.port.IDR & (@as(u32, 1) << pin.number)) != 0;
    }

    pub fn toggle(pin: Pin) void {
        pin.write(!pin.read());
    }
};

// =====================================================================
// Instances
// =====================================================================

const IOPORT_BASE: usize = 0x50000000;
pub const GPIOA: *volatile GPIO_TypeDef = @ptrFromInt(IOPORT_BASE + 0x0000);
pub const GPIOB: *volatile GPIO_TypeDef = @ptrFromInt(IOPORT_BASE + 0x0400);
pub const GPIOC: *volatile GPIO_TypeDef = @ptrFromInt(IOPORT_BASE + 0x0800);
pub const GPIOD: *volatile GPIO_TypeDef = @ptrFromInt(IOPORT_BASE + 0x0C00);
pub const GPIOF: *volatile GPIO_TypeDef = @ptrFromInt(IOPORT_BASE + 0x1400);
