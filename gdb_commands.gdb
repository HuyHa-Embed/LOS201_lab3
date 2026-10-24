set pagination off
set debuginfod enabled off
set confirm off
set print pretty on
set architecture arm
set sysroot /home/huy/embedded_lab3/rootfs/initramfs
set can-use-hw-watchpoints 0
file /home/huy/embedded_lab3/apps/buggy_app
target remote localhost:1234
info registers pc sp lr
break main
break process_data
break create_message
break calculate
info breakpoints
continue
echo \n--- Dung tai main ---\n
backtrace
info locals
next
next
next
next
print arr
print arr[0]@5
print &arr[5]
continue
echo \n--- BUG 1: process_data (array out-of-bounds) ---\n
backtrace
info args
print *data@5
print len
break 9 if i == len
continue
echo \n--- Dung khi i == len (truy cap data[5]) ---\n
backtrace
print i
print len
print &data[i]
print data[i]
print &data[0]
print data[i-1]
x/8dw data
info registers
watch sum
continue
echo \n--- watchpoint: sum bi ghi de boi data[5] rac ---\n
print sum
print i
delete 6
echo \n--- Sua bug luc runtime: khoi phuc sum, ep len=4 de vong lap dung o i=4 ---\n
set variable sum = 150
set variable len = 4
delete 5
finish
echo \n--- BUG 2: create_message (use after free) ---\n
continue
backtrace
info args
next
next
echo \n--- Truoc free(buf): buf tro toi vung heap hop le ---\n
print buf
x/s buf
next
echo \n--- Sau free(buf): con tro buf van giu dia chi cu (dangling pointer) ---\n
print buf
x/s buf
x/24xb buf
echo \n--- sau free(buf): vung nho da tra lai heap, noi dung bi ghi de (tcache) ---\n
info registers pc sp lr
x/10xw $sp
continue
echo \n--- BUG 3: calculate (integer overflow) ---\n
backtrace
info args
next
print result
print/x result
print (long long)a * b
print/x (long long)a * b
disassemble
info registers
continue
