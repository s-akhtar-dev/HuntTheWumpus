// PROGRAMMERS: Sarah Akhtar and Kieran Monks
// DATE: 10/05/2024
// FILE: wumpus.zig
// DESCRIPTION: This file implements the Hunt the Wumpus game
// ----------------------------------------------------------- //

// === Imports and Game State Variables ===

/// Standard library and printing imports
const std = @import("std");
const print = std.debug.print;

/// Global variables for storing player states including:
/// - The current row/column position for the player
/// - The current player proposed direction to move
/// - The current arrow direction set by player
var playerRow: usize = 3;
var playerCol: usize = 0;
var playerDir: Direction = Direction.Still;
var playerArrow: Direction = Direction.Still;

/// Global variables for detecting game over and storing wumpus location
var isWumpusGameOver: bool = false;
var wumpusLocation: [2]usize = [2]usize{ 0, 0 };

/// Enum for storing direction states as follows:
/// - Up/Down/Left/Right: valid direction
/// - Illegal: invalid direction for moving
/// - Still: current player row/column
/// - Shoot: player declares an arrow shot
const Direction = enum { Up, Down, Left, Right, Still, Shoot, Illegal };

/// Hunt the Wumpus Maze for Gameplay
var wumpusMaze = [4][6]u8{
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
    .{ 'O', 'O', 'O', 'O', 'O', 'O' },
};

// === Hunt the Wumpus Feedback and Input Messages ===

/// Struct for storing accessible game message variants
const gameOptions = struct {
    // Introduction and win message
    pub const intro = "Hunt down the wumpus and try to shoot it with your arrow!";
    pub const win = "You killed the wumpus! You win the game.";

    // Player move direction prompts
    pub const instruct = "What do you want to do:";
    pub const moveUp = " u) move up";
    pub const moveDown = " d) move down";
    pub const moveLeft = " l) move left";
    pub const moveRight = " r) move right";
    pub const shootArrow = " s) shoot arrow";

    // Entering a direction and feedback message
    pub const enterChoice = "ENTER CHOICE: ";
    pub const invalidInput = "Oops! Try something else...";

    // Wumpus stench and pit breeze message
    pub const wumpusBreeze = "You feel a breeze.";
    pub const wumpusStench = "You smell a stench.";

    // Player shoot direction prompts
    pub const direction = "What direction do you want to shoot your arrow:";
    pub const shootUp = " u) up";
    pub const shootDown = " d) down";
    pub const shootLeft = " l) left";
    pub const shootRight = " r) right";

    // Various loss and feedback messages
    pub const wumpLoss = "You fell in the depths of the wumpus tummy. You lost!";
    pub const pitsLoss = "You fell into a dark pit where the wumpus children live. You lost!";
    pub const shotLoss = "You shot in the wrong direction and became the snack for the wumpus. You lost!";
    pub const dir = "That's not a valid direction! The wumpus advises you to try again.";
    pub const wall = "You bumped into as wall!";
};

// === Hunt the Wumpus Main Method ===

/// Starts the game of Hunt the Wumpus
pub fn main() void {
    startWumpusGame();
}

// === Hunt the Wumpus Game Initialization Method ===

/// Method to create and loop through wumpus game
pub fn startWumpusGame() void {
    // Prints introduction message and generates random maze
    print("{s}\n\n", .{gameOptions.intro});
    generateWumpusGame();

    // Plays Hunt the Wumpus until game is over
    while (!isWumpusGameOver) {
        // Displays maze, options, and sets direction
        printWumpusMaze();
        printMoveOptions();
        setPlayerDirection(true);
        
        // Ensures the direction is a legal option
        while (playerDir == .Illegal) {
            print("{s}\n", .{gameOptions.invalidInput});
            printMoveOptions();
            setPlayerDirection(true);
        }

        // Prints hints and continues game
        wumpusGameFromMove();
        print("\n", .{});
    }
}

// === Hunt the Wumpus Direction Prompt Methods ===

