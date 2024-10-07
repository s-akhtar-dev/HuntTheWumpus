// PROGRAMMERS: Sarah Akhtar and Kieran Monks
// DATE: 9/24/24
// FILE: wumpus.zig
// DESCRIPTION: This file implements the Hunt the Wumpus game

const std = @import("std");
const print = std.debug.print;

// Game state variables
var isWumpusGameOver: bool = false;
var playerRow: usize = 3;
var playerCol: usize = 0;
var playerDir: Direction = Direction.Up;
var playerArrow: Direction = Direction.Up;
var wumpusLocation: [2]usize = [2]usize{ 0, 0 };

// Enum for player directions
const Direction = enum { Up, Down, Left, Right, Still, Shoot, Illegal };

// Game maze
var wumpusMaze = [4][6]u8{
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
};

// Game messages and options
const gameOptions = struct {
    pub const intro = "Hunt down the wumpus and try to shoot it with your arrow!";
    pub const instruct = "What do you want to do:";
    pub const moveUp = " u) move up";
    pub const moveDown = " d) move down";
    pub const moveLeft = " l) move left";
    pub const moveRight = " r) move right";
    pub const shootArrow = " s) shoot arrow";
    pub const enterChoice = "ENTER CHOICE: ";
    pub const invalidInput = "Oops! Try something else...";
    pub const wumpusBreeze = "You feel a breeze.";
    pub const wumpusStench = "You smell a stench.";
    pub const direction = "What direction do you want to shoot your arrow:";
    pub const shootUp = " u) up";
    pub const shootDown = " d) down";
    pub const shootLeft = " l) left";
    pub const shootRight = " r) right";
    pub const win = "You killed the wumpus! You win the game.";
    pub const wumpLoss = "You fell in the depths of the wumpus tummy. You lost!";
    pub const pitsLoss = "You fell into a dark pit where the wumpus children live. You lost!";
    pub const shotLoss = "You shot in the wrong direction and became the snack for the wumpus. You lost!";
    pub const dir = "That's not a valid direction! The wumpus advises you to try again.";
    pub const wall = "You bumped into as wall!";
};

// Function to print move options
pub fn printMoveOptions() void {
    print("{s}\n", .{gameOptions.instruct});
    print("{s}\n", .{gameOptions.moveUp});
    print("{s}\n", .{gameOptions.moveDown});
    print("{s}\n", .{gameOptions.moveLeft});
    print("{s}\n", .{gameOptions.moveRight});
    print("{s}\n", .{gameOptions.shootArrow});
    print("{s}", .{gameOptions.enterChoice});
}

// Function to print shoot options
pub fn printShootOptions() void {
    print("{s}\n", .{gameOptions.direction});
    print("{s}\n", .{gameOptions.shootUp});
    print("{s}\n", .{gameOptions.shootDown});
    print("{s}\n", .{gameOptions.shootLeft});
    print("{s}\n", .{gameOptions.shootRight});
    print("{s}", .{gameOptions.enterChoice});
}

// Function to generate the Wumpus game maze
pub fn generateWumpusGame() void {
    const rand = std.crypto.random;
    var gameRow: usize = 0;
    var gameCol: usize = 0;

    // Place pits
    for (0..4) |_| {
        gameCol = rand.intRangeAtMost(u8, 1, 5);
        gameRow = rand.intRangeAtMost(u8, 0, 2);
        wumpusMaze[gameRow][gameCol] = 'p';
    }

    // Place Wumpus
    while (true) {
        gameCol = rand.intRangeAtMost(u8, 1, 5);
        gameRow = rand.intRangeAtMost(u8, 0, 2);
        if (wumpusMaze[gameRow][gameCol] == 'O') {
            wumpusMaze[gameRow][gameCol] = 'w';
            wumpusLocation[0] = gameRow;
            wumpusLocation[1] = gameCol;
            break;
        }
    }
}

// Function to print the current game maze
pub fn printWumpusMaze() void {
    for (0..4) |gameRow| {
        for (0..6) |gameCol| {
            if (gameRow == playerRow and gameCol == playerCol) {
                print("X", .{});
            } else {
                print("O", .{});
            }
        }
        print("\n", .{});
    }
}

// Function to print the final game maze
pub fn printGameOverMaze() void {
    for (0..4) |wumpusRow| {
        for (0..6) |wumpusCol| {
            print("{c}", .{wumpusMaze[wumpusRow][wumpusCol]});
        }
        print("\n", .{});
    }
}

// Function to get player input
pub fn setPlayerDecisionWalk(isPlayerMove: bool) void {
    const wumpusReader = std.io.getStdIn().reader();
    var wumpusBuffer: [32]u8 = undefined;
    const input = wumpusReader.readUntilDelimiter(&wumpusBuffer, '\n') catch |err| {
        print("Error reading input: {}\n", .{err});
        playerDir = .Illegal;
        playerArrow = .Illegal;
        return;
    };

    if (input.len > 0 and isPlayerMove) {
        playerDir = switch (input[0]) {
            'u' => .Up,
            'd' => .Down,
            'l' => .Left,
            'r' => .Right,
            's' => .Shoot,
            else => .Illegal,
        };
    } else if (input.len > 0) {
        playerArrow = switch (input[0]) {
            'u' => .Up,
            'd' => .Down,
            'l' => .Left,
            'r' => .Right,
            else => .Illegal,
        };
    }
}

