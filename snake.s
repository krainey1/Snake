#snake.s
#the snake functions 

.section .data
level: .int 1
score: .int 0
length: .int 4
acount: .int 4
collon: .int 0
opcount: .int 0
covercounter: .int 0
applecounter: .int 0
x: .int 40
y: .int 11
timedelay: .int 300
xcor: .space 320 
ycor: .space 320
cxcor: .space 400 #cover arrays
cycor: .space 400 #cover arrays
curr_dir: .byte 'k'

.section .text
.global draw_snake
.global move_snek
.global dummy_snake
.global get_score
.global get_level
.global get_segments
.global get_collcheck
.global cur_apples
.global cover
.global get_opcount
.global get_timedelay

draw_snake:
        push %rbp
        movl $0, %r12d  # Start body segment counter
        movl length(%rip), %r14d  # Total length of snake

draw_head:
        # Draw head
        movq %r13, %rdi
        movl y(%rip), %esi 
        movl x(%rip), %edx
        movl $'O', %ecx
        call mvwaddch

draw_body:
        # Increment body segment counter
        incl %r12d
        
        # Check if we've drawn all segments
        cmpl %r14d, %r12d
        jg end_draw

        # Use coordinates for body segments
        movq %r13, %rdi
        movl ycor(, %r12d, 4), %esi
        movl xcor(, %r12d, 4), %edx
        movl $'*', %ecx
        call mvwaddch

        # Continue drawing body 
        jmp draw_body

end_draw:
        movq %r13, %rdi
        call wrefresh
        pop %rbp
        ret

move_snek: 
        push %rbp
        movl length, %r14d
        decl %r14d
        call getch
        movl %eax, %r12d
        

        cmpl $-1, %r12d
        je nokey

        # Shift body segments 
        cmpl $0, %r14d
        jle change_head
shift_start:
        # Shift body segments
        movl %r14d, %ecx
shift_loop:
        movl xcor-4(, %ecx, 4), %eax
        movl %eax, xcor(, %ecx, 4)
        movl ycor-4(, %ecx, 4), %eax
        movl %eax, ycor(, %ecx, 4)
        decl %ecx
        jnz shift_loop
        jmp change_head
nokey:
        movl curr_dir, %r12d
        jmp shift_start
change_head:
        # Handle movement based on key press
        cmpl $'k', %r12d
        je right
        cmpl $'j', %r12d
        je left
        cmpl $'i', %r12d
        je up
        cmpl $'m', %r12d
        je down
        jmp nokey

change_head_nokey:
        # Handle movement based on no key press
        movl curr_dir(%rip), %r12d
        cmpl $'k', %r12d
        je right
        cmpl $'j', %r12d
        je left
        cmpl $'i', %r12d
        je up
        cmpl $'m', %r12d
        je down
        jmp end_snek

right:  
        movb $'j', %al #illegal move check, cant move right when left
        cmpb curr_dir(%rip), %al
        je change_head_nokey
        movb $'k', curr_dir(%rip)
        incl x(%rip)  # Move right
        jmp scoring

left:   
        movb $'k', %al #illegal move check, cant move left when right
        cmpb curr_dir(%rip), %al
        je change_head_nokey
        movb $'j', curr_dir(%rip)
        decl x(%rip)  # Move left
        jmp scoring

up:     
        movb $'m', %al #illegal move check, cant move up when down
        cmpb curr_dir(%rip), %al
        je change_head_nokey
        movb $'i', curr_dir(%rip)
        decl y(%rip)  # Move up 
        jmp scoring

down:   
        movb $'i', %al #illegal move check, cant move down when up
        cmpb curr_dir(%rip), %al
        je change_head_nokey #will continue moving in the previous direction, ignoring key change
        movb $'m', curr_dir(%rip)
        incl y(%rip)  # Move down
        jmp scoring
#illegal move checks result in snake moving in its current direction, ignoring the key
scoring:
        movl x(%rip), %r8d
        movl y(%rip), %r9d
        movq %r13, %rdi
        movl %r9d, %esi
        movl %r8d, %edx
        call mvwinch
        cmpl $64, %eax
        je scoreup
        jmp collision
scoreup:
        call beep
        call get_level
        addl %eax, score(%rip) #increase score by adding level
        incl length(%rip) #increase segments
        movl x(%rip), %r8d #put coordinate to cover in cover arrays
        movl y(%rip), %r9d
        movl covercounter(%rip), %r12d
        movl %r8d, cxcor(, %r12d, 4)
        movl %r9d, cycor(, %r12d, 4)
        incl covercounter(%rip) #increase cover element counter
        incl applecounter(%rip)
        movl $6, %eax
        subl %eax, timedelay(%rip)
        movl acount(%rip), %r8d
        movl applecounter(%rip), %r9d
        cmpl %r9d, %r8d
        je level_set
        jmp update_head
level_set:
        call beep
        incl level(%rip)
        incl acount(%rip)
        incl opcount(%rip)
        movl $0, applecounter(%rip)
        call place_obstacle
        call generate_apples
        jmp update_head
collision:
        movl x(%rip), %r8d
        movl y(%rip), %r9d
        cmpl $2, %r8d
        jl collset
        cmpl $78, %r8d
        jge collset
        cmpl $2, %r9d
        jl collset
        cmpl $22, %r9d
        jge collset
        movq %r13, %rdi
        movl %r9d, %esi
        movl %r8d, %edx
        call mvwinch
        cmpl $88, %eax
        je collset
        cmpl $42, %eax
        je collset
        jmp update_head
update_head:
        # Update head position in coordinate arrays
        movl x(%rip), %eax
        movl %eax, xcor(%rip)
        movl y(%rip), %eax
        movl %eax, ycor(%rip)
        jmp end_snek
collset:
        movl $1, collon(%rip)
end_snek: 
        pop %rbp
        ret

dummy_snake: #the first frame snake because we need that 
        push %rbp
        movq %r13, %rdi
        movl $11, %esi 
        movl $40, %edx
        movl $'O', %ecx
        call mvwaddch

        movq %r13, %rdi
        movl $11, %esi 
        movl $39, %edx
        movl $'*', %ecx
        call mvwaddch

        movq %r13, %rdi
        movl $11, %esi 
        movl $38, %edx
        movl $'*', %ecx
        call mvwaddch

        movq %r13, %rdi
        movl $11, %esi 
        movl $37, %edx
        movl $'*', %ecx
        call mvwaddch
        pop %rbp
        ret 

#helper functions that grab score, level, and segments

get_score:
        movl score(%rip), %eax
        ret

get_level: 
        movl level(%rip), %eax
        ret 

get_segments: 
        movl length(%rip), %eax
        ret

get_collcheck:
        movl collon(%rip), %eax
        ret

cur_apples:
        movl acount(%rip), %eax
        ret

cover: 
        movl $0, %r12d
cover_loop:
        cmpl %r12d, covercounter
        jl end_cover
        movq %r13, %rdi
        movl cycor(, %r12d, 4), %esi
        movl cxcor(, %r12d, 4), %edx
        movl $' ', %ecx
        call mvwaddch
        incl %r12d
        jmp cover_loop
end_cover:
        ret

get_opcount:
        movl opcount(%rip), %eax
        ret
get_timedelay:
        movl timedelay(%rip), %eax
        ret
