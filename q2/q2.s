.section .rodata
                     
space:                             #defining space string
.string " "
numfmt:                            #defining the number format
.string "%lld"                    
newline:
.string "\n"

.section .text

.globl main
main:
#right now, x10 has number of args and x11 has array of args as strings
addi sp, sp, -48                    #allocating sufficient space on stack (must be a multiple of 16)
sd x1, 0(sp)                        #storing initial ra on stack
sd x18, 8(sp)                       #storing old value of x18 on stack since x18 is a saved register
sd x19, 16(sp)                      #storing old value of x19 on stack since x19 is a saved register
sd x20, 24(sp)                      #storing old value of x20 on stack since x20 is a saved register
sd x21, 32(sp)                      #storing old value of x21 on stack since x21 is a saved register

addi x21, x11, 0                    #x21 stores array of args as strings (input)
addi x18, x10, -1                   #x18 now contains n-1 and is the new n since we want to ignore first arg
slli x10, x18, 3                    #x10 now stores 8*n since each long long int takes 8 bytes                   
call malloc                         #allocating that much space
add x20, x0, x10

#x20 will store the output array from now on
add x5, x0, x0                      #x5 stores the iterator i=0
initforloop:                        #for loop to init output array to all -1
bge x5, x18, endinitforloop         #branch to endinitforloop if i>=n
slli x6, x5, 3                      #x6 now contains 8*i since each long long int takes 8 bytes
add x6, x6, x20                     #x6 now contains addr of output[i]
addi x7, x0, -1
sd x7, 0(x6)                        #set output[i] to -1
addi x5, x5, 1                      #increment iterator
jal x0, initforloop                 #call initforloop again

endinitforloop:

addi x31, x0, 45                    #x31 stores the ascii value of the '-' sign 
addi x5, x0, 0                      #x5 stores the iterator i=0
forloop:                            #forloop that converts each str to int
bge x5, x18, endforloop             #branch to endforloop if i>=n
#this runs if i<n
addi x6, x5, 1                      #using i+1 to skip first arg (executable name)
addi x29, x0, 1                     #stores sign
slli x6, x6, 3                      #x6 now contains 8*i since each ptr is 8 bytes
add x6, x6, x21                     #x6 now contains ptr to str[i]
ld x6, 0(x6)                        #x6 now contains addr of str[i]

add x19, x0, x0                     #x19 will store the int that str[i] represents so init to 0
add x7, x0, x0                      #x7 stores the iterator j=0
whileloop:
add x28, x6, x7                     #x28 now contains the addr of str[i][j]
lb x28, 0(x28)                      #x28 now contains the val at str[i][j]
beq x28, x0, endwhileloop           #branch to endwhileloop if you reached the ending nullchar
bne x28, x31, notneg                #branch to notneg if str[i][j] is not equal to '-'
#this runs if number is negative
addi x29, x0, -1                    #set sign to -
addi x7, x7, 1                      #increment iterator j
jal x0, whileloop                   #continue whileloop
notneg:
addi x28, x28, -48                  #x28 now contains correct numerical value since ascii value of '0' is 48
addi x30, x0, 10
mul x19, x19, x30                   #x19 = 10 * x19
add x19, x19, x28                   #x19 = x19(all previous digits) + x28(last digit)
addi x7, x7, 1                      #increment iterator j
jal x0, whileloop                   #call whileloop again

endwhileloop:
mul x19, x19, x29                   #set the correct sign of the numerical value 
slli x30, x5, 3                     #x30 now contains 8*i since each ptr is 8 bytes
add x30, x30, x21                   #x30 now contains ptr to str[i]
sd x19, 0(x30)                      #overwrite the memory location of str[i] with the int value of str[i]
addi x5, x5, 1                      #increment iterator i
jal x0, forloop

endforloop:
#now x20 stores output array, x21 stores input integer array, x18 stores n, all others can be reused (x5,x6,x7,x19,x20,x28,x29,x30,x31)
add x31, sp, x0                     #x31 contains old sp
addi x28, x0, -8
mul x28, x28, x18
add sp, sp, x28                     #using stack space to implement stack in algorithm (reffered to as s from now). note that the bottom of the stack is the old sp.
add x29, x0, x31                    #x29 will represent the top of s

addi x5, x18, -1                    #x5 stores the iterator i=n-1
ngeforloop:
blt x5, x0, endngeforloop           #branch to endngeforloop if i<0

ngewhileloop:
beq x29, x31, endngewhileloop       #branch to endngewhileloop if s is empty
#this runs if s is not empty
ld x6, 0(x29)                       #x6 now stores value of top elem in s
slli x6, x6, 3                      #x6 now contains 8*s[top] since each long long int in arr is 8 bytes
add x6, x6, x21                     #x6 now contains addr of arr[s[top]]
ld x6, 0(x6)                        #x6 now contains value at arr[s[top]
slli x7, x5, 3                      #x7 now contains 8*i since each long long int in s is 8 bytes
add x7, x7, x21                     #x7 now contains addr of arr[i]
ld x7, 0(x7)                        #x7 now contains value at arr[i]
bgt x6, x7, endngewhileloop         #branch to endngewhileloop if arr[s[top]] > arr[i]
#this runs when arr[s[top]] <= arr[i]
addi x29, x29, 8                    #pop top elem off s
jal x0, ngewhileloop                #call ngewhileloop again

endngewhileloop:
beq x29, x31, noresult              #branch to noresult if s is empty
#this runs if s is not empty
slli x7, x5, 3                      #x7 now contains 8*i since each long long int in output is 8 bytes
add x7, x7, x20                     #x7 now contains addr of output[i]
ld x6, 0(x29)                       #x6 now stores value of top elem in s
sd x6, 0(x7)                        #output[i] is now set to value of top elem in s

noresult:
addi x29, x29, -8                   #move top to make space for i to be added to s
sd x5, 0(x29)                       #s now has i added to it (push i onto s)
addi x5, x5, -1                     #decrement iterator i
jal x0, ngeforloop                  #call ngeforloop again

endngeforloop:
addi x28, x0, 8
mul x28, x28, x18
add sp, sp, x28                     #restoring stack space used to store s

add x19, x0, x0                     #x19 stores the iterator i=0
printforloop:                       #for loop to print output arr
bge x19, x18, endprintforloop       #branch to endprintforloop if i>=n
#this runs if i<n
beq x19, x0, skipspace              #skip printing space if i==0
lla x10, space                      #print space before element
call printf

skipspace:
lla x10, numfmt                     #print the number
slli x6, x19, 3                     #x6 now contains 8*i since each long long int takes 8 bytes
add x6, x6, x20                     #x6 now contains addr of output[i]
ld x11, 0(x6)                       #x11 now contains value of output[i]
call printf                         #print output[i]

addi x19, x19, 1                    #increment iterator
jal x0, printforloop                #call printforloop again

endprintforloop:
lla x10, newline
call printf                         #print newline char

ld x21, 32(sp)                      #restoring old value of x21 from stack
ld x20, 24(sp)                      #restoring old value of x20 from stack
ld x19, 16(sp)                      #restoring old value of x19 from stack
ld x18, 8(sp)                       #restoring old value of x18 from stack
ld x1, 0(sp)                        #restoring initial ra from stack
addi sp, sp, 48                     #restoring space on stack
add x10, x0, x0                     #setting return value to 0
jalr x0, 0(x1)                      #jump to initial ra
