const uvm = @import("uvm.zig");
const zeptolibc = @import("zeptolibc");
const std = @import("std");

const console = @import("console.zig").getWriter();
const tgl = @cImport({
    @cInclude("GL/gl.h");
    @cInclude("zgl.h");
});
const sdlkeys = @cImport({
    @cInclude("SDL_scancode.h");
});

const WIDTH = 320;
const HEIGHT = 200;

var leftPressed: bool = false;
var rightPressed: bool = false;
var upPressed: bool = false;
var downPressed: bool = false;

fn checkKeys() void {
    var pressed:bool = undefined;
    var scancode:u16 = undefined;
    if (uvm.getkey(&scancode, &pressed)) {
        if (pressed) {
            switch(scancode) {
                sdlkeys.SDL_SCANCODE_RIGHT => rightPressed = true,
                sdlkeys.SDL_SCANCODE_LEFT => leftPressed = true,
                sdlkeys.SDL_SCANCODE_UP => upPressed = true,
                sdlkeys.SDL_SCANCODE_DOWN => downPressed = true,
                else => {},
            }
        } else {
            switch(scancode) {
                sdlkeys.SDL_SCANCODE_RIGHT => rightPressed = false,
                sdlkeys.SDL_SCANCODE_LEFT => leftPressed = false,
                sdlkeys.SDL_SCANCODE_UP => upPressed = false,
                sdlkeys.SDL_SCANCODE_DOWN => downPressed = false,
                else => {},
            }
        }
    }
}

var view_rotx: tgl.GLfloat = 20.0;
var view_roty: tgl.GLfloat = 30.0;
var view_rotz: tgl.GLfloat = 0.0;
var gear1: tgl.GLuint = undefined;
var gear2: tgl.GLuint = undefined;
var gear3: tgl.GLuint = undefined;
var angle: tgl.GLfloat = 0.0;
var pos: [4]tgl.GLfloat = .{ 5.0, 5.0, 10.0, 0.0 };
var red: [4]tgl.GLfloat = .{ 0.8, 0.1, 0.0, 1.0 };
var green: [4]tgl.GLfloat = .{ 0.0, 0.8, 0.2, 1.0 };
var blue: [4]tgl.GLfloat = .{ 0.2, 0.2, 1.0, 1.0 };

var gfxFramebuffer: [WIDTH * HEIGHT]u32 = undefined;

