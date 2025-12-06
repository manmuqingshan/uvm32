const uvm32 = @cImport({
    @cDefine("USE_MAIN", "1");
    @cInclude("uvm32_target.h");
});
const std = @import("std");

pub inline fn println(val: [:0]const u8) void {
    asm volatile ("csrw " ++ std.fmt.comptimePrint("0x{x}", .{uvm32.IOREQ_PRINTLN}) ++ ", %[arg1]"
        :
        : [arg1] "r" (val.ptr),
    );
}

pub inline fn printd(val: u32) void {
    asm volatile ("csrw " ++ std.fmt.comptimePrint("0x{x}", .{uvm32.IOREQ_PRINTD}) ++ ", %[arg1]"
        :
        : [arg1] "r" (val),
    );
}

pub inline fn printx(val: u32) void {
    asm volatile ("csrw " ++ std.fmt.comptimePrint("0x{x}", .{uvm32.IOREQ_PRINTX}) ++ ", %[arg1]"
        :
        : [arg1] "r" (val),
    );
}

pub inline fn printc(val: u32) void {
    asm volatile ("csrw " ++ std.fmt.comptimePrint("0x{x}", .{uvm32.IOREQ_PRINTC}) ++ ", %[arg1]"
        :
        : [arg1] "r" (val),
    );
}

pub inline fn yield() void {
    asm volatile (std.fmt.comptimePrint("csrwi 0x{x}, 0", .{uvm32.IOREQ_YIELD}));
}

