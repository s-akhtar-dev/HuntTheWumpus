//PROGRAMMER: Sarah Akhtar and Kieran Monks
//DATE: 9/24/24
//FILE: wumpus.zig
//This file represents the game, Hunt the Wumpus

const std = @import("std");
const print = std.debug.print;
var isGameOver: bool = false;
var isGameWinner: bool = false;
var userRow: usize = 3;
var userCol: usize = 0;

var interfaceWumpusMap = [4][6]u8 {
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'X', 'O', 'O', 'O', 'O', 'O'},
};

var endingWumpusMap = [4][6]u8 {
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
};

var stenchAndBreezeMap = [4][6]u8 {
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
    .{'O', 'O', 'O', 'O', 'O', 'O'},
};

const gameOptions = struct {
    pub const intro = "Hunt down the wumpus and try to shoot it with your arrow!";
    pub const instruct = "What do you want to do:";
    pub const moveUp = " u) move up";
    pub const moveDown = " d) move down";
    pub const moveLeft = " l) move left";
    pub const moveRight = " r) move right";
    pub const shootArrow = " s) shoot arrow";
    pub const enterChoice = "ENTER CHOICE: ";
    pub const wumpusBreeze = "You feel a breeze.";
    pub const wumpusStench = "You smell a stench.";
    pub const direction = "What direction do you want to shoot your arrow:";
    pub const shootUp = " u) up";
    pub const shootDown = " d) down";
    pub const shootLeft = " l) left";
    pub const shootRight = " r) right";
    pub const win = "You killed the wumpus! You win the game.";
    pub const loss = "You fell in the depths of the wumpus tummy. You lost!";
};

pub fn printMoveOptions() void {
    std.debug.print("{s}\n", .{gameOptions.instruct});
    std.debug.print("{s}\n", .{gameOptions.moveUp});
    std.debug.print("{s}\n", .{gameOptions.moveDown});
    std.debug.print("{s}\n", .{gameOptions.moveLeft});
    std.debug.print("{s}\n", .{gameOptions.moveRight});
    std.debug.print("{s}", .{gameOptions.enterChoice});
}

pub fn printShootOptions() void {
    std.debug.print("{s}\n", .{gameOptions.shootUp});
    std.debug.print("{s}\n", .{gameOptions.shootDown});
    std.debug.print("{s}\n", .{gameOptions.shootLeft});
    std.debug.print("{s}\n", .{gameOptions.shootRight});
    std.debug.print("{s}", .{gameOptions.enterChoice});
}

pub fn generateWumpusGame(counter: i32, genType: u8) void {
    var counterMutating = counter;
    const random = std.crypto.random;

    while (counterMutating > 0) {
        const row: usize = random.intRangeAtMost(u8, 0, 3);
        const col: usize = random.intRangeAtMost(u8, 0, 5);

        if (row != 3 and col != 0) {
            endingWumpusMap[row][col] = genType;
            counterMutating -= 1;
        }
    }
    stenchAndBreezeMap = endingWumpusMap;
    generateBreezeAndStench();
}


pub fn generateBreezeAndStench() void {
    const height = 4;
    const width = 6;

    for (0..height) |row| {
        for (0..width) |col| {
            if (stenchAndBreezeMap[row][col] == 'w') {
                addHintsToMap(row, col, 's', height, width);
            } else if (stenchAndBreezeMap[row][col] == 'p') {
                addHintsToMap(row, col, 'b', height, width);
            }
        }
    }
}

pub fn addHintsToMap(wumpusRow: usize, wumpusCol: usize, genType: u8, height: usize, width: usize) void {
    var currentRow: usize = 0;
    var currentCol: usize = 0;

    if (wumpusRow > 0) {
        currentRow = wumpusRow - 1;
        placeMarker(currentRow, wumpusCol, genType);
    }
    if (wumpusRow + 1 < height) {
        currentRow = wumpusRow + 1;
        placeMarker(currentRow, wumpusCol, genType);
    }
    if (wumpusCol > 0) {
        currentCol = wumpusCol - 1;
        placeMarker(wumpusRow, currentCol, genType);
    }
    if (wumpusCol + 1 < width) {
        currentCol = wumpusCol + 1;
        placeMarker(wumpusRow, currentCol, genType);
    }
}

fn placeMarker(row: usize, col: usize, marker: u8) void {
    const existingMarker = stenchAndBreezeMap[row][col];
    if (existingMarker == 'O') {
        stenchAndBreezeMap[row][col] = marker;
    } else if ((existingMarker == 's' and marker == 'b') or (existingMarker == 'b' and marker == 's')) {
        stenchAndBreezeMap[row][col] = 'x';
    }
}

pub fn printWumpusMap(wumpusMap: [4][6]u8) void {
    for (0..4) |wumpusRow| {
        for (0..6) |wumpusCol| {
            print("{c}", .{wumpusMap[wumpusRow][wumpusCol]});
        }
        std.debug.print("\n", .{});
    }
}

