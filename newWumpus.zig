//PROGRAMMER: Sarah Akhtar and Kieran Monks
//DATE: 9/24/24
//FILE: wumpus.zig
//This file represents the game, Hunt the Wumpus

const std = @import("std");
const print = std.debug.print;
var isWumpusGameOver: bool = false;
var playerRow: usize = 3;
var playerCol: usize = 0;
var playerDir: Direction = Direction.Up;
var playerArrow: Direction = Direction.Up;
var wumpusLocation: [2]usize = [2]usize{ 0, 0 };

const Direction = enum { Up, Down, Left, Right, Shoot, Illegal };

var wumpusMaze = [4][6]u8{
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
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
    pub const wumpLoss = "You fell in the depths of the wumpus tummy. You lost!";
    pub const pitsLoss = "You fell into a dark cave where the wumpus children live. You lost!";
    pub const shotLoss = "You shot in the wrong direction and became the snack for the wumpus. You lost!";
    pub const dir = "That's not a valid direction! The wumpus advises you to try again.";
    pub const wall = "You bumped into a fuzzy wall!";
};

pub fn printMoveOptions() void {
    std.debug.print("{s}\n", .{gameOptions.instruct});
    std.debug.print("{s}\n", .{gameOptions.moveUp});
    std.debug.print("{s}\n", .{gameOptions.moveDown});
    std.debug.print("{s}\n", .{gameOptions.moveLeft});
    std.debug.print("{s}\n", .{gameOptions.moveRight});
    std.debug.print("{s}\n", .{gameOptions.shootArrow});
    std.debug.print("{s}", .{gameOptions.enterChoice});
}

pub fn printShootOptions() void {
    std.debug.print("{s}\n", .{gameOptions.shootUp});
    std.debug.print("{s}\n", .{gameOptions.shootDown});
    std.debug.print("{s}\n", .{gameOptions.shootLeft});
    std.debug.print("{s}\n", .{gameOptions.shootRight});
    std.debug.print("{s}", .{gameOptions.enterChoice});
}

pub fn generateWumpusGame() void {
    const rand = std.crypto.random;
    var gameRow: usize = 0;
    var gameCol: usize = 0;

    //
    for (0..4) |row| {
        gameCol = rand.intRangeAtMost(u8, 1, 5);
        wumpusMaze[row][gameCol] = 'p';
    }

    //
    gameCol = rand.intRangeAtMost(u8, 1, 5);
    gameRow = rand.intRangeAtMost(u8, 0, 2);
    while (wumpusMaze[gameRow][gameCol] == 'p') {
        gameCol = rand.intRangeAtMost(u8, 1, 5);
        gameRow = rand.intRangeAtMost(u8, 0, 2);
    }
    wumpusMaze[gameRow][gameCol] = 'w';
    wumpusLocation[0] = gameRow;
    wumpusLocation[1] = gameCol;
}

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

pub fn printGameOverMaze() void {
    for (0..4) |wumpusRow| {
        for (0..6) |wumpusCol| {
            print("{c}", .{wumpusMaze[wumpusRow][wumpusCol]});
        }
        std.debug.print("\n", .{});
    }
}

pub fn setPlayerDecisionWalk(isPlayerMove: bool) void {
    const wumpusReader = std.io.getStdIn().reader();
    var wumpusBuffer: [32]u8 = undefined;

    const input = wumpusReader.readUntilDelimiter(&wumpusBuffer, '\n') catch |err| {
        std.debug.print("Error reading input: {}\n", .{err});
        playerDir = .Illegal;
        playerArrow = .Illegal;
        return;
    };

    if (input.len > 0 and isPlayerMove) {
        if (input[0] == 'u') {
            playerDir = Direction.Up;
        } else if (input[0] == 'd') {
            playerDir = Direction.Down;
        } else if (input[0] == 'l') {
            playerDir = Direction.Left;
        } else if (input[0] == 'r') {
            playerDir = Direction.Right;
        } else if (input[0] == 's') {
            playerDir = Direction.Shoot;
        } else {
            playerDir = Direction.Illegal;
        }
    } else if (input.len > 0) {
        if (input[0] == 'u') {
            playerArrow = Direction.Up;
        } else if (input[0] == 'd') {
            playerArrow = Direction.Down;
        } else if (input[0] == 'l') {
            playerArrow = Direction.Left;
        } else if (input[0] == 'r') {
            playerArrow = Direction.Right;
        } else {
            playerArrow = Direction.Illegal;
        }
    }
}