fn gear(inner_radius: tgl.GLfloat, outer_radius: tgl.GLfloat, width: tgl.GLfloat, teeth: tgl.GLint, tooth_depth: tgl.GLfloat) void {
    var i: tgl.GLint = undefined;
    var r0: tgl.GLfloat = undefined;
    var r1: tgl.GLfloat = undefined;
    var r2: tgl.GLfloat = undefined;
    var ang: tgl.GLfloat = undefined;
    var da: tgl.GLfloat = undefined;
    var u: tgl.GLfloat = undefined;
    var v: tgl.GLfloat = undefined;
    var len: tgl.GLfloat = undefined;

    r0 = inner_radius;
    r1 = outer_radius - tooth_depth / 2.0;
    r2 = outer_radius + tooth_depth / 2.0;

    da = 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth)) / 4.0;

    tgl.glShadeModel(tgl.GL_FLAT);

    tgl.glNormal3f(0.0, 0.0, 1.0);

    // draw front face
    tgl.glBegin(tgl.GL_QUAD_STRIP);

    i = 0;
    while (i <= teeth) : (i += 1) {
        ang = @as(tgl.GLfloat, @floatFromInt(i)) * 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth));
        tgl.glVertex3f(r0 * @cos(ang), r0 * @sin(ang), width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang), r1 * @sin(ang), width * 0.5);
        tgl.glVertex3f(r0 * @cos(ang), r0 * @sin(ang), width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang + 3 * da), r1 * @sin(ang + 3 * da), width * 0.5);
    }
    tgl.glEnd();

    // draw front sides of teeth
    tgl.glBegin(tgl.GL_QUADS);
    da = 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth)) / 4.0;
    i = 0;
    while (i < teeth) : (i += 1) {
        ang = @as(tgl.GLfloat, @floatFromInt(i)) * 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth));

        tgl.glVertex3f(r1 * @cos(ang), r1 * @sin(ang), width * 0.5);
        tgl.glVertex3f(r2 * @cos(ang + da), r2 * @sin(ang + da), width * 0.5);
        tgl.glVertex3f(r2 * @cos(ang + 2 * da), r2 * @sin(ang + 2 * da), width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang + 3 * da), r1 * @sin(ang + 3 * da), width * 0.5);
    }
    tgl.glEnd();

    tgl.glNormal3f(0.0, 0.0, -1.0);

    // draw back face
    tgl.glBegin(tgl.GL_QUAD_STRIP);
    i = 0;
    while (i <= teeth) : (i += 1) {
        ang = @as(tgl.GLfloat, @floatFromInt(i)) * 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth));
        tgl.glVertex3f(r1 * @cos(ang), r1 * @sin(ang), -width * 0.5);
        tgl.glVertex3f(r0 * @cos(ang), r0 * @sin(ang), -width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang + 3 * da), r1 * @sin(ang + 3 * da), -width * 0.5);
        tgl.glVertex3f(r0 * @cos(ang), r0 * @sin(ang), -width * 0.5);
    }
    tgl.glEnd();

    // draw back sides of teeth
    tgl.glBegin(tgl.GL_QUADS);
    da = 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth)) / 4.0;
    i = 0;
    while (i < teeth) : (i += 1) {
        ang = @as(tgl.GLfloat, @floatFromInt(i)) * 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth));

        tgl.glVertex3f(r1 * @cos(ang + 3 * da), r1 * @sin(ang + 3 * da), -width * 0.5);
        tgl.glVertex3f(r2 * @cos(ang + 2 * da), r2 * @sin(ang + 2 * da), -width * 0.5);
        tgl.glVertex3f(r2 * @cos(ang + da), r2 * @sin(ang + da), -width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang), r1 * @sin(ang), -width * 0.5);
    }
    tgl.glEnd();

    // draw outward faces of teeth
    tgl.glBegin(tgl.GL_QUAD_STRIP);
    i = 0;
    while (i <= teeth) : (i += 1) {
        ang = @as(tgl.GLfloat, @floatFromInt(i)) * 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth));

        tgl.glVertex3f(r1 * @cos(ang), r1 * @sin(ang), width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang), r1 * @sin(ang), -width * 0.5);
        u = r2 * @cos(ang + da) - r1 * @cos(ang);
        v = r2 * @sin(ang + da) - r1 * @sin(ang);
        len = std.math.sqrt(u * u + v * v);
        u /= len;
        v /= len;
        tgl.glNormal3f(v, -u, 0.0);
        tgl.glVertex3f(r2 * @cos(ang + da), r2 * @sin(ang + da), width * 0.5);
        tgl.glVertex3f(r2 * @cos(ang + da), r2 * @sin(ang + da), -width * 0.5);
        tgl.glNormal3f(@cos(ang), @sin(ang), 0.0);
        tgl.glVertex3f(r2 * @cos(ang + 2 * da), r2 * @sin(ang + 2 * da), width * 0.5);
        tgl.glVertex3f(r2 * @cos(ang + 2 * da), r2 * @sin(ang + 2 * da), -width * 0.5);
        u = r1 * @cos(ang + 3 * da) - r2 * @cos(ang + 2 * da);
        v = r1 * @sin(ang + 3 * da) - r2 * @sin(ang + 2 * da);
        tgl.glNormal3f(v, -u, 0.0);
        tgl.glVertex3f(r1 * @cos(ang + 3 * da), r1 * @sin(ang + 3 * da), width * 0.5);
        tgl.glVertex3f(r1 * @cos(ang + 3 * da), r1 * @sin(ang + 3 * da), -width * 0.5);
        tgl.glNormal3f(@cos(ang), @sin(ang), 0.0);
    }

    tgl.glVertex3f(r1 * @cos(0.0), r1 * @sin(0.0), width * 0.5);
    tgl.glVertex3f(r1 * @cos(0.0), r1 * @sin(0.0), -width * 0.5);

    tgl.glEnd();

    tgl.glShadeModel(tgl.GL_SMOOTH);

    // draw inside radius cylinder
    tgl.glBegin(tgl.GL_QUAD_STRIP);
    i = 0;
    while (i <= teeth) : (i += 1) {
        ang = @as(tgl.GLfloat, @floatFromInt(i)) * 2.0 * std.math.pi / @as(tgl.GLfloat, @floatFromInt(teeth));
        tgl.glNormal3f(-@cos(ang), -@sin(ang), 0.0);
        tgl.glVertex3f(r0 * @cos(ang), r0 * @sin(ang), -width * 0.5);
        tgl.glVertex3f(r0 * @cos(ang), r0 * @sin(ang), width * 0.5);
    }
    tgl.glEnd();
}

