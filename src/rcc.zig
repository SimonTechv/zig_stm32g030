pub const CrReg = packed struct(u32) {
    pub const HsiDiv = enum(u3) {
        div1 = 0b000,
        div2 = 0b001,
        div4 = 0b010,
        div8 = 0b011,
        div16 = 0b100,
        div32 = 0b101,
        div64 = 0b110,
        div128 = 0b111,
    };

    _reserved0: u8 = 0,
    HSION: bool = true,
    HSIKERON: bool = false,
    HSIRDY: bool = true,
    HSIDIV: HsiDiv = .div1,
    _reserved1: u2 = 0,
    HSEON: bool = false,
    HSERDY: bool = false,
    HSEBYP: bool = false,
    CSSON: bool = false,
    _reserved2: u4 = 0,
    PLLON: bool = false,
    PLLRDY: bool = false,
    _reserved3: u6 = 0,
};

pub const IcscrReg = packed struct(u32) {
    HSICAL: u8 = 0,
    HSITRIM: u7 = 0b1000000,
    _reserved: u17 = 0,
};

pub const CfgrReg = packed struct(u32) {
    pub const ClkSw = enum(u3) {
        hsisys = 0,
        hse = 1,
        pllrclk = 2,
        lsi = 3,
        lse = 4,
        _reserved5 = 5,
        _reserved6 = 6,
        _reserved7 = 7,
    };

    pub const McoPre = enum(u4) {
        div1 = 0b0000,
        div2 = 0b0001,
        div4 = 0b0010,
        div8 = 0b0011,
        div16 = 0b0100,
        div32 = 0b0101,
        div64 = 0b0110,
        div128 = 0b0111,
        div256 = 0b1000,
        div512 = 0b1001,
        div1024 = 0b1010,
        _,
    };

    pub const McoSel = enum(u4) {
        disabled = 0b0000,
        sysclk = 0b0001,
        hsi16 = 0b0011,
        hse = 0b0100,
        pll_r_clk = 0b0101,
        lsi = 0b0110,
        lse = 0b0111,
        pll_p_clk = 0b1000,
        pll_q_clk = 0b1001,
        rtc_clk = 0b1010,
        rtc_wakeup = 0b1011,
        _,
    };

    pub const HpreDiv = enum(u4) {
        div1 = 0b0000,
        div2 = 0b1000,
        div4 = 0b1001,
        div8 = 0b1010,
        div16 = 0b1011,
        div64 = 0b1100,
        div128 = 0b1101,
        div256 = 0b1110,
        div512 = 0b1111,
        _,
    };

    pub const PpreDiv = enum(u3) {
        div1 = 0b000,
        div2 = 0b100,
        div4 = 0b101,
        div8 = 0b110,
        div16 = 0b111,
        _,
    };

    SW: ClkSw = .hsisys,
    SWS: ClkSw = .hsisys,
    _reserved0: u2 = 0,
    HPRE: HpreDiv = .div1,
    PPRE: PpreDiv = .div1,
    _reserved1: u1 = 0,
    MCO2SEL: McoSel = .disabled,
    MCO2PRE: McoPre = .div1,
    MCOSEL: McoSel = .disabled,
    MCOPRE: McoPre = .div1,
};

pub const PllcfgrReg = packed struct(u32) {
    pub const PllSource = enum(u2) {
        none = 0b00,
        _reserved = 0b01,
        hsi = 0b10,
        hse = 0b11,
    };
    PLLSRC: PllSource = .none,
    _reserved0: u2 = 0,
    PLLM: u3 = 0,
    _reserved1: u1 = 0,
    PLLN: u7 = 16,
    _reserved2: u1 = 0,
    PLLPEN: bool = false,
    PLLP: u5 = 0,
    _reserved3: u2 = 0,
    PLLQEN: bool = false,
    PLLQ: u3 = 0,
    PLLREN: bool = false,
    PLLR: u3 = 0,
};

