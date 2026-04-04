.section .rodata

infilepath:                         #defining the input format
.string "input.txt"
outfmt:                             #defining the output format
.string "%s\n"
yes:
.string "Yes"
no:
.string "No"

.section .text

.globl main
main:
add sp, sp, -32                     #allocating sufficient space on stack (must be a multiple of 16)
sd x1, 0(sp)                        #storing initial ra on stack
sd x9, 8(sp)                        #storing old value of x9 on stack since x21 is a saved register

addi x17, x0, 56                    #set sys call num as 56 which corresponds to openat
addi x10, x0, -100                  #telling the os to look in the curr dir
lla x11, infilepath                 
add x12, x0, x0                     #setting to read only    
ecall                               
add x9, x0, x10                     #x9 now contains fd (file descriptor)
addi x5, sp, 8                      #addr in x5 contains start of string

addi x17, x0, 62                    #set sys call num as 62 which corresponds to lseek
add x10, x0, x9                     #giving the fd
add x11, x0, x0                     #setting offset to 0
addi x12, x0, 2                     #measured from end of file    
ecall                               
add x7, x0, x10                     #x7 contains the length
addi x7, x7, -1                     #x7 will now store the rp 

add x6, x0, x0                      #x6 stores the lp
whileloop2:
blt x7, x6, endwhileloop2           #branch to end if lp crosses rp

#move cursor to rp
addi x17, x0, 62                    #set sys call num as 62 which corresponds to lseek
add x10, x0, x9                     #giving the fd
add x11, x0, x7                     #setting offset to rp
add x12, x0, x0                     #measured from start of file    
ecall
#read for str[rp]                               
addi x17, x0, 63                    #set sys call num as 63 which corresponds to read
add x10, x0, x9                     #giving the fd
addi x11, sp, 16                    #location on stack where read value will be stored
addi x12, x0, 1                     #since we want to read 1 byte   
ecall
lb x28, 16(sp)                      #x28 now contains str[rp]

#move cursor to lp
addi x17, x0, 62                    #set sys call num as 62 which corresponds to lseek
add x10, x0, x9                     #giving the fd
add x11, x0, x6                     #setting offset to lp
add x12, x0, x0                     #measured from start of file    
ecall
#read for str[lp]                               
addi x17, x0, 63                    #set sys call num as 63 which corresponds to read
add x10, x0, x9                     #giving the fd
addi x11, sp, 16                    #location on stack where read value will be stored
addi x12, x0, 1                     #since we want to read 1 byte   
ecall
lb x29, 16(sp)                      #x29 now contains str[lp]

sub x30, x29, x28                   
bne x30, x0, break                  #branch to break if str[lp] and str[rp] are not equal
addi x7, x7, -1                     #decrement rp
addi x6, x6, 1                      #increment lp
jal x0, whileloop2                  #call whileloop2 again

break:                              #this runs when string is not palindrome
lla x10, outfmt
lla x11, no
call printf                         #print No
jal x0, finish                      #jump to finish

endwhileloop2:                      #occurs when string is palindrome
lla x10, outfmt
lla x11, yes
call printf                         #print Yes    
jal x0, finish                      #jump to finish

finish:
addi x17, x0, 57                    #set sys call num as 57 which corresponds to close
add x10, x0, x9                     #giving the fd
ecall 
ld x9, 8(sp)                        #restoring old value of x18 from stack
ld x1, 0(sp)                        #restoring initial ra from stack
addi sp, sp, 32                     #restoring space on stack
add x10, x0, x0                     #setting return value to 0
jalr x0, 0(x1)                      #jump to initial ra
