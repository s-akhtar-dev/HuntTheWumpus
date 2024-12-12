# Hunt the Wumpus Game

## Description
The **Hunt the Wumpus** game is a text-based adventure implemented in Zig. Players navigate through a maze filled with various hazards, including pits and the Wumpus itself. The objective is to explore the maze, avoid dangers, and ultimately slay the Wumpus using arrows.

## Authors
- **Sarah Akhtar**
- **Kieran Monks**

## Date
October 5, 2024

## Game Features
- **Maze Exploration**: Navigate through a 4x6 maze with various locations.
- **Hazards**: Encounter pits that lead to instant loss and the Wumpus that must be defeated.
- **Player Movement**: Move in four directions (up, down, left, right) or shoot arrows.
- **Hints**: Receive hints about nearby hazards based on your current location.

## Code Structure
The game consists of several key components:

- **Game State Variables**: Global variables to track player position, direction, and game state.
- **Direction Enum**: Defines possible movement directions and actions.
- **Maze Representation**: A 2D array representing the game maze.
- **Game Options Struct**: Contains various messages for user interaction and feedback.

## Running the Game

To run this game, ensure you have Zig installed on your system. Follow these steps to get started:
1. Clone or download the repository containing the game files.
2. Open your terminal or command prompt.
3. Navigate to the directory containing wumpus.zig.
4. Run the command:
   ```bash
   zig run wumpus.zig
   ```

## Gameplay Instructions
- Use u, d, l, r to move up, down, left, or right respectively.
- Use s to shoot an arrow in the desired direction.
- Pay attention to hints provided after each move to avoid dangers.
  
## Conclusion
The Hunt the Wumpus game is an engaging text-based adventure that combines exploration and strategy. It serves as an excellent example of programming in Zig while providing players with an entertaining challenge.

Feel free to contribute to this project by submitting issues or pull requests!
