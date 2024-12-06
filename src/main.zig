const std = @import("std");

fn line_height() !usize {
    const bindings = @cImport({
        @cInclude("sys/ioctl.h");
    });
    var sz: bindings.winsize = undefined;
    if (bindings.ioctl(0, bindings.TIOCGWINSZ, &sz) != 0) {
        @panic("ioctl failed");
    }

    return sz.ws_ypixel / sz.ws_row;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var arg_iter = try std.process.argsWithAllocator(allocator);
    defer arg_iter.deinit();

    _ = arg_iter.next(); // Skip the program name
    const writer = std.io.getStdOut().writer();
    const height = try line_height();

    var count: u8 = 0;
    while (arg_iter.next()) |arg| {
        count += 1;
        if (count > 1) {
            try writer.print("\n", .{});
        }

        std.debug.assert(arg.len == 6);
        for (arg) |c| {
            std.debug.assert(std.ascii.isHex(c));
        }

        const entry = Entry.new(
            try Entry.Color.from_hex(arg),
            height,
            height,
        );

        const data = try entry.showColor(allocator);
        defer allocator.free(data);
        const color_code = try entry.color.show(allocator);
        defer allocator.free(color_code);

        try writer.print("{s} {s}", .{ data, color_code });
    }

    std.debug.print("\n", .{});
    std.log.debug("alloc={}", .{arena.queryCapacity()});
}

fn escape_fence(alloc: std.mem.Allocator, data: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(alloc, "\x1b_G{s}\x1b\\", .{data});
}

fn control_flags(alloc: std.mem.Allocator, width: usize, height: usize) ![]const u8 {
    return try std.fmt.allocPrint(alloc, "a=T,f=24,s={},v={}", .{ width, height });
}

fn encode_base64(alloc: std.mem.Allocator, data: []const u8) ![]const u8 {
    const encoder = std.base64.Base64Encoder.init(
        std.base64.standard.alphabet_chars,
        std.base64.standard.pad_char,
    );

    const encoded_size = encoder.calcSize(data.len);
    const encoded = try alloc.alloc(u8, encoded_size);
    return encoder.encode(encoded, data);
}

const Entry = struct {
    const Color = struct {
        red: u8,
        green: u8,
        blue: u8,

        fn show(self: Color, alloc: std.mem.Allocator) ![]const u8 {
            return try std.fmt.allocPrint(alloc, "#{x}{x}{x}", .{ self.red, self.green, self.blue });
        }

        fn from_hex(hex: []const u8) !Color {
            std.log.debug("color={s}", .{hex});

            const red = try std.fmt.parseUnsigned(u8, hex[0..2], 16);
            const green = try std.fmt.parseUnsigned(u8, hex[2..4], 16);
            const blue = try std.fmt.parseUnsigned(u8, hex[4..6], 16);

            return Color{ .red = red, .green = green, .blue = blue };
        }

        fn color_matrix(self: Color, alloc: std.mem.Allocator, size: usize) ![]const u8 {
            const data = try alloc.alloc(u8, size * 3);

            std.log.debug("matrix size={d}", .{size});

            var i: usize = 0;
            while (i < size) {
                data[i * 3] = self.red;
                data[i * 3 + 1] = self.green;
                data[i * 3 + 2] = self.blue;
                i += 1;
            }
            return data;
        }
    };
    color: Color,
    width: usize,
    height: usize,

    const Self = @This();

    fn new(color: Color, width: usize, height: usize) Self {
        return Self{ .color = color, .width = width, .height = height };
    }

    fn showColor(self: Self, alloc: std.mem.Allocator) ![]const u8 {
        const color = try self.color.color_matrix(alloc, self.height * self.width * 3);
        defer alloc.free(color);

        const payload = try encode_base64(alloc, color);
        defer alloc.free(payload);

        const flags = try control_flags(alloc, self.width, self.height);
        defer alloc.free(flags);

        return try escape_fence(
            alloc,
            try std.fmt.allocPrint(alloc, "{s};{s}", .{ flags, payload }),
        );
    }
};
