# 🗺️ SISTEMA DE MAPA DE NIVELES - Estilo Super Mario

## 📋 ¿QUÉ ES?

Un mapa visual donde el jugador puede ver:
- ✅ Niveles completados (verde con check)
- 🎯 Nivel actual (azul pulsante con personaje)
- 🔒 Niveles bloqueados (gris con candado)
- ⭐ Estrellas ganadas (1-3 por nivel)
- 🛤️ Caminos conectando niveles

## 🎨 CARACTERÍSTICAS VISUALES

### **Nodos de Nivel:**
- **Círculos grandes** (80x80) con número del nivel
- **Colores según estado:**
  - Verde: Completado
  - Azul: Actual (pulsa)
  - Gris: Bloqueado
  - Color por dificultad: Verde→Azul→Naranja→Rojo→Morado
- **Iconos:**
  - ✓ Check verde si completado
  - 🔒 Candado si bloqueado
  - 👤 Personaje en nivel actual
- **Estrellas:** 1-3 estrellas según desempeño

### **Caminos:**
- **Líneas curvas** conectando niveles
- **Color amarillo** si desbloqueado
- **Color café** si bloqueado
- **Bifurcaciones** posibles (nivel 2 → 3a o 3b)

### **Fondo:**
- **Gradiente** azul cielo → verde pasto
- **Nubes** decorativas flotantes
- **Estilo** retro/arcade

## 🎮 FUNCIONALIDAD

### **Interacción:**
1. **Tap en nivel desbloqueado:**
   - Muestra diálogo con info
   - Botón "¡JUGAR!" para iniciar
   
2. **Tap en nivel bloqueado:**
   - Mensaje: "Completa el nivel anterior"

3. **Animaciones:**
   - Nivel actual pulsa constantemente
   - Brillo amarillo en nivel actual

### **Progreso:**
- Se guarda localmente (SharedPreferences)
- Nivel 1 siempre desbloqueado
- Completar nivel desbloquea siguiente(s)
- Sistema de estrellas (1-3)
- Mejor tiempo y puntuación guardados

## 📊 ESTRUCTURA DE NIVELES

### **7 Niveles Actuales:**

```
        🏰 [7] Jefe Final
         |
        ⭐ [6] Arena Mortal
         |
        ⭐ [5] Horda
        / \
       /   \
      ⭐   ⭐ [3/4] Emboscada / Alternativo
       \   /
        \ /
        ⭐ [2] Doble Problema
         |
        ⭐ [1] Primera Batalla
```

### **Detalles por Nivel:**

**Nivel 1: Primera Batalla**
- Dificultad: ⭐
- Enemigos: 1
- Arena: arena_1
- Recompensa: 50 monedas
- Descripción: Tutorial básico

**Nivel 2: Doble Problema**
- Dificultad: ⭐⭐
- Enemigos: 2
- Arena: arena_1
- Recompensa: 75 monedas

**Nivel 3: Emboscada**
- Dificultad: ⭐⭐
- Enemigos: 3
- Arena: arena_2
- Recompensa: 100 monedas

**Nivel 4: Camino Alternativo**
- Dificultad: ⭐⭐
- Enemigos: 3
- Arena: arena_2
- Recompensa: 100 monedas
- Nota: Ruta alternativa al nivel 3

**Nivel 5: Horda**
- Dificultad: ⭐⭐⭐
- Enemigos: 5
- Arena: arena_2
- Recompensa: 150 monedas

**Nivel 6: Arena Mortal**
- Dificultad: ⭐⭐⭐⭐
- Enemigos: 4
- Arena: arena_3
- Recompensa: 200 monedas

**Nivel 7: Jefe Final**
- Dificultad: ⭐⭐⭐⭐⭐
- Enemigos: 1 (Boss)
- Arena: arena_3
- Recompensa: 500 monedas

## 🔧 ARCHIVOS CREADOS

### **1. lib/models/level_data.dart**
- Clase `LevelData`: Info de cada nivel
- Clase `LevelPosition`: Posición en mapa (x, y)
- Clase `LevelProgress`: Estado de progreso
- Lista de todos los niveles
- Mapa de conexiones entre niveles

