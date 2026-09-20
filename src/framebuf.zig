// framebuffer.zig - 1bpp framebuffer for e-paper (single layer)

/// 3x5 glyphs, one byte per row, low 3 bits = pixels (bit 2 = left). Order: 0-9 . -
const font = [_][5]u3{
    .{ 0b111, 0b101, 0b101, 0b101, 0b111 }, // 0
    .{ 0b010, 0b110, 0b010, 0b010, 0b111 }, // 1
    .{ 0b111, 0b001, 0b111, 0b100, 0b111 }, // 2
    .{ 0b111, 0b001, 0b111, 0b001, 0b111 }, // 3
    .{ 0b101, 0b101, 0b111, 0b001, 0b001 }, // 4
    .{ 0b111, 0b100, 0b111, 0b001, 0b111 }, // 5
    .{ 0b111, 0b100, 0b111, 0b101, 0b111 }, // 6
    .{ 0b111, 0b001, 0b010, 0b010, 0b010 }, // 7
    .{ 0b111, 0b101, 0b111, 0b101, 0b111 }, // 8
    .{ 0b111, 0b101, 0b111, 0b001, 0b111 }, // 9
    .{ 0b000, 0b000, 0b000, 0b000, 0b010 }, // .
    .{ 0b000, 0b000, 0b111, 0b000, 0b000 }, // -
};

const glyph_advance: i32 = 4; // 3 px + 1 px gap

