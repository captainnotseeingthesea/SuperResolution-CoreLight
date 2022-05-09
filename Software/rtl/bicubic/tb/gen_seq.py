
width=11
height=6  
f = open("display_test_backup.txt")
result = []
for line in f.readlines():
    result.append(line.strip())
f.close()

result.pop(0)

while len(result) != width*height*4:
    result.pop()


des = []
for i in range(height):
    for j in range(width):
        des.append(result[4*width*i+ j*4+0])
    for j in range(width):
        des.append(result[4*width*i+ j*4+1])
    for j in range(width):
        des.append(result[4*width*i+ j*4+2])
    for j in range(width):
        des.append(result[4*width*i+ j*4+3])

for t in range(len(des)):
    print(des[t])

