
from curses import endwin
import os
path = "./downscaled"
result = []
names = os.listdir(path)
print("{", end="")
for name in names:
	if(name.endswith('.bmp')):
		print("\"" + name + "\"", end=",")
print("}")