pub fn getPlayerSelection() u8 {
    const wumpusReader = std.io.getStdIn().reader();
    var wumpusBuffer: [8]u8 = undefined;
    if (wumpusReader.readUntilDelimiter(&wumpusBuffer, '\n')) |input| {
        if (input.len > 0) { return input[0]; }
    } else |_| {}
    return '0';
}

pub fn wumpusGameFromMove(selection: u8) void {
    switch (selection) {
        'u' => {
            movePlayerOnWumpusMap("up");
            checkPosition(userCol, userRow);
        },
        'd' => {
            movePlayerOnWumpusMap("down");
            checkPosition(userCol, userRow);
        },
        'l' => {
            movePlayerOnWumpusMap("left");
            checkPosition(userCol, userRow);
        },
        'r' => {
            movePlayerOnWumpusMap("right");
            checkPosition(userCol, userRow);
        },
        's' => {
            std.debug.print("{s}\n\n", .{gameOptions.shootArrow});
            printShootOptions();
            const userSelection: u8 = getPlayerSelection();
            wumpusGameFromShoot(userSelection);
        },
        else => {
            print("Invalid option. Please try again.\n", .{});
            std.debug.print("{s}\n\n", .{gameOptions.enterChoice});
            const userSelection: u8 = getPlayerSelection();
            wumpusGameFromMove(userSelection);
        }
    }
}

pub fn wumpusGameFromShoot(selection: u8) void {
    var hit: bool = false;
    switch (selection) {
        'u' => {
            for ((userRow - 1)..0) |row| {
                if (stenchAndBreezeMap[row][userCol] == 'w') {
                    hit = true;
                    break;
                }
            }
        },
        'd' => {
            for ((userRow + 1)..3) |row| {
                if (stenchAndBreezeMap[row][userCol] == 'w') {
                    hit = true;
                    break;
                }
            }
        },
        'l' => {
            for ((userCol - 1)..0) |col| {
                if (stenchAndBreezeMap[userRow][col] == 'w') {
                    hit = true;
                    break;
                }
            }
        },
        'r' => {
            for ((userCol + 1)..5) |col| {
                if (stenchAndBreezeMap[userRow][col] == 'w') {
                    hit = true;
                    break;
                }
            }
        },
        else => {
            print("Invalid option. Please try again.\n", .{});
            return;
        }
    }

    if (hit) {
        isGameWinner = true;
        isGameOver = true;
        print("{s}\n", .{gameOptions.win});
    } else {
        print("You missed the Wumpus!\n", .{});
    }
}

pub fn movePlayerOnWumpusMap(moveType: []const u8) void {
    if (std.mem.eql(u8, moveType, "up")) {
        if (userRow > 0) {
            userRow -= 1;
        }
    } else if (std.mem.eql(u8, moveType, "down")) {
        if (userRow < 3) {
            userRow += 1;
        }
    } else if (std.mem.eql(u8, moveType, "left")) {
        if (userCol > 0) {
            userCol -= 1;
        }
    } else if (std.mem.eql(u8, moveType, "right")) {
        if (userCol < 5) {
            userCol += 1;
        }
    } else {
        std.debug.print("You bumped into a wall.", .{});
    }
    updatePlayerPosition();
}

fn updatePlayerPosition() void {
    interfaceWumpusMap = endingWumpusMap; // Reset map to base
    interfaceWumpusMap[userRow][userCol] = 'X'; // Mark the player position
}

pub fn shootWumpusOnMap() void {

}

pub fn checkPosition(row: usize, col: usize) void {
    const elementCharacter = stenchAndBreezeMap[row][col];
    if (elementCharacter == 's') {
        std.debug.print("{s}\n\n", .{gameOptions.wumpusStench});
    } else if (elementCharacter == 'b') {
        std.debug.print("{s}\n\n", .{gameOptions.wumpusBreeze});
    } else if (elementCharacter == 'x') {
        std.debug.print("{s}\n\n", .{gameOptions.wumpusStench});
        std.debug.print("{s}\n\n", .{gameOptions.wumpusBreeze});
    }
}

pub fn startWumpusGame() void {
    var userSelection: u8 = '0';
    std.debug.print("{s}\n\n", .{gameOptions.intro});
    generateWumpusGame(1, 'w');
    generateWumpusGame(4, 'p');
    checkPosition(userRow, userCol);

    while (!isGameOver) {
        printWumpusMap(interfaceWumpusMap);
        std.debug.print("\n", .{});
        printWumpusMap(stenchAndBreezeMap);
        printMoveOptions();
        userSelection = getPlayerSelection();
        wumpusGameFromMove(userSelection);
    }

    const ending = if (isGameWinner) .{gameOptions.win} else .{gameOptions.loss};
    std.debug.print("{s}\n\n", ending);
    printWumpusMap(endingWumpusMap);
}

pub fn main() !void {
    startWumpusGame();
}