pub const CierReg = packed struct(u32) {
    LSIRDYIE: bool = false,
    LSERDYIE: bool = false,
    _reserved0: u1 = 0,
    HSIRDYIE: bool = false,
    HSERDYIE: bool = false,
    PLLRDYIE: bool = false,
    _reserved1: u26 = 0,
};

pub const CifrReg = packed struct(u32) {
    LSIRDYF: bool = false,
    LSERDYF: bool = false,
    _reserved0: u1 = 0,
    HSIRDYF: bool = false,
    HSERDYF: bool = false,
    PLLRDYF: bool = false,
    _reserved1: u2 = 0,
    CSSF: bool = false,
    LSECSSF: bool = false,
    _reserved2: u22 = 0,
};

pub const CicrReg = packed struct(u32) {
    LSIRDYC: bool = false,
    LSERDYYC: bool = false,
    _reserved0: u1 = 0,
    HSIRDYC: bool = false,
    HSERDYC: bool = false,
    PLLRDYC: bool = false,
    _reserved1: u2 = 0,
    CSSC: bool = false,
    LSECSSC: bool = false,
    _reserved2: u22 = 0,
};

pub const IopRstReg = packed struct(u32) {
    GPIOARST: bool = false,
    GPIOBRST: bool = false,
    GPIOCRST: bool = false,
    GPIODRST: bool = false,
    GPIOERST: bool = false,
    GPIOFRST: bool = false,
    _reserved1: u26 = 0,
};

pub const AhbRstReg = packed struct(u32) {
    DMA1RST: bool = false,
    DMA2RST: bool = false,
    _reserved0: u6 = 0,
    FLASHRST: bool = false,
    _reserved1: u3 = 0,
    CRCRST: bool = false,
    _reserved2: u19 = 0,
};

pub const ApbRstr1Reg = packed struct(u32) {
    _reserved0: u1 = 0,
    TIM3RST: bool = false,
    TIM4RST: bool = false,
    _reserved1: u1 = 0,
    TIM6RST: bool = false,
    TIM7RST: bool = false,
    _reserved2: u2 = 0,
    USART5RST: bool = false,
    USART6RST: bool = false,
    _reserved3: u3 = 0,
    USBRST: bool = false,
    SPI2RST: bool = false,
    SPI3RST: bool = false,
    _reserved4: u1 = 0,
    USART2RST: bool = false,
    USART3RST: bool = false,
    USART4RST: bool = false,
    _reserved5: u1 = 0,
    I2C1RST: bool = false,
    I2C2RST: bool = false,
    I2C3RST: bool = false,
    _reserved6: u3 = 0,
    DBGRST: bool = false,
    PWRRST: bool = false,
    _reserved7: u3 = 0,
};

pub const ApbRstr2Reg = packed struct(u32) {
    SYSCFGRST: bool = false,
    _reserved0: u10 = 0,
    TIM1RST: bool = false,
    SPI1RST: bool = false,
    _reserved1: u1 = 0,
    USART1RST: bool = false,
    TIM14RST: bool = false,
    TIM15RST: bool = false,
    TIM16RST: bool = false,
    TIM17RST: bool = false,
    _reserved2: u1 = 0,
    ADCRST: bool = false,
    _reserved3: u11 = 0,
};

pub const IopEnReg = packed struct(u32) {
    GPIOAEN: bool = false,
    GPIOBEN: bool = false,
    GPIOCEN: bool = false,
    GPIODEN: bool = false,
    GPIOEEN: bool = false,
    GPIOFEN: bool = false,
    _reserved: u26 = 0,
};

pub const AhbEnReg = packed struct(u32) {
    DMA1EN: bool = false,
    DMA2EN: bool = false,
    _reserved0: u6 = 0,
    FLASHEN: bool = true,
    _reserved1: u3 = 0,
    CRCEN: bool = false,
    _reserved2: u19 = 0,
};

