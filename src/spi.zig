pub const Cr1Reg = packed struct(u32) {
    pub const BaudRate = enum(u3) {
        div2 = 0b000,
        div4 = 0b001,
        div8 = 0b010,
        div16 = 0b011,
        div32 = 0b100,
        div64 = 0b101,
        div128 = 0b110,
        div256 = 0b111,
    };

    CPHA: bool = false,
    CPOL: bool = false,
    MSTR: bool = false,
    BR: BaudRate = .div2,
    SPE: bool = false,
    LSBFIRST: bool = false,
    SSI: bool = false,
    SSM: bool = false,
    RXONLY: bool = false,
    CRCL: bool = false,
    CRCNEXT: bool = false,
    CRCEN: bool = false,
    BIDIOE: bool = false,
    BIDIMODE: bool = false,
    _reserved0: u16 = 0,
};

pub const Cr2Reg = packed struct(u32) {
    pub const DataSize = enum(u4) {
        bits_4 = 0b0011,
        bits_5 = 0b0100,
        bits_6 = 0b0101,
        bits_7 = 0b0110,
        bits_8 = 0b0111,
        bits_9 = 0b1000,
        bits_10 = 0b1001,
        bits_11 = 0b1010,
        bits_12 = 0b1011,
        bits_13 = 0b1100,
        bits_14 = 0b1101,
        bits_15 = 0b1110,
        bits_16 = 0b1111,
        _,
    };

    RXDMAEN: bool = false,
    TXDMAEN: bool = false,
    SSOE: bool = false,
    NSSP: bool = false,
    FRF: bool = false,
    ERRIE: bool = false,
    RXNEIE: bool = false,
    TXEIE: bool = false,
    DS: DataSize = .bits_8,
    FRXTH: bool = false,
    LDMA_RX: bool = false,
    LDMA_TX: bool = false,
    _reserved0: u1 = 0,
    _reserved1: u16 = 0,
};

pub const SrReg = packed struct(u32) {
    pub const FifoLevel = enum(u2) {
        empty = 0b00,
        quarter = 0b01,
        half = 0b10,
        full = 0b11,
    };

    RXNE: bool = false,
    TXE: bool = true,
    CHSIDE: bool = false,
    UDR: bool = false,
    CRCERR: bool = false,
    MODF: bool = false,
    OVR: bool = false,
    BSY: bool = false,
    FRE: bool = false,
    FRLVL: FifoLevel = .empty,
    FTLVL: FifoLevel = .empty,
    _reserved0: u3 = 0,
    _reserved1: u16 = 0,
};

pub const DrReg = packed struct(u32) {
    DR: u16 = 0,
    _reserved0: u16 = 0,
};

pub const CrcprReg = packed struct(u32) {
    CRCPOLY: u16 = 0x0007,
    _reserved0: u16 = 0,
};

pub const RxcrcrReg = packed struct(u32) {
    RXCRC: u16 = 0,
    _reserved0: u16 = 0,
};

pub const TxcrcrReg = packed struct(u32) {
    TXCRC: u16 = 0,
    _reserved0: u16 = 0,
};

pub const I2scfgrReg = packed struct(u32) {
    pub const DataLength = enum(u2) {
        bits_16 = 0b00,
        bits_24 = 0b01,
        bits_32 = 0b10,
        _,
    };

    pub const Standard = enum(u2) {
        philips = 0b00,
        msb_justified = 0b01,
        lsb_justified = 0b10,
        pcm = 0b11,
    };

    pub const Configuration = enum(u2) {
        slave_transmit = 0b00,
        slave_receive = 0b01,
        master_transmit = 0b10,
        master_receive = 0b11,
    };

    CHLEN: bool = false,
    DATLEN: DataLength = .bits_16,
    CKPOL: bool = false,
    I2SSTD: Standard = .philips,
    _reserved0: u1 = 0,
    PCMSYNC: bool = false,
    I2SCFG: Configuration = .slave_transmit,
    I2SE: bool = false,
    I2SMOD: bool = false,
    ASTRTEN: bool = false,
    _reserved1: u3 = 0,
    _reserved2: u16 = 0,
};

pub const I2sprReg = packed struct(u32) {
    I2SDIV: u8 = 2,
    ODD: bool = false,
    MCKOE: bool = false,
    _reserved0: u6 = 0,
    _reserved1: u16 = 0,
};

pub const SPI_TypeDef = extern struct {
    CR1: Cr1Reg,
    CR2: Cr2Reg,
    SR: SrReg,
    DR: DrReg,
    CRCPR: CrcprReg,
    RXCRCR: RxcrcrReg,
    TXCRCR: TxcrcrReg,
    I2SCFGR: I2scfgrReg,
    I2SPR: I2sprReg,
};

pub const SPI1_BASE: usize = 0x40013000;
pub const SPI1: *volatile SPI_TypeDef = @ptrFromInt(SPI1_BASE);

/// Helper API section
pub const Error = error{
    Timeout,
    ModeFault,
    Overrun,
    CrcError,
};

pub const Mode = enum {
    master,
    slave,
};

pub const Direction = enum {
    full_duplex,
    receive_only,
    half_duplex_rx,
    half_duplex_tx,
};

pub const ClockPolarity = enum {
    idle_low,
    idle_high,
};

pub const ClockPhase = enum {
    first_edge,
    second_edge,
};

pub const BitOrder = enum {
    msb_first,
    lsb_first,
};

pub const config = struct {
    mode: Mode = .master,
    direction: Direction = .full_duplex,
    baud_rate_div: Cr1Reg.BaudRate = .div16,
    cpol: ClockPolarity = .idle_low,
    cpha: ClockPhase = .first_edge,
    bit_order: BitOrder = .msb_first,
    data_size: Cr2Reg.DataSize = .bits_8,
    software_nss: bool = true,
};

pub fn SpiInit(spi: *volatile SPI_TypeDef, cfg: config) void {
    // 1. Disable peripheral before configuration
    spi.CR1.SPE = false;

    // 2. Configure CR2: data size, RX FIFO threshold (FRXTH), and hardware NSS output
    spi.CR2 = .{
        .DS = cfg.data_size,
        .FRXTH = switch (cfg.data_size) {
            .bits_4, .bits_5, .bits_6, .bits_7, .bits_8 => true,
            else => false,
        },
        .SSOE = (!cfg.software_nss and cfg.mode == .master),
    };

    // 3. Configure CR1: mode, clock, frame format, bus direction, SSM, and enable
    spi.CR1 = .{
        .MSTR = (cfg.mode == .master),
        .BR = cfg.baud_rate_div,
        .CPOL = (cfg.cpol == .idle_high),
        .CPHA = (cfg.cpha == .second_edge),
        .LSBFIRST = (cfg.bit_order == .lsb_first),

        // Bus direction configuration
        .RXONLY = (cfg.direction == .receive_only),
        .BIDIMODE = (cfg.direction == .half_duplex_rx or cfg.direction == .half_duplex_tx),
        .BIDIOE = (cfg.direction == .half_duplex_tx),

        // Software slave management (prevents MODF in master mode)
        .SSM = cfg.software_nss,
        .SSI = (cfg.software_nss and cfg.mode == .master),

        // Enable SPI
        .SPE = true,
    };
}
