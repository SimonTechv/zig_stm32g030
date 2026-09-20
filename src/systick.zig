pub const CsrReg = packed struct(u32) {
    pub const ClockSource = enum(u1) {
        external = 0, // HCLK / 8
        processor = 1, // Processor clock (HCLK)
    };

    ENABLE: bool = false,
    TICKINT: bool = false,
    CLKSOURCE: ClockSource = .processor,
    _reserved0: u13 = 0,
    COUNTFLAG: bool = false,
    _reserved1: u15 = 0,
};

pub const RvrReg = packed struct(u32) {
    RELOAD: u24 = 0,
    _reserved0: u8 = 0,
};

pub const CvrReg = packed struct(u32) {
    CURRENT: u24 = 0,
    _reserved0: u8 = 0,
};

pub const CalibReg = packed struct(u32) {
    TENMS: u24 = 0,
    _reserved0: u6 = 0,
    SKEW: bool = false,
    NOREF: bool = false,
};

pub const SysTick_TypeDef = extern struct {
    CSR: CsrReg,
    RVR: RvrReg,
    CVR: CvrReg,
    CALIB: CalibReg,
};

pub const SYSTICK_BASE: usize = 0xE000_E010;
pub const SYSTICK: *volatile SysTick_TypeDef = @ptrFromInt(SYSTICK_BASE);

pub fn Time(comptime sys_clk_hz: u32) type {
    return struct {
        const ticks_per_us: u32 = sys_clk_hz / 1_000_000;
        const ticks_per_ms: u32 = sys_clk_hz / 1_000;

        pub fn init() void {
            SYSTICK.RVR = .{ .RELOAD = 0x00FF_FFFF };
            SYSTICK.CVR = .{ .CURRENT = 0 };
            SYSTICK.CSR = .{
                .ENABLE = true,
                .TICKINT = false,
                .CLKSOURCE = .processor,
            };
        }

        pub fn SleepUs(us: u32) void {
            SleepTicks(us * ticks_per_us);
        }

        pub fn SleepMs(ms: u32) void {
            SleepTicks(ms * ticks_per_ms);
        }

        pub fn SleepTicks(ticks: u32) void {
            var remaining: u32 = ticks;
            var last: u24 = SYSTICK.CVR.CURRENT;

            while (remaining != 0) {
                const cur: u24 = SYSTICK.CVR.CURRENT;
                const delta: u24 = last -% cur;
                last = cur;
                remaining -|= delta;
            }
        }
    };
}
