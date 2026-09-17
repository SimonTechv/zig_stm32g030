const std = @import("std");

comptime {
    @export(&vector_table, .{
        .name = "vector_table",
        .section = ".isr_vector",
        .linkage = .strong,
    });
}

fn defaultHandler() callconv(.c) noreturn {
    while (true) {}
}

const resetHandler = @import("startup.zig").resetHandler;

/// The __stack symbol we defined in our linker script for where the stack pointer should
/// start (the very end of RAM). Note is given the type "anyopaque" as this symbol is
/// only ever meant to be used by taking the address with &. It doesn't actually "point"
/// to anything valid at all!
extern var __stack: anyopaque;

/// The actual instance of our vector table we will export into the section
/// ".isr_vector", ensuring it is placed at the beginning of flash memory.
/// Actual interrupt handlers (rather than the defaultHandler) could be added
/// by assigning them in struct instantiation.
const vector_table: VectorTable = .{
    .initial_stack_pointer = &__stack,
};

/// Note that any interrupt function is specified to use the "c" calling convention.
/// This is because Zig's calling convention could differ from C. C being the defacto
/// "standard" for function calling conventions, it's what the processor expects when
/// it branches to one of these functions. Normal functions in application code, however
/// can use normal Zig function definitions. These functions are "special" in the sense
/// that they are being called by "hardware" directly.
const IsrFunction = *const fn () callconv(.c) void;

/// An "extern" struct here is used here to create a
/// struct that has the same memory layout as a C struct.
/// Note that this is NOT the same as "packed", so care must be taken
/// to match the memory layout the CPU is expecting. In this case
/// all fields are ultimately a u32, so silently added padding bytes
/// aren't a concern.
const VectorTable = extern struct {
    initial_stack_pointer: *anyopaque,
    Reset_Handler: IsrFunction = resetHandler,
    NMI_Handler: IsrFunction = defaultHandler,
    HardFault_Handler: IsrFunction = defaultHandler,
    reserved1: [7]u32 = [_]u32{0} ** 7,
    SVC_Handler: IsrFunction = defaultHandler,
    reserved2: [2]u32 = [_]u32{0} ** 2,
    PendSV_Handler: IsrFunction = defaultHandler,
    SysTick_Handler: IsrFunction = defaultHandler,

    WWDG_IRQHandler: IsrFunction = defaultHandler,
    PVD_IRQHandler: IsrFunction = defaultHandler,
    RTC_IRQHandler: IsrFunction = defaultHandler,
    reserved_periph1: u32 = 0,
    RCC_IRQHandler: IsrFunction = defaultHandler,
    EXTI0_1_IRQHandler: IsrFunction = defaultHandler,
    EXTI2_3_IRQHandler: IsrFunction = defaultHandler,
    EXTI4_15_IRQHandler: IsrFunction = defaultHandler,
    reserved_periph2: u32 = 0,
    DMA1_Channel1_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Channel2_3_IRQHandler: IsrFunction = defaultHandler,
    DMA1_Channel4_7_IRQHandler: IsrFunction = defaultHandler,
    ADC_COMP_IRQHandler: IsrFunction = defaultHandler,
    LPTIM1_IRQHandler: IsrFunction = defaultHandler,
    USART4_USART5_IRQHandler: IsrFunction = defaultHandler,
    TIM2_IRQHandler: IsrFunction = defaultHandler,
    TIM3_IRQHandler: IsrFunction = defaultHandler,
    TIM6_IRQHandler: IsrFunction = defaultHandler,
    TIM7_IRQHandler: IsrFunction = defaultHandler,
    reserved_periph3: u32 = 0,
    TIM21_IRQHandler: IsrFunction = defaultHandler,
    I2C3_IRQHandler: IsrFunction = defaultHandler,
    TIM22_IRQHandler: IsrFunction = defaultHandler,
    I2C1_IRQHandler: IsrFunction = defaultHandler,
    I2C2_IRQHandler: IsrFunction = defaultHandler,
    SPI1_IRQHandler: IsrFunction = defaultHandler,
    SPI2_IRQHandler: IsrFunction = defaultHandler,
    USART1_IRQHandler: IsrFunction = defaultHandler,
    USART2_IRQHandler: IsrFunction = defaultHandler,
    AES_RNG_LPUART1_IRQHandler: IsrFunction = defaultHandler,
};
