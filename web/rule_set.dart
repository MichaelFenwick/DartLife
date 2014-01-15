part of Life;

class RuleSet {
  List<int> birthRules;
  List<int> surviveRules;
  int sightRange;

  RuleSet(List<int> this.birthRules, List<int> this.surviveRules, int this.sightRange) {}

  RuleSet.conway() : this([3], [2, 3], 1);
  RuleSet.highLife() : this([3, 6], [2, 3], 1);
  RuleSet.lifeWithoutDeath() : this([3], [0, 1, 2, 3, 4, 5, 6, 7, 8], 1);
  RuleSet.dayAndNight() : this([3, 6, 7, 8], [3, 4, 6, 7, 8], 1);
  RuleSet.seeds() : this([2], [], 1);
  RuleSet.replicator() : this([1, 3, 5, 7], [1, 3, 5, 7], 1);
  RuleSet.maze() : this([3], [1, 2, 3, 4, 5], 1);
  RuleSet.mazectric() : this([3], [1, 2, 3, 4], 1);
  RuleSet.twoByTwo() : this([3, 6], [1, 2, 5], 1);
  RuleSet.move() : this([3, 6, 8], [2, 4, 5], 1);
  RuleSet.amoeba() : this([3, 5, 7], [1, 3, 5, 8], 1);
  RuleSet.liveFreeOrDie() : this([2], [0], 1);

  factory RuleSet.byName(String ruleSetName) {
    switch (ruleSetName) {
      case 'conway':
        return new RuleSet.conway();
      case 'highLife':
        return new RuleSet.highLife();
      case 'lifeWithoutDeath':
        return new RuleSet.lifeWithoutDeath();
      case 'dayAndNight':
        return new RuleSet.dayAndNight();
      case 'seeds':
        return new RuleSet.seeds();
      case 'replicator':
        return new RuleSet.replicator();
      case 'maze':
        return new RuleSet.maze();
      case 'mazectric':
        return new RuleSet.mazectric();
      case 'twoByTwo':
        return new RuleSet.twoByTwo();
      case 'move':
        return new RuleSet.move();
      case 'amoeba':
        return new RuleSet.amoeba();
      case 'liveFreeOrDie':
        return new RuleSet.liveFreeOrDie();
      default:
        throw new Exception("Invalid ruleSetName passed '$ruleSetName' to RuleSet.byName().");
    }
  }

  static List<int> parseRuleSetString(String string) {
    return new RegExp(r'\d').allMatches(string).toList().map(
      (Match match) => int.parse(match.group(0).toString())
    ).toSet().toList();
  }
}