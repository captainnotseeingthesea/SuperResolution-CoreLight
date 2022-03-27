
width=960
height=540

f = open("display_verilator.txt")
result = []
cnt = 0
for line in f.readlines():
    result.append(line.strip())
f.close()

# if use iverilog, the first line should be poped
# result.pop(0)

while len(result) != width*height*4:
    result.pop()
# print(result)


des = []
for i in range(height):
    for j in range(width):
        des.append(result[i*width*4 + j*4])
    for j in range(width):
        des.append(result[i*width*4 + j*4+1]) 
    for j in range(width):
        des.append(result[i*width*4 + j*4+2])
    for j in range(width):
        des.append(result[i*width*4 + j*4+3])


res = []
t=""
for i in range(4*height):
    for j in range(width):
        t=t+des[i*width+j]
    res.append(t)
    t=""

# print(res[0])
# print(res[1])


des=[]
for i in range(4*height):
    des.append(res[4*height-i-1])


f = open("49_1k.bmp","rb")
head = f.read(18)
f.seek(f.tell()+8)
tail = f.read(28)
# body = f.read(2)
f.close()

import struct
test = open("49_4k.bmp","wb+")
test.write(struct.pack('B',head[0]))
test.write(struct.pack('B',head[1]))
test.write(struct.pack('i',54+4*4*width*height*3))
for i in range(18-6):
    test.write(struct.pack('B',head[6+i]))
test.write(struct.pack('i', width*4))
test.write(struct.pack("i", height*4))
for i in range(28):
    test.write(struct.pack('B', tail[i]))


# print(int(t[0*2:0*2+2],16))
# test.write(struct.pack('B', int(t[0*2:0*2+1],16)))
for i in range (len(des)):
    t = des[i]
    for j in range (12*width):
        test.write(struct.pack('B', int(t[j*2:j*2+2],16)))
test.close()
print("the result is in 49_4k.bmp")