fn make_object() tgl.GLuint {
    var list: tgl.GLuint = undefined;

    list = tgl.glGenLists(1);

    tgl.glNewList(list, tgl.GL_COMPILE);

    tgl.glBegin(tgl.GL_LINE_LOOP);
    tgl.glColor3f(1.0, 1.0, 1.0);
    tgl.glVertex3f(1.0, 0.5, -0.4);
    tgl.glColor3f(1.0, 0.0, 0.0);
    tgl.glVertex3f(1.0, -0.5, -0.4);
    tgl.glColor3f(0.0, 1.0, 0.0);
    tgl.glVertex3f(-1.0, -0.5, -0.4);
    tgl.glColor3f(0.0, 0.0, 1.0);
    tgl.glVertex3f(-1.0, 0.5, -0.4);
    tgl.glEnd();

    tgl.glColor3f(1.0, 1.0, 1.0);

    tgl.glBegin(tgl.GL_LINE_LOOP);
    tgl.glVertex3f(1.0, 0.5, 0.4);
    tgl.glVertex3f(1.0, -0.5, 0.4);
    tgl.glVertex3f(-1.0, -0.5, 0.4);
    tgl.glVertex3f(-1.0, 0.5, 0.4);
    tgl.glEnd();

    tgl.glBegin(tgl.GL_LINES);
    tgl.glVertex3f(1.0, 0.5, -0.4);
    tgl.glVertex3f(1.0, 0.5, 0.4);
    tgl.glVertex3f(1.0, -0.5, -0.4);
    tgl.glVertex3f(1.0, -0.5, 0.4);
    tgl.glVertex3f(-1.0, -0.5, -0.4);
    tgl.glVertex3f(-1.0, -0.5, 0.4);
    tgl.glVertex3f(-1.0, 0.5, -0.4);
    tgl.glVertex3f(-1.0, 0.5, 0.4);
    tgl.glEnd();

    tgl.glEndList();

    return list;
}

fn reshape(width: c_int, height: c_int) void {
    const h: tgl.GLfloat = @as(tgl.GLfloat, @floatFromInt(height)) / @as(tgl.GLfloat, @floatFromInt(width));

    tgl.glViewport(0, 0, @intCast(width), @intCast(height));
    tgl.glMatrixMode(tgl.GL_PROJECTION);
    tgl.glLoadIdentity();
    tgl.glFrustum(-1.0, 1.0, -h, h, 5.0, 60.0);
    tgl.glMatrixMode(tgl.GL_MODELVIEW);
    tgl.glLoadIdentity();
    tgl.glTranslatef(0.0, 0.0, -40.0);
    tgl.glClear(tgl.GL_COLOR_BUFFER_BIT | tgl.GL_DEPTH_BUFFER_BIT);
}