// Function to handle player movement
pub fn wumpusGameFromMove() void {
    if (playerDir == .Shoot) {
        wumpusGameFromShoot();
        return;
    }

    if (!checkValidDirection()) {
        print("{s}\n", .{gameOptions.dir});
        return;
    }

    if (!checkValidMove()) {
        print("{s}\n", .{gameOptions.wall});
        return;
    }

    switch (playerDir) {
        .Up => playerRow -= 1,
        .Down => playerRow += 1,
        .Left => playerCol -= 1,
        .Right => playerCol += 1,
        else => {},
    }

    mazeScentsAndLossDetection();
}

// Function to check if the direction is valid
pub fn checkValidDirection() bool {
    return switch (playerDir) {
        .Up, .Down, .Left, .Right => true,
        else => false,
    };
}

// Function to check if the move is valid
pub fn checkValidMove() bool {
    return switch (playerDir) {
        .Up => playerRow > 0,
        .Down => playerRow < 3,
        .Left => playerCol > 0,
        .Right => playerCol < 5,
        else => false,
    };
}

// Function to detect nearby pits and Wumpus
pub fn mazeScentsAndLossDetection() void {
    var validDirections = std.ArrayList(Direction).init(std.heap.page_allocator);
    defer validDirections.deinit();

    if (playerRow > 0) validDirections.append(.Up) catch unreachable;
    if (playerRow < 3) validDirections.append(.Down) catch unreachable;
    if (playerCol > 0) validDirections.append(.Left) catch unreachable;
    if (playerCol < 5) validDirections.append(.Right) catch unreachable;

    // Detect loss
    if (wumpusMaze[playerRow][playerCol] == 'w') {
        print("{s}\n\n", .{gameOptions.wumpLoss});
        isWumpusGameOver = true;
        printGameOverMaze();
    } else if (wumpusMaze[playerRow][playerCol] == 'p') {
        print("{s}\n\n", .{gameOptions.pitsLoss});
        isWumpusGameOver = true;
        printGameOverMaze();
    } else {
        checkWumpusStenchandBreeze(validDirections.items);
    }
}

// Function to check for Wumpus stench and pit breeze
pub fn checkWumpusStenchandBreeze(directions: []const Direction) void {
    var isStench: bool = false;
    var isBreeze: bool = false;

    for (directions) |direction| {
        var checkRow = playerRow;
        var checkCol = playerCol;

        switch (direction) {
            .Up => checkRow -= 1,
            .Down => checkRow += 1,
            .Left => checkCol -= 1,
            .Right => checkCol += 1,
            else => {},
        }

        if (wumpusMaze[checkRow][checkCol] == 'w' and !isStench) {
            print("{s}\n", .{gameOptions.wumpusStench});
            isStench = true;
        } else if (wumpusMaze[checkRow][checkCol] == 'p' and !isBreeze) {
            print("{s}\n", .{gameOptions.wumpusBreeze});
            isBreeze = true;
        }
    }
}

// Function to handle shooting the arrow
pub fn wumpusGameFromShoot() void {
    printShootOptions();
    setPlayerDecisionWalk(false);
    while (playerArrow == .Illegal) {
        print("{s}\n", .{gameOptions.dir});
        printShootOptions();
        setPlayerDecisionWalk(false);
    }

    const isWumpusShot = switch (playerArrow) {
        .Up => playerRow > 0 and playerRow - 1 == wumpusLocation[0] and playerCol == wumpusLocation[1],
        .Down => playerRow < 3 and playerRow + 1 == wumpusLocation[0] and playerCol == wumpusLocation[1],
        .Left => playerCol > 0 and playerCol - 1 == wumpusLocation[1] and playerRow == wumpusLocation[0],
        .Right => playerCol < 5 and playerCol + 1 == wumpusLocation[1] and playerRow == wumpusLocation[0],
        else => false,
    };

    if (isWumpusShot) {
        print("{s}\n", .{gameOptions.win});
    } else {
        print("{s}\n", .{gameOptions.shotLoss});
    }

    isWumpusGameOver = true;
    printGameOverMaze();
}

// Function to start and run the Wumpus game
pub fn startWumpusGame() void {
    print("{s}\n\n", .{gameOptions.intro});
    generateWumpusGame();
    while (!isWumpusGameOver) {
        printWumpusMaze();
        printMoveOptions();
        setPlayerDecisionWalk(true);
        while (playerDir == .Illegal) {
            print("{s}\n", .{gameOptions.invalidInput});
            printMoveOptions();
            setPlayerDecisionWalk(true);
        }
        wumpusGameFromMove();
        print("\n", .{});
    }
}

// Main function
pub fn main() void {
    startWumpusGame();
}