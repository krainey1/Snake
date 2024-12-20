all: snake

snake: main.o playfield.o snake.o
	gcc -no-pie -g -Wall $^ -o $@ -lncurses

main.o: main.s
	gcc -no-pie -g -Wall -c $^ -o $@

playfield.o: playfield.s
	gcc -no-pie -g -Wall -c  $^ -o $@ 
snake.o: snake.s
	gcc -no-pie -g -Wall -c $^ -o $@
clean: 
	rm *.o snake
