# Arena Brawler

Un juego de arena tipo brawler desarrollado con Flutter y Flame.

## 🎮 Características

### Sistema de Juego
- **6 Personajes Únicos** con diferentes estadísticas:
  - Aventurero Novato (Gratis)
  - Guardián Férreo
  - Archimago Arcano
  - Sombra Veloz
  - Explorador Certero
  - Clérigo Benevolente

- **Sistema de Combate**:
  - Joystick virtual para movimiento
  - Botón de ataque para disparar proyectiles
  - Sistema de colisiones
  - Barras de vida en tiempo real
  - IA de enemigos que persiguen y atacan

- **3 Arenas de Combate** con fondos personalizados

### Pantallas del Juego

1. **Menú Principal**
   - Botón Jugar
   - Tienda
   - Configuración (próximamente)
   - Visualización de monedas

2. **Selección de Personajes**
   - Ver todos los personajes desbloqueados
   - Estadísticas de cada personaje (Vida, Velocidad, Ataque)
   - Seleccionar personaje antes de jugar

3. **Tienda**
   - Comprar nuevos personajes con monedas
   - Ver estadísticas antes de comprar
   - Sistema de monedas

4. **Gameplay**
   - HUD con información del jugador
   - Botón de pausa
   - Controles táctiles
   - Sistema de recompensas (50 monedas por partida)

## 🛠️ Tecnologías

- **Flutter** - Framework de UI
- **Flame** - Motor de juegos 2D
- **SharedPreferences** - Persistencia local de datos

## 📦 Instalación

```bash
# Clonar el repositorio
git clone https://github.com/angelu333/ArenaBrawler.git

# Entrar al directorio
cd ArenaBrawler

# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome

# O en dispositivo móvil
flutter run
```

## 🎯 Cómo Jugar

1. **Inicio**: Abre el juego y verás el menú principal con 1000 monedas iniciales
2. **Seleccionar Personaje**: Presiona "JUGAR" y elige tu personaje
3. **Combate**: 
   - Usa el joystick (abajo izquierda) para moverte
   - Presiona el botón de rayo (abajo derecha) para atacar
   - Evita los proyectiles enemigos
4. **Ganar Monedas**: Al salir de una partida ganas 50 monedas
5. **Comprar Personajes**: Ve a la tienda y compra nuevos personajes

## 📁 Estructura del Proyecto

```
lib/
├── data/
│   └── character_data.dart          # Datos de personajes
├── game/
│   ├── components/                  # Componentes del juego
│   │   ├── arena.dart
│   │   ├── player.dart
│   │   ├── enemy_bot.dart
│   │   ├── projectile.dart
│   │   ├── wall.dart
│   │   ├── health_bar.dart
│   │   └── joystick.dart
│   ├── data/
│   │   └── arena_data.dart
│   ├── arena_brawler_game.dart      # Lógica principal del juego
│   └── flame_game_wrapper.dart      # Wrapper de Flutter
├── models/
│   ├── character_model.dart
│   └── user_profile.dart
├── screens/
│   ├── home_screen.dart             # Menú principal
│   ├── character_selection_screen.dart
│   └── store_screen.dart
├── services/
│   └── game_data_service.dart       # Gestión de datos locales
└── main.dart

assets/
├── images/
│   ├── arenas/                      # Fondos de arenas
│   │   ├── arena_1.png
│   │   ├── arena_2.png
│   │   └── arena_3.png
│   └── sprites/                     # Sprites de personajes
│       ├── char_adventurer.png
│       ├── char_warrior.png
│       ├── char_mage.png
│       ├── char_rogue.png
│       ├── char_archer.png
│       └── char_healer.png
```

## 🎨 Próximas Características

- [ ] Múltiples enemigos simultáneos
- [ ] Sistema de niveles/oleadas
- [ ] Power-ups y mejoras
- [ ] Más arenas
- [ ] Efectos de sonido y música
- [ ] Animaciones de personajes
- [ ] Sistema de logros
- [ ] Tabla de puntuaciones
- [ ] Multijugador local

## 📝 Notas de Desarrollo

- El juego usa `shared_preferences` para guardar progreso localmente
- Firebase está configurado pero deshabilitado temporalmente
- Los personajes tienen tamaño de 96x96 píxeles
- Las arenas son de 1600x1200 píxeles

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👤 Autor

**angelu333**
- GitHub: [@angelu333](https://github.com/angelu333)
- Repositorio: [ArenaBrawler](https://github.com/angelu333/ArenaBrawler)

---

¡Diviértete jugando! 🎮✨
