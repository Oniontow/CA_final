.globl __start

.rodata
    msg0: .string "This is HW1-2: Longest Substring without Repeating Characters\n"
    msg1: .string "Enter a string: "
    msg2: .string "Answer: "
.text

# Please use "result" to print out your final answer
################################################################################
# result function
# Usage: 
#     1. Store the beginning address in t4
#     2. Use "j print_char"
#     The function will print the string stored t4
#     When finish, the whole program will return value 0
result:
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    add a1, x0, t4
    ecall
# Ends the program with status code 0
    addi a0, x0, 10
    ecall
################################################################################

__start:
# Prints msg
    addi a0, x0, 4
    la a1, msg0
    ecall
    
    la a1, msg1
    ecall
    
    addi a0, x0, 8
    
    li a1, 0x10200
    addi a2, x0, 2047
    ecall
# Load address of the input string into a0
    add a0, x0, a1

################################################################################
# DO NOT MODIFY THE CODE ABOVE
################################################################################  
# Write your main function here. 
# a0 stores the beginning address (66048(0x10200)) of the  Plaintext
li s0, 0x10600          # t4 = [] final answer
li s1, 0x11000          # t5 = [] hash table
main:
    mv t0, a0           # Load address of a0 to t0
    li t1, 0            # left = 0
    li t2, 0            # final_left = 0
    li t3, 0            # final_i = 0
    li t4, 0            # length = 0

loop_outer:
    lb t5, 0(t0)        # Load byte from a0[left]
    beqz t5, end_outer  # If a0[left] == 0, break
    mv t6, t1           # i = left
    
loop_inner:
    add a7, t0, t6      # find address of a0[i]
    lb a2, 0(a7)        # Load byte from a0[i]
    beqz a2, break_inner  # If a0[i] == 0, break

    mv a3, s1           # Load address of hashtable
    add a4, a3, a2      # hashtable[a0[i]]
    lb a5, 0(a4)       # Load value from hashtable[a0[i]]
    bnez a5, break_inner # If hashtable[a0[i]] != 0, break

    sb zero, 0(a4)      # hashtable[a0[i]] = 0
    addi t6, t6, 1      # i += 1
    j loop_inner

break_inner:
    sub a6, t6, t1     # new_length = i - left
    addi a6, a6, 1    # new_length += 1
    blt t4, a6, update_length # if new_length > length, update

    j reset_hashtable

update_length:
    mv t4, a6      # length = new_length
    mv t2, t1   # final_left = left
    mv t3, t6      # final_i = i

reset_hashtable:
    mv a3, s1           # Load address of hashtable
    mv t6, t1           # i = left
    add t6, t6, a0
reset_loop:
    lb a2, 0(t6)        # Load byte from a0[i]
    beqz a2, end_reset  # If a0[i] == 0, break
    add a4, a3, a2      # hashtable[a0[i]]
    sb zero, 0(a4)      # hashtable[a0[i]] = 0
    addi t6, t6, 1      # i += 1
    j reset_loop

end_reset:
    addi t1, t1, 1      # left += 1
    addi t0, t0, 1      # Move pointer to next character
    j loop_outer

end_outer:
    # t4 = length of longest substring
    # Final substring is from a0[final_left] to a0[final_left + length]
    mv t4, s0           #copy the address of ans to t4
    mv t0, t4           #copy the start point of t4 to t0
answerloop:
    bgt t2, t3, result  #if left <= i
    add t6, a0, t2      #find a0[left]
    lb t1, 0(t6)        #load a0[left] to t1
    sb t1, 0(t0)        #save a0[left] to t4[index]
    addi t0, t0, 1      #index++
    addi t2, t2, 1      #left++
    beq x0, x0, answerloop
    
  