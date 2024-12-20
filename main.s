#main.s 


.section .data 
intro: .asciz "Press Key to Start"
outro: .asciz "Done, press key to exit"
endscore: .string "Your score was %d.\n"
endsegments: .string "Your snake had %d segments. \n"
endlevel: .string "You made it to level %d.\n"

.section .text
.global main 

main:
        push %rbp
        call initscr #initialize ncurses
        call start_color #start color mode

        #red coloring
        movq $1, %rdi
        movq $1, %rsi
        movq $0, %rdx
        call init_pair

        #snake coloring
        movq $2, %rdi
        movq $3, %rsi
        movq $0, %rdx
        call init_pair

        #obstacle coloring
        movq $3, %rdi
        movq $0, %rsi
        movq $4, %rdx
        call init_pair


        call initp #renders the border, the snake playfield is a new window
        movl $0, %edi
        call curs_set #set the cursor to invisible
        #seed random number generator
        movl $0, %edi
        call time
        movl %eax, %edi
        call srand

        #start coloring
        
        movl $1, %edi
        call COLOR_PAIR
        movq %r13, %rdi
        movl %eax, %esi
        call wattron

        #intro Press Key to Start message on border
        movq %r13, %rdi
        movq $0, %rsi
        movq $31, %rdx
        leaq intro(%rip), %rcx #prints the intro onto the playfield border
        call mvwprintw
        
        #end coloring
        movq %r13, %rdi
        movl $1, %esi
        shll $8, %esi
        call wattroff

        

        movq %r13, %rdi
        call wrefresh #refreshes window/needed if changes made to window
        movq %r13, %rdi
        movl $2, %esi
        shll $8, %esi
        call wattron #start snake color
        call dummy_snake #sets the starting snake
        movq %r13, %rdi
        movl $2, %esi
        shll $8, %esi
        call wattroff #end snake color
        movq %r13, %rdi
        movl $3, %esi
        shll $8, %esi
        call wattron
        call place_obstacle #place initial obstacle
        movq %r13, %rdi
        movl $3, %esi
        shll $8, %esi
        call wattroff
        call generate_apples #generate apples
       
        movq %r13, %rdi
        movl $1, %esi
        shll $8, %esi
        call wattron #start apple coloring

        call show_apples #put apples to screen
        
        movq %r13, %rdi
        movl $1, %esi
        shll $8, %esi
        call wattroff
        
        movq %r13, %rdi
        call wrefresh #refreshes window/needed if changes made to window
        movl $1, %edi
        shll $8, %edi
        call attron
        call get_level #get/print level
        movl %eax, %edi
        call level_print
        call get_score #get/print score
        movl %eax, %edi
        call score_print
        call get_segments #get/print segments
        movl %eax, %edi
        call segment_print
        
startpoint:
        call getch #initial key press to start
        cmpl $'k', %eax
        je gameentry
        cmpl $'j', %eax
        je gameentry
        cmpl $'i', %eax
        je gameentry
        cmpl $'m', %eax
        je gameentry
        jmp startpoint
gameentry: 
        call initp
        call current_obstacle
        call get_level
        movl %eax, %edi
        call level_print
        call get_score
        movl %eax, %edi
        call score_print
        call get_segments
        movl %eax, %edi
        call segment_print
        movl $100, %edi #milliseconds
        call timeout #non blocking mode
        call draw_snake
game_loop: #the main gameplay loop
        call clear #clears the window
        call initp #resets it (changing frame by frame)
        call current_obstacle
        call show_apples
        call cover
        movl $1, %edi
        shll $8, %edi
        call attron
        call get_level #gets current level
        movl %eax, %edi
        call level_print
        call get_score #gets score
        movl %eax, %edi
        call score_print
        call get_segments #gets segments
        movl %eax, %edi
        call segment_print 
        movl $1, %edi
        shll $8, %edi
        call attroff
        call get_collcheck #checks if a collision has occured. If so moves to end the game/do teardown.
        cmpl $1, %eax
        je end
        movq %r13, %rdi
        movl $2, %esi
        shll $8, %esi
        call wattron
        call draw_snake #draws the snake
        movq %r13, %rdi
        movl $2, %esi
        shll $8, %esi
        call wattroff
        movq %r13, %rdi
        movl $0, %esi
        movl $0, %edx
        movl $']', %ecx
        call mvwaddch
        movq %r13, %rdi
        call wrefresh
        call move_snek #moves the snake
        call flushinp
        call get_timedelay
        cmpl $0, %eax
        jle timefix
        jmp reg
end:
        call current_obstacle
        movq %r13, %rdi
        movl $2, %esi
        shll $8, %esi
        call wattron
        call draw_snake
        movq %r13, %rdi
        movl $2, %esi
        shll $8, %esi
        call wattroff
        movq %r13, %rdi
        movl $1, %esi
        shll $8, %esi
        call wattron
        movq %r13, %rdi
        movq $0, %rsi
        movq $29, %rdx
        leaq outro(%rip), %rcx
        call mvwprintw
        movq %r13, %rdi
        movl $1, %esi
        shll $8, %esi
        call wattroff
        movq %r13, %rdi
        movl $0, %esi
        movl $0, %edx
        movl $']', %ecx
        call mvwaddch
        movq %r13, %rdi
        call wrefresh
        movq $100, %rdi
        call napms
        call beep
        movq $100, %rdi #found needed delay for three beeps or only 1 would sound
        call napms #used napms
        call beep
        movq $100, %rdi
        call napms
        call beep
        movq $-1, %rdi #goes back into blocking mode
        call timeout
        call getch #waits for key before closing
        call endwin
        #end statistics
        call get_score
        movl %eax, %esi
        leaq endscore(%rip), %rdi
        call printf
        call get_segments
        movl %eax, %esi
        leaq endsegments(%rip), %rdi
        call printf
        call get_level
        movl %eax, %esi
        leaq endlevel(%rip), %rdi
        call printf
        pop %rbp
        ret 

timefix:
        movl $0, %edi
        call napms
        jmp game_loop
reg:
        call get_timedelay
        movl %eax, %edi
        call napms
        jmp game_loop
        