pub fn Framebuffer(comptime phys_width: u16, comptime phys_height: u16) type {
    return struct {
        const Self = @This();

        pub const width_bytes: usize = (phys_width + 7) / 8;
        pub const buffer_size: usize = width_bytes * phys_height;

        /// Waveshare convention: 1 = white (no ink), 0 = black.
        /// In the red layer, 0 = red.
        pub const Color = enum(u1) {
            black = 0,
            white = 1,
        };

        pub const Rotation = enum {
            deg0,
            deg90,
            deg180,
            deg270,
        };

        pub const Point = struct {
            x: u16,
            y: u16,
        };

        const PixelLocation = struct {
            byte_index: usize,
            mask: u8,
        };

        buf: *[buffer_size]u8,
        rotation: Rotation = .deg0,

        pub fn init(buf: *[buffer_size]u8) Self {
            return .{ .buf = buf };
        }

        /// Logical width, taking rotation into account
        pub fn width(self: Self) u16 {
            return switch (self.rotation) {
                .deg0, .deg180 => phys_width,
                .deg90, .deg270 => phys_height,
            };
        }

        /// Logical height, taking rotation into account
        pub fn height(self: Self) u16 {
            return switch (self.rotation) {
                .deg0, .deg180 => phys_height,
                .deg90, .deg270 => phys_width,
            };
        }

        pub fn setRotation(self: *Self, rotation: Rotation) void {
            self.rotation = rotation;
        }

        pub fn clear(self: *Self, color: Color) void {
            const fill: u8 = if (color == .white) 0xFF else 0x00;
            @memset(self.buf, fill);
        }

        /// Logical coordinates -> physical coordinates. Returns null if off-screen.
        fn map(self: Self, x: i32, y: i32) ?Point {
            if (x < 0 or y < 0) return null;
            if (x >= self.width() or y >= self.height()) return null;

            const ux: u16 = @intCast(x);
            const uy: u16 = @intCast(y);

            const max_x = phys_width - 1;
            const max_y = phys_height - 1;

            return switch (self.rotation) {
                .deg0 => .{ .x = ux, .y = uy },
                .deg90 => .{ .x = max_x - uy, .y = ux },
                .deg180 => .{ .x = max_x - ux, .y = max_y - uy },
                .deg270 => .{ .x = uy, .y = max_y - ux },
            };
        }

        /// Calculates the byte offset and the bitmask (MSB first) for physical coordinates.
        inline fn pixelLocation(p: Point) PixelLocation {
            const shift: u3 = @truncate(p.x);
            return .{
                .byte_index = @as(usize, p.y) * width_bytes + (p.x >> 3),
                .mask = @as(u8, 0x80) >> shift,
            };
        }

        pub fn setPixel(self: *Self, x: i32, y: i32, color: Color) void {
            const p = self.map(x, y) orelse return;
            const loc = pixelLocation(p);

            switch (color) {
                .white => self.buf[loc.byte_index] |= loc.mask,
                .black => self.buf[loc.byte_index] &= ~loc.mask,
            }
        }

        pub fn getPixel(self: Self, x: i32, y: i32) ?Color {
            const p = self.map(x, y) orelse return null;
            const loc = pixelLocation(p);

            return if (self.buf[loc.byte_index] & loc.mask != 0) .white else .black;
        }

        /// Inverts pixel color (useful for UI elements, cursors, selection highlights)
        pub fn invertPixel(self: *Self, x: i32, y: i32) void {
            const p = self.map(x, y) orelse return;
            const loc = pixelLocation(p);
            self.buf[loc.byte_index] ^= loc.mask;
        }

        /// Raw data to pass to the driver
        pub fn data(self: Self) []const u8 {
            return self.buf;
        }

        pub fn dataMut(self: *Self) []u8 {
            return self.buf;
        }

        // Geometry helpers

        /// Bresenham line, endpoints inclusive. Clipping is done by setPixel.
        pub fn drawLine(self: *Self, x0: i32, y0: i32, x1: i32, y1: i32, color: Color) void {
            const dx: i32 = if (x1 > x0) x1 - x0 else x0 - x1;
            const dy: i32 = -(if (y1 > y0) y1 - y0 else y0 - y1);
            const sx: i32 = if (x0 < x1) 1 else -1;
            const sy: i32 = if (y0 < y1) 1 else -1;

            var x = x0;
            var y = y0;
            var err = dx + dy;

            while (true) {
                self.setPixel(x, y, color);
                if (x == x1 and y == y1) break;

                const e2 = 2 * err;
                if (e2 >= dy) {
                    err += dy;
                    x += sx;
                }
                if (e2 <= dx) {
                    err += dx;
                    y += sy;
                }
            }
        }

        /// Horizontal line in logical coords; setPixel handles rotation and clipping.
        pub fn drawHLine(self: *Self, x: i32, y: i32, len: i32, color: Color) void {
            var i: i32 = 0;
            while (i < len) : (i += 1) {
                self.setPixel(x + i, y, color);
            }
        }

        pub fn drawVLine(self: *Self, x: i32, y: i32, len: i32, color: Color) void {
            var i: i32 = 0;
            while (i < len) : (i += 1) self.setPixel(x, y + i, color);
        }

        /// Rect outline, (x, y) = top-left.
        pub fn drawRect(self: *Self, x: i32, y: i32, w: i32, h: i32, color: Color) void {
            if (w <= 0 or h <= 0) return;
            self.drawHLine(x, y, w, color);
            self.drawHLine(x, y + h - 1, w, color);
            self.drawVLine(x, y, h, color);
            self.drawVLine(x + w - 1, y, h, color);
        }

        pub fn fillRect(self: *Self, x: i32, y: i32, w: i32, h: i32, color: Color) void {
            var j: i32 = 0;
            while (j < h) : (j += 1) self.drawHLine(x, y + j, w, color);
        }

        /// Midpoint circle outline.
        pub fn drawCircle(self: *Self, cx: i32, cy: i32, r: i32, color: Color) void {
            if (r < 0) return;
            var x = r;
            var y: i32 = 0;
            var err: i32 = 1 - r;

            while (x >= y) {
                self.setPixel(cx + x, cy + y, color);
                self.setPixel(cx - x, cy + y, color);
                self.setPixel(cx + x, cy - y, color);
                self.setPixel(cx - x, cy - y, color);
                self.setPixel(cx + y, cy + x, color);
                self.setPixel(cx - y, cy + x, color);
                self.setPixel(cx + y, cy - x, color);
                self.setPixel(cx - y, cy - x, color);

                y += 1;
                if (err < 0) {
                    err += 2 * y + 1;
                } else {
                    x -= 1;
                    err += 2 * (y - x) + 1;
                }
            }
        }

        /// Filled circle: same walk, horizontal spans instead of pixels.
        pub fn fillCircle(self: *Self, cx: i32, cy: i32, r: i32, color: Color) void {
            if (r < 0) return;
            var x = r;
            var y: i32 = 0;
            var err: i32 = 1 - r;

            while (x >= y) {
                self.drawHLine(cx - x, cy + y, 2 * x + 1, color);
                self.drawHLine(cx - x, cy - y, 2 * x + 1, color);
                self.drawHLine(cx - y, cy + x, 2 * y + 1, color);
                self.drawHLine(cx - y, cy - x, 2 * y + 1, color);

                y += 1;
                if (err < 0) {
                    err += 2 * y + 1;
                } else {
                    x -= 1;
                    err += 2 * (y - x) + 1;
                }
            }
        }

        /// Triangle outline: just three lines.
        pub fn drawTriangle(self: *Self, x0: i32, y0: i32, x1: i32, y1: i32, x2: i32, y2: i32, color: Color) void {
            self.drawLine(x0, y0, x1, y1, color);
            self.drawLine(x1, y1, x2, y2, color);
            self.drawLine(x2, y2, x0, y0, color);
        }

        // Digits printing

        /// Draws glyph by index; (x, y) = top-left.
        fn drawGlyph(self: *Self, x: i32, y: i32, idx: usize, scale: u8, color: Color) void {
            const s: i32 = scale;
            for (font[idx], 0..) |row_bits, row| {
                for (0..3) |col| {
                    if (row_bits >> @intCast(2 - col) & 1 != 0) {
                        const px = x + @as(i32, @intCast(col)) * s;
                        const py = y + @as(i32, @intCast(row)) * s;
                        self.fillRect(px, py, s, s, color);
                    }
                }
            }
        }

        /// Fixed-point -> glyph indices (0-9, 10 = '.', 11 = '-'), filled from the end of `out`.
        /// value=-1250, decimals=2 -> "-12.50". Needs out.len >= 12, decimals <= 9.
        fn fmtFixed(out: []u8, value: i32, decimals: u8) []u8 {
            var v: u32 = @abs(value);
            var n: usize = out.len;
            var digits: u8 = 0;

            while (true) {
                n -= 1;
                out[n] = @intCast(v % 10);
                v /= 10;
                digits += 1;

                if (digits == decimals) {
                    n -= 1;
                    out[n] = 10; // '.'
                }
                // stop once integer part has at least one digit
                if (v == 0 and digits > decimals) break;
            }

            if (value < 0) {
                n -= 1;
                out[n] = 11; // '-'
            }
            return out[n..];
        }

        /// Draws fixed-point number, returns x after the last glyph.
        pub fn drawFixed(self: *Self, x: i32, y: i32, value: i32, decimals: u8, scale: u8, color: Color) i32 {
            var buf: [12]u8 = undefined; // 10 digits + '.' + '-'
            var cx = x;
            for (fmtFixed(&buf, value, decimals)) |g| {
                self.drawGlyph(cx, y, g, scale, color);
                cx += glyph_advance * @as(i32, scale);
            }
            return cx;
        }
    };
}
