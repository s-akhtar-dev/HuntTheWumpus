//PROGRAMMER: Dan Cliburn
//DATE: 8/22/24
//FILE: test.zig
//This file provides a short example of how to code in Zig

const std = @import("std");
const print = std.debug.print;

var twoDarray = [3][3]u8{
	.{'C', 'A', 'T'},
	.{'D', 'O', 'G'},
	.{'A', 'C', 'E'},
};

//function to count the occurences of letter in twoDarray
pub fn countIn2Darray(letter:u8) c_int {
	var total: c_int = 0;
	
	for (0..3) |r| {
		for (0..3) |c| {
			if (twoDarray[r][c] == letter) {
				total += 1;
			}
		}
	}
	return total;
}

//function that returns a random character in twoDarray
pub fn randomCharIn2Darray() u8 {
	const rand = std.crypto.random;

	const col: usize = rand.intRangeAtMost(u8, 0, 2);
	const row: usize = rand.intRangeAtMost(u8, 0, 2);

	return twoDarray[row][col];
}

//function to print the contents of the array
pub fn printArray() void {
	for (0..3) |i| {
		print("{s}\n", .{twoDarray[i]}); 
	}
}

pub fn main() !void {
	const reader = std.io.getStdIn().reader();
	var buffer: [16]u8 = undefined; //creates a buffer to hold 16 characters
	var choice: u8 = '1';
	
	while (choice != '4')
	{
		print("What do you want to do:\n 1) count occurrences of a letter in array\n", .{}); 
		print(" 2) return a random letter in array\n 3) print array\n 4) quit\nENTER CHOICE: ", .{});
		const input = try reader.readUntilDelimiter(&buffer, '\n');
		choice = input[0];
		if (choice == '1')
		{
			print("\nWhat letter do you want to search for: ", .{});
			const letter = try reader.readUntilDelimiter(&buffer, '\n');
			print("\n{}\n", .{countIn2Darray(letter[0])});
		}
		else if (choice == '2')
		{
			print("\n{c}\n", .{randomCharIn2Darray()});
		}
		else if (choice == '3')
		{
			printArray();
		}
		else if (choice != '4')
		{
			print("\nInvalid choice\n", .{});
		}
	}
}
