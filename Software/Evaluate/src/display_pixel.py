from PIL import Image

f = open("o.txt", "w")
img = Image.open('../upscaled/0.bmp')
rgb_img = img.convert("RGB")

""" Generate the memory map for bmp """
# list = []
# for i in range(img.height):
#     for j in range(img.width):
#         r, g, b = rgb_img.getpixel((j, i))
#         list.append('{:02X}'.format(b))
#         list.append('{:02X}'.format(g))
#         list.append('{:02X}'.format(r))
    
# print("memory_initialization_radix=16;", file=f)
# print("memory_initialization_vector=", file=f)
# for i in range(len(list) // 8):
#     str = ""
#     for ch in reversed(list[8 * i: 8 * i + 8]):
#         str += ch
#     print(str + ',', file=f)

str = ""
for i in range(img.height):
    for j in range(img.width):
        str = ""
        r, g, b = rgb_img.getpixel((j, i))
        str += '{:02X}'.format(r) + '{:02X}'.format(g) + '{:02X}'.format(b)
        print(str, file=f)
