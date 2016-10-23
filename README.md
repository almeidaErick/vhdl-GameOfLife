# vhdl-GameOfLife
Game Of Life implemented in Nexys 4.

Before copying all the files, refer to this video to know more about what the Game Of Life is.
https://www.youtube.com/watch?v=CgOcEZinQ2I

This project simulates a grid, and the evolution of each cells according based on the Conway Game Of Life. Those rules are:

1. A live cell with less than two live neighbours will die, due to under-population.
2. A live cell with two or three live neighbours will survive to the next generation.
3. A live cell with more than three live neighbours will die, due to over-population.
4. A dead cell with exactly three live neighbours will become alive.

Each dead cell is represented by the color "black". Each cell that is alive is represented by different color chosen by the signal "cell_color", defined in the module "pracTop", this signal is modified in the module "userInt".
In other words, this project simulates how living organisms can be borns, evolve and decay. 
Here 3 types of figures can be simulated:
1. still
2. oscillators
3. spaceships

The entire grid (16 x 16) is being sent by radio using the "nRF24L01+ Single Chip 2.4GHz Transceiver", each line of the grid is send each 47ms (no faster than this because the packet may not arrive properly at that speed). The protocol used to comunicate with the nRF24L01+ is SPI, which is shown in the "SPI module", note that this module only sends the message we want giving previously the numbers of bytes we want to send, but this module will not receive any response from the base "radio that receives the grid".

Additionally, VGA is implemented for this project, "vga_display" is the module that controls the display of the grid in a monitor. 

Further details for each modules will be added soon.