/// Prints the sequence of messages for moving player
pub fn printMoveOptions() void {
    print("{s}\n", .{gameOptions.instruct});
    print("{s}\n", .{gameOptions.moveUp});
    print("{s}\n", .{gameOptions.moveDown});
    print("{s}\n", .{gameOptions.moveLeft});
    print("{s}\n", .{gameOptions.moveRight});
    print("{s}\n", .{gameOptions.shootArrow});
    print("{s}", .{gameOptions.enterChoice});
}

/// Prints the sequence of messages for shooting arrow
pub fn printShootOptions() void {
    print("{s}\n", .{gameOptions.direction});
    print("{s}\n", .{gameOptions.shootUp});
    print("{s}\n", .{gameOptions.shootDown});
    print("{s}\n", .{gameOptions.shootLeft});
    print("{s}\n", .{gameOptions.shootRight});
    print("{s}", .{gameOptions.enterChoice});
}

// === Hunt the Wumpus Map Generation and Printing Methods ===

/// Generates placement of pits and wumpus for maze
/// - The pits and wumpus locations exclude the last row and first column
pub fn generateWumpusGame() void {
    // Creates random number generator and placeholders
    const rand = std.crypto.random;
    var gameRow: usize = 0;
    var gameCol: usize = 0;

    // Generates four pits in maze from valid boundaries
    for (0..4) |_| {
        gameCol = rand.intRangeAtMost(u8, 1, 5);
        gameRow = rand.intRangeAtMost(u8, 0, 2);
        wumpusMaze[gameRow][gameCol] = 'p';
    }

    // Generates wumpus in maze, avoiding the placements of pits
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

/// Prints the maze with player and with pits and wumpus hidden
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

/// Prints the maze with player and with pits and wumpus showing
pub fn printGameOverMaze() void {
    for (0..4) |wumpusRow| {
        for (0..6) |wumpusCol| {
            print("{c}", .{wumpusMaze[wumpusRow][wumpusCol]});
        }
        print("\n", .{});
    }
}

// === Hunt the Wumpus Player Move Validation and Update Methods ===

/// Sets potential player move or arrow direction from input
/// - Illegal moves will result in a feedback message for retry
/// - isPlayerMove will determine whether player or arrow is set
pub fn setPlayerDirection(isPlayerMove: bool) void {
    // Reads input from player and throws optional error
    const wumpusReader = std.io.getStdIn().reader();
    var wumpusBuffer: [32]u8 = undefined;
    const input = wumpusReader.readUntilDelimiter(&wumpusBuffer, '\n') catch |err| {
        print("Error reading input: {}\n", .{err});
        playerDir = .Illegal;
        playerArrow = .Illegal;
        return;
    };

    // Determines whether input is illegal and if arrow or move is updated
    if (input.len > 0 and isPlayerMove) {
        playerDir = switch (input[0]) {
            'u' => .Up, 'd' => .Down, 'l' => .Left, 'r' => .Right, 's' => .Shoot,
            else => .Illegal,
        };
    } else if (input.len > 0) {
        playerArrow = switch (input[0]) {
            'u' => .Up, 'd' => .Down, 'l' => .Left, 'r' => .Right,
            else => .Illegal,
        };
    }
}

/// Updates maze from move and prints maze feedback
/// - Checks for valid direction and bounds for moving
/// - Updates direction from move and detects hints
pub fn wumpusGameFromMove() void {
    // Shoots arrow if player selected arrow
    if (playerDir == .Shoot) {
        wumpusGameFromShoot();
        return;
    }

    // Checks for illegal direction before update
    if (!checkValidDirection()) {
        print("{s}\n", .{gameOptions.dir});
        return;
    }

    // Checks for illegal bounds before update
    if (!checkValidMove()) {
        print("{s}\n", .{gameOptions.wall});
        return;
    }

    // Updates player direction from move
    switch (playerDir) {
        .Up => playerRow -= 1, .Down => playerRow += 1,
        .Left => playerCol -= 1, .Right => playerCol += 1,
        else => {},
    }

    // Detects potential stench and breeze
    mazeScentsAndLossDetection();
}

/// Check for valid direction from player input
pub fn checkValidDirection() bool {
    return switch (playerDir) {
        .Up, .Down, .Left, .Right => true,
        else => false,
    };
}

/// Check for valid bounds from player input
pub fn checkValidMove() bool {
    return switch (playerDir) {
        .Up => playerRow > 0, .Down => playerRow < 3,
        .Left => playerCol > 0, .Right => playerCol < 5,
        else => false,
    };
}

// === Hunt the Wumpus Player Loss Detection and Hint Methods ===

/// Determines a player loss or hints from move
pub fn mazeScentsAndLossDetection() void {
    // Creates a valid directions array for hint detection
    var validDirections = std.ArrayList(Direction).init(std.heap.page_allocator);
    defer validDirections.deinit();

    // Ensures that player position is valid for moving
    if (playerRow > 0) validDirections.append(.Up) catch unreachable;
    if (playerRow < 3) validDirections.append(.Down) catch unreachable;
    if (playerCol > 0) validDirections.append(.Left) catch unreachable;
    if (playerCol < 5) validDirections.append(.Right) catch unreachable;

    // Determines a loss from wumpus or pit, otherwise prints hints
    if (wumpusMaze[playerRow][playerCol] == 'w') {
        print("{s}\n\n", .{gameOptions.wumpLoss});
        isWumpusGameOver = true;
        printGameOverMaze();
    } else if (wumpusMaze[playerRow][playerCol] == 'p') {
        print("{s}\n\n", .{gameOptions.pitsLoss});
        isWumpusGameOver = true;
        printGameOverMaze();
    } else {
        printWumpusStenchandBreeze(validDirections.items);
    }
}

/// Prints hints from pit and wumpus locations
pub fn printWumpusStenchandBreeze(directions: []const Direction) void {
    // Stores state for one hint per obstacle
    var isStench: bool = false;
    var isBreeze: bool = false;

    // Checks all directions to ensure hints are detected
    for (directions) |direction| {
        var checkRow = playerRow;
        var checkCol = playerCol;

        // Updates direction for hint checking
        switch (direction) {
            .Up => checkRow -= 1,
            .Down => checkRow += 1,
            .Left => checkCol -= 1,
            .Right => checkCol += 1,
            else => {},
        }

        // Prints hints based on wumpus or pit detection
        if (wumpusMaze[checkRow][checkCol] == 'w' and !isStench) {
            print("{s}\n", .{gameOptions.wumpusStench});
            isStench = true;
        } else if (wumpusMaze[checkRow][checkCol] == 'p' and !isBreeze) {
            print("{s}\n", .{gameOptions.wumpusBreeze});
            isBreeze = true;
        }
    }
}

// === Hunt the Wumpus Arrow Shooting Method ===

/// Concludes the game from player arrow shot
pub fn wumpusGameFromShoot() void {
    // Prints game prompts and sets direction
    printShootOptions();
    setPlayerDirection(false);

    // Ensures that player arrow direction is legal
    while (playerArrow == .Illegal) {
        print("{s}\n", .{gameOptions.dir});
        printShootOptions();
        setPlayerDirection(false);
    }

    // Determines if the arrow shot direction hits the wumpus
    const isWumpusShot = switch (playerArrow) {
        .Up => playerRow > 0 and playerRow - 1 == wumpusLocation[0] and playerCol == wumpusLocation[1],
        .Down => playerRow < 3 and playerRow + 1 == wumpusLocation[0] and playerCol == wumpusLocation[1],
        .Left => playerCol > 0 and playerCol - 1 == wumpusLocation[1] and playerRow == wumpusLocation[0],
        .Right => playerCol < 5 and playerCol + 1 == wumpusLocation[1] and playerRow == wumpusLocation[0],
        else => false,
    };

    // Prints message based on success of arrow shot
    if (isWumpusShot) { print("{s}\n", .{gameOptions.win});
    } else { print("{s}\n", .{gameOptions.shotLoss}); }

    // Ends the game and prints full maze
    isWumpusGameOver = true;
    printGameOverMaze();
}