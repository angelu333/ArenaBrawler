import os
from PIL import Image

def remove_checkerboard(image_path):
    try:
        img = Image.open(image_path).convert("RGBA")
        datas = img.getdata()

        new_data = []
        # Colores típicos del checkerboard (blanco y gris claro)
        # Ajustar tolerancia si es necesario
        for item in datas:
            # Blanco (255, 255, 255) o Gris (204, 204, 204) o similar
            # A veces el gris es diferente, vamos a usar un rango o detectar esquinas
            # En este caso, asumiremos que los colores de fondo son distintos a los del personaje
            # O mejor, hacemos floodfill desde la esquina si el personaje está centrado?
            # No, es un spritesheet.
            
            # Vamos a intentar detectar colores casi blancos y grises claros que sean fondo
            # Rango para blanco: > 240, 240, 240
            # Rango para gris: alrededor de 200-220 en los 3 canales
            
            if (item[0] > 240 and item[1] > 240 and item[2] > 240) or \
               (item[0] > 190 and item[0] < 220 and item[1] > 190 and item[1] < 220 and item[2] > 190 and item[2] < 220):
                new_data.append((255, 255, 255, 0)) # Transparente
            else:
                new_data.append(item)

        img.putdata(new_data)
        img.save(image_path, "PNG")
        print(f"Processed: {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

base_dir = r"c:\Users\PC001\Documents\Tareas Sep-Dic\juego_happy\assets\images\characters"
characters = ["Adventurer", "Archer", "Warrior", "Mage", "Rogue", "Healer"]

for char in characters:
    for type in ["walk_spritesheet.png", "attack_spritesheet.png"]:
        path = os.path.join(base_dir, char, type)
        if os.path.exists(path):
            remove_checkerboard(path)
        else:
            print(f"Not found: {path}")