fn consoleWriteFn(data:[]const u8) void {
    _ = console.print("{s}", .{data}) catch 0;
    _ = console.flush() catch 0;
}


//fn scancode_to_doom_key(scancode:u16) pd.doom_key_t {
//    return switch(scancode) {
//        sdlkeys.SDL_SCANCODE_TAB => pd.DOOM_KEY_TAB,
//        sdlkeys.SDL_SCANCODE_RETURN => pd.DOOM_KEY_ENTER,
//        sdlkeys.SDL_SCANCODE_ESCAPE => pd.DOOM_KEY_ESCAPE,
//        sdlkeys.SDL_SCANCODE_SPACE => pd.DOOM_KEY_SPACE,
//        sdlkeys.SDL_SCANCODE_APOSTROPHE => pd.DOOM_KEY_APOSTROPHE,
//        sdlkeys.SDL_SCANCODE_KP_MULTIPLY => pd.DOOM_KEY_MULTIPLY,
//        sdlkeys.SDL_SCANCODE_COMMA => pd.DOOM_KEY_COMMA,
//        sdlkeys.SDL_SCANCODE_MINUS => pd.DOOM_KEY_MINUS,
//        sdlkeys.SDL_SCANCODE_PERIOD => pd.DOOM_KEY_PERIOD,
//        sdlkeys.SDL_SCANCODE_SLASH => pd.DOOM_KEY_SLASH,
//        sdlkeys.SDL_SCANCODE_0 => pd.DOOM_KEY_0,
//        sdlkeys.SDL_SCANCODE_1 => pd.DOOM_KEY_1,
//        sdlkeys.SDL_SCANCODE_2 => pd.DOOM_KEY_2,
//        sdlkeys.SDL_SCANCODE_3 => pd.DOOM_KEY_3,
//        sdlkeys.SDL_SCANCODE_4 => pd.DOOM_KEY_4,
//        sdlkeys.SDL_SCANCODE_5 => pd.DOOM_KEY_5,
//        sdlkeys.SDL_SCANCODE_6 => pd.DOOM_KEY_6,
//        sdlkeys.SDL_SCANCODE_7 => pd.DOOM_KEY_7,
//        sdlkeys.SDL_SCANCODE_8 => pd.DOOM_KEY_8,
//        sdlkeys.SDL_SCANCODE_9 => pd.DOOM_KEY_9,
//        sdlkeys.SDL_SCANCODE_SEMICOLON => pd.DOOM_KEY_SEMICOLON,
//        sdlkeys.SDL_SCANCODE_EQUALS => pd.DOOM_KEY_EQUALS,
//        sdlkeys.SDL_SCANCODE_LEFTBRACKET => pd.DOOM_KEY_LEFT_BRACKET,
//        sdlkeys.SDL_SCANCODE_RIGHTBRACKET => pd.DOOM_KEY_RIGHT_BRACKET,
//        sdlkeys.SDL_SCANCODE_A => pd.DOOM_KEY_A,
//        sdlkeys.SDL_SCANCODE_B => pd.DOOM_KEY_B,
//        sdlkeys.SDL_SCANCODE_C => pd.DOOM_KEY_C,
//        sdlkeys.SDL_SCANCODE_D => pd.DOOM_KEY_D,
//        sdlkeys.SDL_SCANCODE_E => pd.DOOM_KEY_E,
//        sdlkeys.SDL_SCANCODE_F => pd.DOOM_KEY_F,
//        sdlkeys.SDL_SCANCODE_G => pd.DOOM_KEY_G,
//        sdlkeys.SDL_SCANCODE_H => pd.DOOM_KEY_H,
//        sdlkeys.SDL_SCANCODE_I => pd.DOOM_KEY_I,
//        sdlkeys.SDL_SCANCODE_J => pd.DOOM_KEY_J,
//        sdlkeys.SDL_SCANCODE_K => pd.DOOM_KEY_K,
//        sdlkeys.SDL_SCANCODE_L => pd.DOOM_KEY_L,
//        sdlkeys.SDL_SCANCODE_M => pd.DOOM_KEY_M,
//        sdlkeys.SDL_SCANCODE_N => pd.DOOM_KEY_N,
//        sdlkeys.SDL_SCANCODE_O => pd.DOOM_KEY_O,
//        sdlkeys.SDL_SCANCODE_P => pd.DOOM_KEY_P,
//        sdlkeys.SDL_SCANCODE_Q => pd.DOOM_KEY_Q,
//        sdlkeys.SDL_SCANCODE_R => pd.DOOM_KEY_R,
//        sdlkeys.SDL_SCANCODE_S => pd.DOOM_KEY_S,
//        sdlkeys.SDL_SCANCODE_T => pd.DOOM_KEY_T,
//        sdlkeys.SDL_SCANCODE_U => pd.DOOM_KEY_U,
//        sdlkeys.SDL_SCANCODE_V => pd.DOOM_KEY_V,
//        sdlkeys.SDL_SCANCODE_W => pd.DOOM_KEY_W,
//        sdlkeys.SDL_SCANCODE_X => pd.DOOM_KEY_X,
//        sdlkeys.SDL_SCANCODE_Y => pd.DOOM_KEY_Y,
//        sdlkeys.SDL_SCANCODE_Z => pd.DOOM_KEY_Z,
//        sdlkeys.SDL_SCANCODE_BACKSPACE => pd.DOOM_KEY_BACKSPACE,
//        sdlkeys.SDL_SCANCODE_LCTRL => pd.DOOM_KEY_CTRL,
//        sdlkeys.SDL_SCANCODE_RCTRL => pd.DOOM_KEY_CTRL,
//        sdlkeys.SDL_SCANCODE_LEFT => pd.DOOM_KEY_LEFT_ARROW,
//        sdlkeys.SDL_SCANCODE_UP => pd.DOOM_KEY_UP_ARROW,
//        sdlkeys.SDL_SCANCODE_RIGHT => pd.DOOM_KEY_RIGHT_ARROW,
//        sdlkeys.SDL_SCANCODE_DOWN => pd.DOOM_KEY_DOWN_ARROW,
//        sdlkeys.SDL_SCANCODE_RSHIFT => pd.DOOM_KEY_SHIFT,
//        sdlkeys.SDL_SCANCODE_LSHIFT => pd.DOOM_KEY_SHIFT,
//        sdlkeys.SDL_SCANCODE_LALT => pd.DOOM_KEY_ALT,
//        sdlkeys.SDL_SCANCODE_RALT => pd.DOOM_KEY_ALT,
//        sdlkeys.SDL_SCANCODE_F1 => pd.DOOM_KEY_F1,
//        sdlkeys.SDL_SCANCODE_F2 => pd.DOOM_KEY_F2,
//        sdlkeys.SDL_SCANCODE_F3 => pd.DOOM_KEY_F3,
//        sdlkeys.SDL_SCANCODE_F4 => pd.DOOM_KEY_F4,
//        sdlkeys.SDL_SCANCODE_F5 => pd.DOOM_KEY_F5,
//        sdlkeys.SDL_SCANCODE_F6 => pd.DOOM_KEY_F6,
//        sdlkeys.SDL_SCANCODE_F7 => pd.DOOM_KEY_F7,
//        sdlkeys.SDL_SCANCODE_F8 => pd.DOOM_KEY_F8,
//        sdlkeys.SDL_SCANCODE_F9 => pd.DOOM_KEY_F9,
//        sdlkeys.SDL_SCANCODE_F10 => pd.DOOM_KEY_F10,
//        sdlkeys.SDL_SCANCODE_F11 => pd.DOOM_KEY_F11,
//        sdlkeys.SDL_SCANCODE_F12 => pd.DOOM_KEY_F12,
//        sdlkeys.SDL_SCANCODE_PAUSE => pd.DOOM_KEY_PAUSE,
//        else => pd.DOOM_KEY_UNKNOWN,
//    };
//}