### **2. lib/services/game_data_service.dart** (actualizado)
- `getLevelProgress()`: Obtener progreso
- `saveLevelProgress()`: Guardar progreso
- `unlockLevel()`: Desbloquear nivel
- `completeLevel()`: Marcar como completado
- `getCurrentLevel()`: Nivel actual
- `setCurrentLevel()`: Cambiar nivel actual

### **3. lib/screens/level_map_screen.dart**
- Pantalla principal del mapa
- `LevelPathPainter`: Dibuja caminos
- `CloudsPainter`: Dibuja nubes decorativas
- Animaciones y efectos visuales
- Manejo de interacciones

## 🚀 CÓMO USAR

### **Desde el Menú Principal:**
```dart
// Ya está integrado en home_screen.dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LevelMapScreen(),
  ),
);
```

### **Completar un Nivel:**
```dart
// Al terminar una partida
await _gameData.completeLevel(
  levelId: 1,
  stars: 3,        // 1-3 estrellas
  score: 1000,     // Puntuación
  time: 45.5,      // Tiempo en segundos
);

// Desbloquear siguiente nivel
await _gameData.unlockLevel(2);
```

### **Verificar Progreso:**
```dart
final progress = await _gameData.getLevelProgress();
final isCompleted = progress[1]?['isCompleted'] ?? false;
final stars = progress[1]?['stars'] ?? 0;
```

## 🎯 PRÓXIMAS MEJORAS

### **Fáciles:**
- [ ] Más niveles (hasta 20-30)
- [ ] Diferentes mundos/temas
- [ ] Animación al desbloquear nivel
- [ ] Sonidos al seleccionar nivel

### **Medias:**
- [ ] Niveles secretos
- [ ] Desafíos especiales
- [ ] Logros por nivel
- [ ] Tabla de clasificación

### **Avanzadas:**
- [ ] Modo historia con cinemáticas
- [ ] Jefes únicos por mundo
- [ ] Power-ups desbloqueables
- [ ] Multijugador en niveles

## 💡 PERSONALIZACIÓN

### **Cambiar Posiciones:**
```dart
// En lib/models/level_data.dart
position: LevelPosition(
  x: 0.5,  // 0.0 = izquierda, 1.0 = derecha
  y: 0.9,  // 0.0 = arriba, 1.0 = abajo
),
```

### **Agregar Más Niveles:**
```dart
LevelData(
  id: 8,
  name: 'Nuevo Nivel',
  description: 'Descripción',
  difficulty: 3,
  enemyCount: 4,
  arenaId: 'arena_1',
  coinsReward: 150,
  position: LevelPosition(x: 0.5, y: 0.05),
),
```

### **Cambiar Conexiones:**
```dart
// En LevelData.connections
7: [8, 9],  // Nivel 7 desbloquea 8 y 9
```

### **Cambiar Colores:**
```dart
// En _getNodeColors() de level_map_screen.dart
case 1:
  return [Colors.green.shade300, Colors.green.shade600];
```

## 🐛 SOLUCIÓN DE PROBLEMAS

**P: Los niveles no se guardan**
R: Verifica que SharedPreferences esté inicializado

**P: Todos los niveles están bloqueados**
R: El nivel 1 siempre debe estar desbloqueado por defecto

**P: Las líneas no se ven bien**
R: Ajusta strokeWidth en LevelPathPainter

**P: Los nodos están mal posicionados**
R: Ajusta los valores x, y en LevelPosition (0.0 a 1.0)

## 📱 RESPONSIVE

El mapa se adapta automáticamente a diferentes tamaños de pantalla:
- Usa porcentajes (0.0 a 1.0) para posiciones
- Se escala según MediaQuery.of(context).size
- Funciona en móvil, tablet y web

## 🎨 ESTILO VISUAL

Inspirado en:
- Super Mario World (SNES)
- Candy Crush Saga
- Angry Birds
- Monument Valley

Características:
- Colores vibrantes
- Animaciones suaves
- Feedback visual claro
- Estilo arcade/retro

---

¡Disfruta tu mapa de niveles! 🎮✨
