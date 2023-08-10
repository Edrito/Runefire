from PIL import Image
import sys

def split_image(input_file, tile_size):
    try:
        image = Image.open(input_file)
    except IOError:
        print("Error: Couldn't open the image file.")
        return
    
    width, height = image.size
    tile_width, tile_height = tile_size
    
    tiles_x = width // tile_width
    tiles_y = height // tile_height
    
    for y in range(tiles_y):
        for x in range(tiles_x):
            left = x * tile_width
            upper = y * tile_height
            right = left + tile_width
            lower = upper + tile_height
            
            tile = image.crop((left, upper, right, lower))
            tile.save(f"tile_{x}_{y}.png")
    
    print(f"Image split into {tiles_x}x{tiles_y} tiles.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python split_image.py input_file.png tile_width tile_height")
    else:
        input_file = sys.argv[1]
        tile_size = (int(sys.argv[2]), int(sys.argv[3]))
        split_image(input_file, tile_size)
