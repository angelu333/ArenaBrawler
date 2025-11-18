# 📋 Instrucciones para Integrar Sprites Animados

## 🎯 Objetivo
Reemplazar los sprites estáticos actuales con sprites animados completos.

## 📥 PASO 1: Descargar Sprites

### Opción Recomendada: Tiny Swords
1. Ve a: https://pixelfrog-assets.itch.io/tiny-swords
2. Click en "Download Now"
3. Pon $0.00 (es gratis)
4. Click en "No thanks, just take me to the downloads"
5. Descarga el archivo ZIP
6. Extrae el contenido

### Alternativa: Dungeon Tileset II
1. Ve a: https://0x72.itch.io/dungeontileset-ii
2. Sigue el mismo proceso

## 📁 PASO 2: Estructura de Carpetas

Crea esta estructura en tu proyecto:

```
assets/
└── images/
    └── characters/
        ├── knight/
        │   ├── idle.png
        │   ├── run.png
        │   ├── attack.png
        │   ├── hit.png
        │   └── death.png
        ├── warrior/
        ├── mage/
        ├── archer/
        ├── rogue/
        └── paladin/
```

## 🎨 PASO 3: Preparar los Sprites

### Qué buscar en el pack descargado:

Para cada personaje necesitas encontrar estos archivos:
- **Idle** (parado/respirando)
- **Run** (corriendo)
- **Attack** (atacando)
- **Hit** (recibiendo daño)
- **Death** (muriendo)

### Formato esperado:

Los sprite sheets deben ser imágenes horizontales con todos los frames en fila:
```
[Frame1][Frame2][Frame3][Frame4]...
```

## 📝 PASO 4: Renombrar y Copiar

1. Busca los archivos de animación en el pack descargado
2. Renómbralos según la estructura de arriba
3. Cópialos a las carpetas correspondientes

## ✅ PASO 5: Verificar

Asegúrate de tener:
- ✅ 6 carpetas de personajes
- ✅ 5 archivos PNG por personaje (idle, run, attack, hit, death)
- ✅ Total: 30 archivos PNG

## 🚀 PASO 6: Avisar

Una vez que tengas todo organizado, avísame y yo:
1. Actualizo el código para usar las animaciones
2. Configuro los frames correctos
3. Ajusto velocidades y timings
4. Pruebo que todo funcione

## 💡 Consejos

- Los sprites deben ser del mismo tamaño (ej: 64x64, 32x32)
- Mantén los nombres consistentes
- Si un personaje no tiene una animación, usa la de otro temporalmente

## ❓ Problemas Comunes

**P: No encuentro la animación de "hit"**
R: Algunos packs la llaman "hurt" o "damage"

**P: Los sprites están en carpetas separadas**
R: Está bien, solo organízalos según la estructura de arriba

**P: Hay múltiples versiones del mismo personaje**
R: Elige la que más te guste

## 📞 Siguiente Paso

Cuando termines, dime:
1. ✅ "Ya tengo los sprites organizados"
2. 📊 Cuántos frames tiene cada animación
3. 📏 Qué tamaño tienen los sprites (32x32, 64x64, etc.)

Y yo actualizo todo el código automáticamente.
