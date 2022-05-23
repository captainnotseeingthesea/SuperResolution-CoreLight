
# width=11
# height=6
# f = open("display.txt")

width=960
height=540
f = open("display_verilator.txt")

# width=48
# height=27
# f = open("display.txt")

result = []
for line in f.readlines():
    result.append(line.strip())
f.close()

# If use iverilog, the first line should be poped
# result.pop(0)

if(len(result) != (width+1)*height*4):
    print("error len")

while len(result) != (width+1)*height*4:
    result.pop()


# merge the extra pixel into one row
des = []
for i in range(4*height):
    string_t = ""
    for j in range(width+1):
        string_t += result[(width+1)*i+j]
    des.append(string_t)

# reverse
# t = des
# des = []
# for i in range(4*height):
#     des.append(t[4*height-i-1])

# print(des[0])

# f = open("2.bmp","rb")
f = open("49_1k.bmp","rb")
# f = open("4.bmp","rb")
head = f.read(18)
f.seek(f.tell()+8)
body = f.read(8)
f.seek(f.tell()+4)
tail = f.read(16)

f.seek(f.tell()+8)
f.close()

import struct
# test = open("2_4k.bmp","wb+")
test = open("49_4k.bmp","wb+")
# test = open("4_4k.bmp","wb+")
test.write(struct.pack('B', head[0]))
test.write(struct.pack('B', head[1]))
test.write(struct.pack('i', 54+4*4*width*height*3))
for i in range(18-6):
    test.write(struct.pack('B',head[6+i]))
test.write(struct.pack('i', width*4))
test.write(struct.pack("i", height*4))
for i in range(8):
    test.write(struct.pack('B', body[i]))    
test.write(struct.pack('i', 4*4*width*height*3))
for i in range(16):
    test.write(struct.pack('B', tail[i]))

for i in range (len(des)):
    t = des[i]
    for j in range (4*width):
        test.write(struct.pack('B', int(t[(j+1)*6-2:(j+1)*6],16)))
        test.write(struct.pack('B', int(t[(j+1)*6-4:(j+1)*6-2],16)))
        test.write(struct.pack('B', int(t[(j+1)*6-6:(j+1)*6-4],16)))

test.close()
print("the result is valid")
