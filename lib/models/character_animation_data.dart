/// Datos de animación para cada personaje
class CharacterAnimationData {
  final String characterId;
  final String basePath;
  final AnimationFrames frames;
  final AnimationSpeeds speeds;

  const CharacterAnimationData({
    required this.characterId,
    required this.basePath,
    required this.frames,
    required this.speeds,
  });

  // Configuración por defecto (ajustar según los sprites reales)
  static const Map<String, CharacterAnimationData> animations = {
    'knight': CharacterAnimationData(
      characterId: 'knight',
      basePath: 'characters/knight',
      frames: AnimationFrames(
        idle: 4,
        run: 6,
        attack: 4,
        hit: 2,
        death: 4,
      ),
      speeds: AnimationSpeeds(
        idle: 0.15,
        run: 0.1,
        attack: 0.1,
        hit: 0.1,
        death: 0.15,
      ),
    ),
    'warrior': CharacterAnimationData(
      characterId: 'warrior',
      basePath: 'characters/warrior',
      frames: AnimationFrames(
        idle: 4,
        run: 6,
        attack: 4,
        hit: 2,
        death: 4,
      ),
      speeds: AnimationSpeeds(
        idle: 0.15,
        run: 0.1,
        attack: 0.1,
        hit: 0.1,
        death: 0.15,
      ),
    ),
    'mage': CharacterAnimationData(
      characterId: 'mage',
      basePath: 'characters/mage',
      frames: AnimationFrames(
        idle: 4,
        run: 6,
        attack: 4,
        hit: 2,
        death: 4,
      ),
      speeds: AnimationSpeeds(
        idle: 0.15,
        run: 0.1,
        attack: 0.1,
        hit: 0.1,
        death: 0.15,
      ),
    ),
    'archer': CharacterAnimationData(
      characterId: 'archer',
      basePath: 'characters/archer',
      frames: AnimationFrames(
        idle: 4,
        run: 6,
        attack: 4,
        hit: 2,
        death: 4,
      ),
      speeds: AnimationSpeeds(
        idle: 0.15,
        run: 0.1,
        attack: 0.1,
        hit: 0.1,
        death: 0.15,
      ),
    ),
    'rogue': CharacterAnimationData(
      characterId: 'rogue',
      basePath: 'characters/rogue',
      frames: AnimationFrames(
        idle: 4,
        run: 6,
        attack: 4,
        hit: 2,
        death: 4,
      ),
      speeds: AnimationSpeeds(
        idle: 0.15,
        run: 0.1,
        attack: 0.1,
        hit: 0.1,
        death: 0.15,
      ),
    ),
    'paladin': CharacterAnimationData(
      characterId: 'paladin',
      basePath: 'characters/paladin',
      frames: AnimationFrames(
        idle: 4,
        run: 6,
        attack: 4,
        hit: 2,
        death: 4,
      ),
      speeds: AnimationSpeeds(
        idle: 0.15,
        run: 0.1,
        attack: 0.1,
        hit: 0.1,
        death: 0.15,
      ),
    ),
  };
}

class AnimationFrames {
  final int idle;
  final int run;
  final int attack;
  final int hit;
  final int death;

  const AnimationFrames({
    required this.idle,
    required this.run,
    required this.attack,
    required this.hit,
    required this.death,
  });
}

class AnimationSpeeds {
  final double idle;
  final double run;
  final double attack;
  final double hit;
  final double death;

  const AnimationSpeeds({
    required this.idle,
    required this.run,
    required this.attack,
    required this.hit,
    required this.death,
  });
}
