const uvm = @import("uvm.zig");
const console = @import("console.zig").getWriter();

fn submain() !void {
    try console.print("Hello world\n", .{});
    try console.flush();

    const foo = try uvm.allocator().dupe(u8, "copy me");
    try console.print("dupe={s}\n", .{foo});
    try console.flush();

}

export fn main() void {
    _ = submain() catch {
        uvm.println("Caught err");
    };
}