pub const ApbEnr1Reg = packed struct(u32) {
    _reserved0: u1 = 0,
    TIM3EN: bool = false,
    TIM4EN: bool = false,
    _reserved1: u1 = 0,
    TIM6EN: bool = false,
    TIM7EN: bool = false,
    _reserved2: u2 = 0,
    USART5EN: bool = false,
    USART6EN: bool = false,
    _reserved3: u3 = 0,
    USBEN: bool = false,
    SPI2EN: bool = false,
    SPI3EN: bool = false,
    _reserved4: u1 = 0,
    USART2EN: bool = false,
    USART3EN: bool = false,
    USART4EN: bool = false,
    _reserved5: u1 = 0,
    I2C1EN: bool = false,
    I2C2EN: bool = false,
    I2C3EN: bool = false,
    _reserved6: u3 = 0,
    DBGEN: bool = false,
    PWREN: bool = false,
    _reserved7: u3 = 0,
};

pub const ApbEnr2Reg = packed struct(u32) {
    SYSCFGEN: bool = false,
    _reserved0: u10 = 0,
    TIM1EN: bool = false,
    SPI1EN: bool = false,
    _reserved1: u1 = 0,
    USART1EN: bool = false,
    TIM14EN: bool = false,
    TIM15EN: bool = false,
    TIM16EN: bool = false,
    TIM17EN: bool = false,
    _reserved2: u1 = 0,
    ADCEN: bool = false,
    _reserved3: u11 = 0,
};

pub const IopSmEnReg = packed struct(u32) {
    GPIOASMEN: bool = true,
    GPIOBSMEN: bool = true,
    GPIOCSMEN: bool = true,
    GPIODSMEN: bool = true,
    GPIOESMEN: bool = true,
    GPIOFSMEN: bool = true,
    _reserved: u26 = 0,
};

pub const AhbSmEnReg = packed struct(u32) {
    DMA1SMEN: bool = true,
    DMA2SMEN: bool = true,
    _reserved0: u6 = 0,
    FLASHSMEN: bool = true,
    SRAMSMEN: bool = true,
    _reserved1: u2 = 0,
    CRCSMEN: bool = true,
    _reserved2: u19 = 0,
};

pub const ApbSmEnr1Reg = packed struct(u32) {
    _reserved0: u1 = 0,
    TIM3SMEN: bool = true,
    TIM4SMEN: bool = true,
    _reserved1: u1 = 0,
    TIM6SMEN: bool = true,
    TIM7SMEN: bool = true,
    _reserved2: u2 = 0,
    USART5SMEN: bool = true,
    USART6SMEN: bool = true,
    _reserved3: u3 = 0,
    USBSMEN: bool = true,
    SPI2SMEN: bool = true,
    SPI3SMEN: bool = true,
    _reserved4: u1 = 0,
    USART2SMEN: bool = true,
    USART3SMEN: bool = true,
    USART4SMEN: bool = true,
    _reserved5: u1 = 0,
    I2C1SMEN: bool = true,
    I2C2SMEN: bool = true,
    I2C3SMEN: bool = true,
    _reserved6: u3 = 0,
    DBGSMEN: bool = true,
    PWRSMEN: bool = true,
    _reserved7: u3 = 0,
};

pub const ApbSmEnr2Reg = packed struct(u32) {
    SYSCFGSMEN: bool = true,
    _reserved0: u10 = 0,
    TIM1SMEN: bool = true,
    SPI1SMEN: bool = true,
    _reserved1: u1 = 0,
    USART1SMEN: bool = true,
    TIM14SMEN: bool = true,
    TIM15SMEN: bool = true,
    TIM16SMEN: bool = true,
    TIM17SMEN: bool = true,
    _reserved2: u1 = 0,
    ADCSMEN: bool = true,
    _reserved3: u11 = 0,
};

