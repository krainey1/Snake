#playfield.s
#initialize play area

.section .data
levelf: .string "Level %d"
score: .string "Score %d"
segments: .string "%d Segments"
oxcor: .space 200
oycor: .space 200
axcor: .space 200
aycor: .space 200

.section .text
.global initp
.global level_print
.global score_print
.global segment_print
.global place_obstacle
.global current_obstacle
.global generate_apples
.global show_apples


initp: 
        push %rbp
        call cbreak #disable line buffering
        call noecho #dont echo character
        #call use_default_colors
        #call start_color #my terminal defaults to cyan/white when color is started

        #movq $1, %rdi
        #movq $1, %rsi
        #movq $7, %rdx
        #call init_pair
        


        movq $23, %rdi #setting up window for play area/height
        movq $80, %rsi #width
        movq $1, %rdx
        movq $0, %rcx
        call newwin
        #should return pointer to a new window %rax
        movq %rax, %r13
        call refresh
        #setting up border
        movq %r13, %rdi
        movq $']', %rsi
        movq $'[', %rdx
        movq $'=', %rcx
        movq $'=', %r8
        movq $']', %r9
        push $'['
        push $']' 
        push $'['
        call wborder #creates window border
        addq $24, %rsp
        movq %r13, %rdi
        call wrefresh
        pop %rbp
        ret

level_print:
        push %rbp
        movl %edi, %ebx
        movq $0, %rdi
        movq $0, %rsi
        leaq levelf(%rip), %rdx
        movl %ebx, %ecx
        call mvprintw
        pop %rbp
        ret

score_print:
        push %rbp
        movl %edi, %ebx
        movq $0, %rdi
        movq $37, %rsi
        leaq score(%rip), %rdx
        movl %ebx, %ecx
        call mvprintw
        pop %rbp
        ret

segment_print:
        push %rbp
        movl %edi, %ebx
        movq $0, %rdi
        movq $65, %rsi
        leaq segments(%rip), %rdx
        movl %ebx, %ecx
        call mvprintw
        pop %rbp
        ret

place_obstacle:
        call get_opcount
        movl %eax, %r12d
        call rand
        movl $76, %ebx
        idiv %ebx
        incl %edx
        incl %edx
        movl %edx, oxcor(, %r12d, 4)
        call rand
        movl $19, %ebx
        idiv %ebx
        incl %edx
        incl %edx
        movl %edx, oycor(, %r12d, 4)
        movq %r13, %rdi
        movl oycor(, %r12d, 4), %esi
        movl oxcor(, %r12d, 4), %edx
        call mvwinch
        cmpl $79, %eax
        je place_obstacle
        cmpl $42, %eax
        je place_obstacle
        cmpl $88, %eax
        je place_obstacle
        movq %r13, %rdi
        movl oycor(, %r12d, 4), %esi
        movl oxcor(, %r12d, 4), %edx
        movl $'X', %ecx
        call mvwaddch
        ret

current_obstacle:
        call get_opcount
        movl %eax, %r12d
        movl $0, %r8d
o_loop:
        cmpl $0, %r12d
        jl endo
        movq %r13, %rdi
        movl oycor(, %r12d, 4), %esi
        movl oxcor(, %r12d, 4), %edx
        movl $'X', %ecx
        call mvwaddch
        decl %r12d
        jmp o_loop
endo:
        ret

generate_apples:
        call cur_apples
        movl %eax, %r12d
        decl %r12d
        #coordinate generation
cor_gen:
        cmpl $0, %r12d
        jl endapples
        call rand
        movl $76, %ebx
        idiv %ebx
        incl %edx
        incl %edx
        movl %edx, %r14d
        call rand
        movl $19, %ebx
        idiv %ebx
        incl %edx
        incl %edx
        movl %edx, %r15d
        movq %r13, %rdi
        movl %r14d, %esi
        movl %r15d, %edx
        call mvwinch
        cmpl $79, %eax #dont spawn on snake head
        je cor_gen
        cmpl $42, %eax #segment
        je cor_gen
        cmpl $88, %eax #obstacle
        je cor_gen
        cmpl $64, %eax #another apple
        je cor_gen
        movl %r14d, axcor(, %r12d, 4)
        movl %r15d, aycor(, %r12d, 4)
        decl %r12d
        jmp cor_gen
endapples: 
        ret

show_apples: 
        call cur_apples
        movl %eax, %r12d
        decl %r12d
apple_loop:
        cmpl $0, %r12d
        jl end_adraw
        movq %r13, %rdi
        movl aycor(, %r12d, 4), %esi
        movl axcor(, %r12d, 4), %edx
        movl $'@', %ecx
        call mvwaddch
        movq %r13, %rdi
        decl %r12d
        jmp apple_loop
end_adraw:
        ret


        