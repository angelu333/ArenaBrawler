from PIL import Image
import sys

def fix_archer_rows(path):
    try:
        img = Image.open(path)
        width, height = img.size
        row_height = height // 4
        
        # Extract rows
        row1 = img.crop((0, 0, width, row_height))              # Down
        row2 = img.crop((0, row_height, width, row_height * 2)) # Currently Left (but user says it looks Right)
        row3 = img.crop((0, row_height * 2, width, row_height * 3)) # Currently Right (broken)
        row4 = img.crop((0, row_height * 3, width, height))     # Up
        
        # Logic:
        # User says Row 2 (Left slot) looks like it's going Right.
        # So we take Row 2, put it in Row 3 (Right slot).
        # Then we flip Row 2 horizontally and put it in Row 2 (Left slot).
        
        new_right = row2
        new_left = row2.transpose(Image.FLIP_LEFT_RIGHT)
        
        # Create new image
        new_img = Image.new("RGBA", (width, height))
        new_img.paste(row1, (0, 0))
        new_img.paste(new_left, (0, row_height))
        new_img.paste(new_right, (0, row_height * 2))
        new_img.paste(row4, (0, row_height * 3))
        
        new_img.save(path)
        print(f"Successfully fixed rows for {path}")
        
    except Exception as e:
        print(f"Error fixing rows: {e}")

if __name__ == "__main__":
    fix_archer_rows(r'c:\Users\PC001\Documents\Tareas Sep-Dic\juego_happy\assets\images\characters\Archer\walk_spritesheet.png')