pub fn wumpusGameFromMove() void {
    if (playerDir == .Shoot) {
        wumpusGameFromShoot();
        return;
    }

    if (!checkValidDirection()) {
        std.debug.print("{s}\n", .{gameOptions.dir});
        return;
    }

    if (!checkValidMove()) {
        std.debug.print("{s}\n", .{gameOptions.wall});
        return;
    }

    if (playerDir == .Up) {
        playerRow -= 1;
    } else if (playerDir == .Down) {
        playerRow += 1;
    } else if (playerDir == .Left) {
        playerCol -= 1;
    } else if (playerDir == .Right) {
        playerCol += 1;
    }

    mazeScentsAndLossDetection();
}

pub fn checkValidDirection() bool {
    return ((playerDir == .Up) or (playerDir == .Down) or (playerDir == .Left) or (playerDir == .Right));
}

pub fn checkValidMove() bool {
    if (playerDir == .Up and playerRow == 0) {
        return false;
    } else if (playerDir == .Down and playerRow == 3) {
        return false;
    } else if (playerDir == .Left and playerCol == 0) {
        return false;
    } else if (playerDir == .Right and playerCol == 5) {
        return false;
    }
    return true;
}

pub fn mazeScentsAndLossDetection() void {
    var validDirections = std.ArrayList(Direction).init(std.heap.page_allocator);
    defer validDirections.deinit();

    if (playerRow > 0) {
        validDirections.append(.Up) catch unreachable;
    }
    if (playerRow < 3) {
        validDirections.append(.Down) catch unreachable;
    }
    if (playerCol > 0) {
        validDirections.append(.Left) catch unreachable;
    }
    if (playerCol < 5) {
        validDirections.append(.Right) catch unreachable;
    }

    // Detect loss
    if (wumpusMaze[playerRow][playerCol] == 'w') {
        std.debug.print("{s}\n\n", .{gameOptions.wumpLoss});
        isWumpusGameOver = true;
        printGameOverMaze();
    } else if (wumpusMaze[playerRow][playerCol] == 'p') {
        std.debug.print("{s}\n\n", .{gameOptions.pitsLoss});
        isWumpusGameOver = true;
        printGameOverMaze();
    }

    checkWumpusStenchandBreeze(validDirections.items);
}

pub fn checkWumpusStenchandBreeze(directions: []const Direction) void {
    for (directions) |direction| {
        var checkRow = playerRow;
        var checkCol = playerCol;
        var isStench: bool = false;
        var isBreeze: bool = false;

        if (direction == .Up) {
            checkRow -= 1;
        } else if (direction == .Down) {
            checkRow += 1;
        } else if (direction == .Left) {
            checkCol -= 1;
        } else if (direction == .Right) {
            checkCol += 1;
        }

        if (wumpusMaze[checkRow][checkCol] == 'w' and !isStench) {
            std.debug.print("{s}\n", .{gameOptions.wumpusStench});
            isStench = true;
        } else if (wumpusMaze[checkRow][checkCol] == 'p' and !isBreeze) {
            std.debug.print("{s}\n", .{gameOptions.wumpusBreeze});
            isBreeze = false;
        }
    }
}

pub fn wumpusGameFromShoot() void {
    printShootOptions();
    setPlayerDecisionWalk(false);
    var isWumpusShot: bool = false;

    while (playerArrow == .Illegal) {
        print("{s}\n", .{gameOptions.dir});
        printShootOptions();
        setPlayerDecisionWalk(false);
    }

    if (playerArrow == .Up) {
        isWumpusShot = (playerRow > wumpusLocation[0] and playerCol == wumpusLocation[1]);
    } else if (playerArrow == .Down) {
        isWumpusShot = (playerRow < wumpusLocation[0] and playerCol == wumpusLocation[1]);
    } else if (playerArrow == .Left) {
        isWumpusShot = (playerCol > wumpusLocation[1] and playerRow == wumpusLocation[0]);
    } else if (playerArrow == .Right) {
        isWumpusShot = (playerCol < wumpusLocation[1] and playerRow == wumpusLocation[0]);
    }

    if (isWumpusShot) {
        print("{s}\n", .{gameOptions.win});
    } else {
        print("{s}\n", .{gameOptions.shotLoss});
    }

    isWumpusGameOver = true;
    printGameOverMaze();
}

pub fn startWumpusGame() void {
    std.debug.print("{s}\n\n", .{gameOptions.intro});
    generateWumpusGame();

    while (!isWumpusGameOver) {
        printWumpusMaze();
        printMoveOptions();
        setPlayerDecisionWalk(true);
        while (playerDir == .Illegal) { setPlayerDecisionWalk(true); }
        wumpusGameFromMove();
        print("\n", .{});
    }
}

pub fn main() void {
    startWumpusGame();
}
