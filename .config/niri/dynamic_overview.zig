const std = @import("std");
const posix = std.posix;
const OVERVIEW_VAL_POS = 61;
const END_POS = 68;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;

pub fn get_overview_val_pos(settings_content: []u8) [2]usize {
    var positions: [2]usize = undefined;
    positions[0] = std.mem.indexOf(u8, settings_content, "0").?;
    positions[1] = positions[0] + std.mem.indexOf(u8, settings_content[positions[0]..], "\n").? - 1;
    return positions;
}

/// write in settings_file at OVERVIEW_VAL_POS the value of overview_val
pub fn change_overview(settings_content: []u8, settings_file: std.fs.File, overview_val: u64) !void {
    // const ovw_idx_rng = pos[1]  - pos[0]
    var buffer: [4]u8 = undefined;
    const res = try std.fmt.bufPrint(&buffer, "{d}", .{overview_val});
    @memmove(settings_content[OVERVIEW_VAL_POS + 2 .. OVERVIEW_VAL_POS + 4], res);

    try settings_file.seekTo(0);
    _ = try settings_file.write(settings_content[0 .. END_POS - 1]);
}

pub fn main() !void {
    var verbose = false;
    for (std.os.argv) |arg| {
        verbose |= std.mem.eql(u8, std.mem.span(arg), "--verbose");
    }
    const exe_path = try std.fs.selfExeDirPathAlloc(allocator);
    defer allocator.free(exe_path);
    const dir = try std.fs.openDirAbsolute(exe_path, .{});
    const settings_file = try dir.openFile("overview.kdl", .{ .mode = .read_write });
    // const settings_file = try std.fs.cwd().openFile("overview.kdl", .{ .mode = .read_write });
    defer settings_file.close();

    var settings_content: [512]u8 = undefined;
    var overview_val: u64 = 99;

    const file_size = try settings_file.read(&settings_content);
    const pos = get_overview_val_pos(&settings_content);
    std.debug.print(" overview val positions = [{d},{d}] \n", .{ pos[0], pos[1] });
    std.debug.print("overview start : {c} \n", .{settings_content[pos[0]]});
    std.debug.print("overview end : {c} \n", .{settings_content[pos[1]]});

    std.debug.print(" file size : {d} \n", .{file_size});
    for (settings_content[0..file_size], 0..) |elem, i| {
        std.debug.print("file content char n° [ {d} ]: {c} \n", .{ i, elem });
    }

    var socket_path: [108]u8 = undefined;
    if (posix.getenv("NIRI_SOCKET")) |sp| {
        std.debug.assert(sp.len < socket_path.len);
        @memcpy(socket_path[0..sp.len], sp);
        socket_path[sp.len] = 0;
        std.debug.print("Connected to Niri socket at : {s} \n", .{socket_path[0 .. sp.len + 1]});
    }
    var addr = posix.system.sockaddr.un{ .family = posix.system.AF.UNIX, .path = socket_path };

    const niri_socket = try posix.socket(posix.system.AF.UNIX, posix.system.SOCK.STREAM, 0);
    defer std.posix.close(niri_socket);
    try posix.connect(niri_socket, @ptrCast(&addr), 108);

    // Event Stream Request
    _ = try std.posix.write(niri_socket, "\"EventStream\"\n");
    var buffer: [4096]u8 = undefined;
    var bytesRead: usize = undefined;
    var response: []u8 = undefined;
    var nb_workspaces: usize = 0;
    var inOverview = false;

    while (true) {
        bytesRead = try std.posix.recv(niri_socket, &buffer, 0);
        response = buffer[0..bytesRead];
        if (verbose) {
            std.debug.print("NIRI >>> {s} \n", .{response});
        }
        if (std.mem.indexOf(u8, response, "\"workspaces\"")) |w_idx| {
            // the index Of got here is relative to the slice passed in parameter
            // which start at w_idx of response
            const w_array_start = w_idx + std.mem.indexOf(u8, response[w_idx..], "[").?;
            const w_array_end = w_idx + std.mem.indexOf(u8, response[w_idx..], "]").?;
            nb_workspaces = std.mem.count(u8, response[w_array_start..w_array_end], "{");

            if (std.mem.indexOf(u8, response, "\"OverviewOpenedOrClosed\"")) |o_idx| {
                // overview info index in buffer
                const o_obj_end = o_idx + std.mem.indexOf(u8, response[o_idx..], "}").?;
                if (std.mem.containsAtLeast(u8, response[o_idx..o_obj_end], 1, "true")) {
                    inOverview = true;
                }
            }

            if (!inOverview) {
                overview_val = switch (nb_workspaces) {
                    0, 1, 2 => 99,
                    3 => 65,
                    4 => 45,
                    5 => 25,
                    else => 20,
                };
                try change_overview(&settings_content, settings_file, overview_val);
            }
        }

        if (verbose) {
            std.debug.print(" number of workspaces =  {d} \n", .{nb_workspaces});
            std.debug.print(" overview value = {d} \n", .{overview_val});

            std.debug.print(" \n", .{}); // new line
        }
    }
}
