.globl __start

.rodata
    msge: .string "\n "
    msg0: .string "This is HW1-1: Extended Euclidean Algorithm\n"
    msg1: .string "Enter a number for input x: "
    msg2: .string "Enter a number for input y: "
    msg3: .string "The result is:\n "
    msg4: .string "GCD: "
    msg5: .string "a: "
    msg6: .string "b: "
    msg7: .string "inv(x modulo y): "

.text
################################################################################
  # You may write function here

    
    
################################################################################
__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads int1
    addi a0, x0, 5
    ecall
    add t0, x0, a0
    
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall
    
  # Reads int2
    addi a0, x0, 5
    ecall
    add a1, x0, a0
    add a0, x0, t0
    addi t0, x0, 0
    
################################################################################ 
  # You can do your main function here
    addi x5, x0, 1 #int t = 1
    addi x20, a0, 0 #x20 = m
    addi x21, a1, 0 #x21 = n
while:
    beq x5, x0, returngcd
    div x6, x20, x21  #x6 = m/n
    mul x6, x6, x21
    sub x5, x20, x6  #t = m-(m/n)*n=m%n
    addi x20,x21, 0  #m = n
    addi x21, x5, 0  #n = t
    beq x0, x0, while
returngcd:
    addi s0, x20, 0  #return m 

addi sp, sp, -8
sw a0, 0(sp)
sw a1, 4(sp)

ext_euclid:
# Initialize registers
addi s1, zero, 1      # old_s = 1
addi s2, zero, 0      # old_t = 0
addi s3, a0, 0        # old_r = a
addi t0, zero, 0      # s = 0
addi t1, zero, 1      # t = 1
addi t2, a1, 0        # r = b

# Check if b == 0
beq a1, zero, return_initial

loop:
beq t2, zero, end_loop  # while r != 0

# q = old_r // r
div t3, s3, t2

# old_r, r = r, old_r - q * r
mul t4, t3, t2
sub t4, s3, t4
mv s3, t2
mv t2, t4

# old_s, s = s, old_s - q * s
mul t4, t3, t0
sub t4, s1, t4
mv s1, t0
mv t0, t4

# old_t, t = t, old_t - q * t
mul t4, t3, t1
sub t4, s2, t4
mv s2, t1
mv t1, t4

j loop

end_loop:
mv a0, s1  # return old_s
mv a1, s2  # return old_t
mv a2, s3  # return old_r


return_initial:
addi a0, zero, 1  # return 1
addi a1, zero, 0  # return 0
mv a2, s3         # return a


lw a0, 0(sp)
lw a1, 4(sp)
addi sp, sp, 8

part3:

addi t0, x0, 1
addi s3, x0, 0
bne s0, t0, result
bge s1, x0, situation1
mv s3, s1
add s3, s3, a1
beq x0, x0, result


situation1:  # a > 0
mv s3, s1
beq x0, x0, result



    
    
################################################################################

result:
    addi t0,a0,0
  # Prints msg
    addi a0, x0, 4
    la a1, msg3
    ecall
    
    addi a0, x0, 4
    la a1, msg4
    ecall

  # Prints the result in s0
    addi a0, x0, 1
    add a1, x0, s0
    ecall
    
    addi a0, x0, 4
    la a1, msge
    ecall
    addi a0, x0, 4
    la a1, msg5
    ecall
    
  # Prints the result in s1
    addi a0, x0, 1
    add a1, x0, s1
    ecall
    
    addi a0, x0, 4
    la a1, msge
    ecall
    addi a0, x0, 4
    la a1, msg6
    ecall
    
  # Prints the result in s2
    addi a0, x0, 1
    add a1, x0, s2
    ecall
    
    addi a0, x0, 4
    la a1, msge
    ecall
    addi a0, x0, 4
    la a1, msg7
    ecall
    
  # Prints the result in s3
    addi a0, x0, 1
    add a1, x0, s3
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall