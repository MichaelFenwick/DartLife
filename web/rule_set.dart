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