fn submain() !void {
    // init zepto with a memory allocator and console writer
    zeptolibc.init(uvm.allocator(), consoleWriteFn);

    const zb: *tgl.ZBuffer = tgl.ZB_open(WIDTH, HEIGHT, tgl.ZB_MODE_RGBA, 0, 0, 0, &gfxFramebuffer);
    tgl.glInit(zb);

    const glCtx: *tgl.GLContext = tgl.gl_get_context();
    glCtx.zb = zb;

    reshape(WIDTH, HEIGHT);

    tgl.glLightfv(tgl.GL_LIGHT0, tgl.GL_POSITION, &pos);
    tgl.glEnable(tgl.GL_CULL_FACE);
    tgl.glEnable(tgl.GL_LIGHTING);
    tgl.glEnable(tgl.GL_LIGHT0);
    tgl.glEnable(tgl.GL_DEPTH_TEST);

    // make the gears
    gear1 = tgl.glGenLists(1);
    tgl.glNewList(gear1, tgl.GL_COMPILE);
    tgl.glMaterialfv(tgl.GL_FRONT, tgl.GL_AMBIENT_AND_DIFFUSE, &red);
    gear(1.0, 4.0, 1.0, 20, 0.7);
    tgl.glEndList();

    gear2 = tgl.glGenLists(1);
    tgl.glNewList(gear2, tgl.GL_COMPILE);
    tgl.glMaterialfv(tgl.GL_FRONT, tgl.GL_AMBIENT_AND_DIFFUSE, &green);
    gear(0.5, 2.0, 2.0, 10, 0.7);
    tgl.glEndList();

    gear3 = tgl.glGenLists(1);
    tgl.glNewList(gear3, tgl.GL_COMPILE);
    tgl.glMaterialfv(tgl.GL_FRONT, tgl.GL_AMBIENT_AND_DIFFUSE, &blue);
    gear(1.3, 2.0, 0.5, 10, 0.7);
    tgl.glEndList();

    tgl.glEnable(tgl.GL_NORMALIZE);

    while(true) {
        checkKeys();

        if (leftPressed) {
            view_roty += 5.0;
        }
        if (rightPressed) {
            view_roty -= 5.0;
        }
        if (upPressed) {
            view_rotx += 5.0;
        }
        if (downPressed) {
            view_rotx -= 5.0;
        }

        angle += 2.0;

        tgl.glClear(tgl.GL_COLOR_BUFFER_BIT | tgl.GL_DEPTH_BUFFER_BIT);

        tgl.glPushMatrix();
        tgl.glRotatef(view_rotx, 1.0, 0.0, 0.0);
        tgl.glRotatef(view_roty, 0.0, 1.0, 0.0);
        tgl.glRotatef(view_rotz, 0.0, 0.0, 1.0);

        tgl.glPushMatrix();
        tgl.glTranslatef(-3.0, -2.0, 0.0);
        tgl.glRotatef(angle, 0.0, 0.0, 1.0);
        tgl.glCallList(gear1);
        tgl.glPopMatrix();

        tgl.glPushMatrix();
        tgl.glTranslatef(3.1, -2.0, 0.0);
        tgl.glRotatef(-2.0 * angle - 9.0, 0.0, 0.0, 1.0);
        tgl.glCallList(gear2);
        tgl.glPopMatrix();

        tgl.glPushMatrix();
        tgl.glTranslatef(-3.1, 4.2, 0.0);
        tgl.glRotatef(-2.0 * angle - 25.0, 0.0, 0.0, 1.0);
        tgl.glCallList(gear3);
        tgl.glPopMatrix();

        tgl.glPopMatrix();
        
        uvm.render(@ptrCast(&gfxFramebuffer), WIDTH * HEIGHT * 4);
    }
}

export fn main() void {
    _ = submain() catch {
        uvm.println("Caught err");
    };
}
