
from PIL import Image 

def addTransparency(img, factor=0.99):
    img = img.convert('RGBA')
    img_blender = Image.new('RGBA', img.size, (0,0,0,0))
    img = Image.blend(img_blender, img, factor)
    return img

# def downSample(img):
#     img1 = img.resize((img.width//2, img.height//2))
#     return img1



for i in range(21):
    img = Image.open(str(i)+".jpg")
    img = addTransparency(img, factor=0.99)
    img.save("../png/"+str(i)+".png", quality=100)

# img = Image.open(file_list[0])
# img = img = addTransparency(img, factor=0.99)
# img = downSample(img)
# img.save("../downsample/"+str(0)+".png", quality=100)


