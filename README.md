# x86_64 Assembly Snake Implementation
To run:
Either 
> git clone

the repo and use the Makefile (Uses GCC) to compile the executable or using the provided executable


> chmod +x snake \
> ./snake

To play: 
Use i,j,k,m to control the snake. Current level indicates the amount of points you will recieve for eating an apple.
To level up, clear all apples in the current level. The snake will speed up slightly after eating an apple. Obstacles and Apples will increase as the game continues. 
A beep sound will occur to signal eating an apple, leveling up, and the end of the game. The game will end if
the snake hits the borders, itself, or an obstacle. Upon the completion of the game, your game statistics will 
be presented to you in the terminal. 

Note:
Ensure NCURSES is installed when running this program. To install on linux (i.e ubuntu):
> sudo apt-get install libncurses5-dev libncursesw5-dev