pub const CciprReg = packed struct(u32) {
    pub const UsartSel = enum(u2) {
        PClk = 0b00,
        SYSClk = 0b01,
        Hsi16 = 0b10,
        Lse = 0b11,
    };

    pub const I2C1Sel = enum(u2) {
        PClk = 0b00,
        SYSClk = 0b01,
        Hsi16 = 0b10,
        _,
    };

    pub const I2C2I2S1Sel = enum(u2) {
        PClk_SYSClk = 0b00,
        SYSClk_PLLPClk = 0b01,
        Hsi16_Hsi16 = 0b10,
        _,
    };

    pub const AdcSel = enum(u2) {
        SysClk = 0b00,
        PllPClk = 0b01,
        Hsi16 = 0b10,
        _,
    };

    USART1SEL: UsartSel = .PClk,
    USART2SEL: UsartSel = .PClk,
    USART3SEL: UsartSel = .PClk,
    _reserved0: u6 = 0,
    I2C1SEL: I2C1Sel = .PClk,
    I2C2I2S1SEL: I2C2I2S1Sel = .PClk_SYSClk,
    _reserved1: u6 = 0,
    TIM1SEL: bool = false,
    _reserved2: u1 = 0,
    TIM15SEL: bool = false,
    _reserved3: u5 = 0,
    ADCSEL: AdcSel = .SysClk,
};

pub const Ccipr2Reg = packed struct(u32) {
    I2S1SEL: u2 = 0,
    I2S2SEL: u2 = 0,
    _reserved0: u8 = 0,
    USBSEL: u2 = 0,
    _reserved1: u18 = 0,
};

pub const BdcrReg = packed struct(u32) {
    LSEON: bool = false,
    LSERDY: bool = false,
    LSEBYP: bool = false,
    LSEDRV: u2 = 0,
    LSECSSON: bool = false,
    LSECSSD: bool = false,
    _reserved0: u1 = 0,
    RTCSEL: u2 = 0,
    _reserved1: u5 = 0,
    RTCEN: bool = false,
    BDRST: bool = false,
    _reserved2: u7 = 0,
    LSCOEN: bool = false,
    LSCOSEL: bool = false,
    _reserved3: u6 = 0,
};

pub const CsrReg = packed struct(u32) {
    LSION: bool = false,
    LSIRDY: bool = false,
    _reserved0: u21 = 0,
    RMVF: bool = false,
    _reserved1: u1 = 0,
    OBLRSTF: bool = false,
    PINRSTF: bool = false,
    PWRRSTF: bool = false,
    SFTRSTF: bool = false,
    IWDGRSTF: bool = false,
    WWDGRSTF: bool = false,
    LPWRRSTF: bool = false,
};

pub const RCC_TypeDef = extern struct {
    CR: CrReg, // 0x00
    ICSCR: IcscrReg, // 0x04
    CFGR: CfgrReg, // 0x08
    PLLCFGR: PllcfgrReg, // 0x0C
    _reserved0: [2]u32, // 0x10 - 0x14
    CIER: CierReg, // 0x18
    CIFR: CifrReg, // 0x1C
    CICR: CicrReg, // 0x20
    IOPRSTR: IopRstReg, // 0x24
    AHBRSTR: AhbRstReg, // 0x28
    APBRSTR1: ApbRstr1Reg, // 0x2C
    APBRSTR2: ApbRstr2Reg, // 0x30
    IOPENR: IopEnReg, // 0x34
    AHBENR: AhbEnReg, // 0x38
    APBENR1: ApbEnr1Reg, // 0x3C
    APBENR2: ApbEnr2Reg, // 0x40
    IOPSMENR: IopSmEnReg, // 0x44
    AHBSMENR: AhbSmEnReg, // 0x48
    APBSMENR1: ApbSmEnr1Reg, // 0x4C
    APBSMENR2: ApbSmEnr2Reg, // 0x50
    CCIPR: CciprReg, // 0x54
    CCIPR2: Ccipr2Reg, // 0x58
    BDCR: BdcrReg, // 0x5C
    CSR: CsrReg, // 0x60
};

const AHBPERIPH_BASE: usize = 0x40020000;
const RCC_BASE: usize = AHBPERIPH_BASE + 0x00001000;
pub const RCC: *volatile RCC_TypeDef = @ptrFromInt(RCC_BASE);
