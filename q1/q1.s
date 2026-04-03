.globl make_node
make_node:
#right now, x10 contains val 
addi sp, sp, -16                    #allocating sufficient space on stack (must be a multiple of 16)
sd x1, 0(sp)                        #storing initial ra on stack

add x6, x0, x10                     #x6 contains val (since x10 will get overwritten)
addi x10, x0, 24
call malloc
#x10 now contains address of allocated space which is perfect because thats also what we want to return

sw x6, 0(x10)                       #storing val
sd x0, 8(x10)                       #storing left child as null
sd x0, 16(x10)                      #storing right child as null

ld x1, 0(sp)                        #restoring initial ra from stack
addi sp, sp, 16                     #restoring space on stack
jalr x0, 0(x1)                      #jump to initial ra


.globl insert
insert:
#right now, x10 contains root and x11 contains val
addi sp, sp, -16                    #allocating sufficient space on stack (must be a multiple of 16)
sd x1, 0(sp)                        #storing initial ra on stack
sd x10, 8(sp)                       #storing root on stack because we need to use x10 again (will get overwritten)

bne x10, x0, continue_insert        #branch to continue if root is not null
#this runs if root is null
add x10, x0, x11
jal x1, make_node
ld x1, 0(sp)                        #restoring initial ra from stack
addi sp, sp, 16                     #restoring space on stack
jalr x0, 0(x1)

continue_insert:
lw x5, 0(x10)                       #x5 now contains val of root
ble x11, x5, left_insert            #branch to left if val <= val of root

ld x10, 16(x10)                     #x10 now has addr of right child of node
jal x1, insert                      #call insert on right child of node with same val
ld x6, 8(sp)                        #x6 has root
sd x10, 16(x6)                      #store the above function calls return value as right child of node
jal x0, end_insert                  #jump to end_insert

left_insert:
ld x10, 8(x10)                      #x10 now has addr of left child of node
jal x1, insert                      #call insert on left child of node with same val
ld x6, 8(sp)                        #x6 has root
sd x10, 8(x6)                       #store the above function calls return value as left child of node

end_insert:
ld x1, 0(sp)                        #restoring initial ra from stack
ld x10, 8(sp)                       #restoring root from stack
addi sp, sp, 16                     #restoring space on stack
jalr x0, 0(x1)                      #jump to initial ra


.globl get
get:
#right now, x10 contains root and x11 contains val
addi sp, sp, -16                    #allocating sufficient space on stack (must be a multiple of 16)
sd x1, 0(sp)                        #storing initial ra on stack

bne x10, x0, continue               #branch to continue if root is not null
#this runs if root is null
add x10, x0, x0
# sd x1, 0(sp)                        #restoring initial ra from stack
addi sp, sp, 16                     #restoring space on stack
jalr x0, 0(x1)

continue:
lw x5, 0(x10)                       #x5 now contains val of root
bne x5, x11, continuefurther        #branch to continuefurther if val and val != val of root
#this runs if they are equal
addi sp, sp, 16                     #restoring space on stack
jalr x0, 0(x1)

continuefurther:
blt x11, x5, left                   #branch to left if val < val of root
#this runs if val > val of root
ld x10, 16(x10)                     #x10 now has addr of right child of node
jal x1, get                         #call get on right child of node with same val
jal x0, end                         #jump to end

left:
ld x10, 8(x10)                      #x10 now has addr of left child of node
jal x1, get                         #call get on left child of node with same val
jal x0, end                         #jump to end

end:
ld x1, 0(sp)                        #restoring initial ra from stack
addi sp, sp, 16                     #restoring space on stack
jalr x0, 0(x1)                      #jump to initial ra


.globl getAtMost
getAtMost:
#right now, x10 contains val and x11 contains root
add x5, x0, x0                      #x5 contains possible predecessors
whileloop:
beq x11, x0, endwhileloop           #branch to endwhileloop if root is equal to null
#this runs if root is not null
lw x6, 0(x11)                       #x6 now contains val of root
blt x10, x6, else                   #branch to else if val < val of root
add x5, x0, x11                     #mark root as a possible predecessor
beq x6, x10, endwhileloop           #branch to endwhileloop if val is equal to val of root
#this runs if val < val of root 
ld x11, 16(x11)                     #set root as roots right child to check for a larger predecessor
jal x0, whileloop                   #call whileloop again

else:
ld x11, 8(x11)                      #set root as roots left child to find a possible predecessor
jal x0, whileloop                   #call whileloop again

endwhileloop:
bne x5, x0, notnull                 #branch to notnull if x5 is not null
#this runs if not is null so we want to return -1
addi x10, x0, -1                    #set return val as -1
jalr x0, 0(x1)                      #jump to initial ra
notnull:
lw x10, 0(x5)                       #x5 will now contain the answer, set it as the return val
jalr x0, 0(x1)                      #jump to initial ra
