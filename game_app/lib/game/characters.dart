enum CharacterType { wizard, rogue }

extension CharacterTypeFilename on CharacterType {
  String getFilename() {
    switch (this) {
      case CharacterType.wizard:
        return 'wizard.png';
      case CharacterType.rogue:
        return 'rogue.png';
      default:
        return '';
    }
  }
}

enum EnemyType {
  flameHead,
}

extension EnemyTypeFilename on EnemyType {
  String getFilename() {
    switch (this) {
      case EnemyType.flameHead:
        return 'flame_head.png';

      default:
        return '';
    }
  }
}
