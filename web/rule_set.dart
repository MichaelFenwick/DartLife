part of Life;

class RuleSet {
  List<int> birthRules;
  List<int> surviveRules;
  int sightRange;

  static final Map<String, Map> builtIns = {
    'conway': {
      'name': "Conway's Life", 'ruleSet': new RuleSet([3], [2, 3], 1)
    }, 'highLife': {
      'name': "High Life", 'ruleSet': new RuleSet([3, 6], [2, 3], 1)
    }, 'lifeWithoutDeath': {
      'name': "Life Without Death", 'ruleSet': new RuleSet([3], [0, 1, 2, 3, 4, 5, 6, 7, 8], 1)
    }, 'dayAndNight': {
      'name': "Day & Night", 'ruleSet': new RuleSet([3, 6, 7, 8], [3, 4, 6, 7, 8], 1)
    }, 'seeds': {
      'name': "Seeds", 'ruleSet': new RuleSet([2], [], 1)
    }, 'replicator': {
      'name': "Replicator", 'ruleSet': new RuleSet([1, 3, 5, 7], [1, 3, 5, 7], 1)
    }, 'maze': {
      'name': "Maze", 'ruleSet': new RuleSet([3], [1, 2, 3, 4, 5], 1)
    }, 'mazectric': {
      'name': "Mazectric", 'ruleSet': new RuleSet([3], [1, 2, 3, 4], 1)
    }, 'twoByTwo': {
      'name': "Two By Two", 'ruleSet': new RuleSet([3, 6], [1, 2, 5], 1)
    }, 'move': {
      'name': "Move", 'ruleSet': new RuleSet([3, 6, 8], [2, 4, 5], 1)
    }, 'amoeba': {
      'name': "Amoeba", 'ruleSet': new RuleSet([3, 5, 7], [1, 3, 5, 8], 1)
    }, 'liveFreeOrDie': {
      'name': "Live Free Or Die", 'ruleSet': new RuleSet([2], [0], 1)
    }
  };

  RuleSet(List<int> this.birthRules, List<int> this.surviveRules, int this.sightRange) {}

  factory RuleSet.byName(String ruleSetName) {
    if (RuleSet.builtIns.containsKey(ruleSetName)) {
      return RuleSet.builtIns[ruleSetName]['ruleSet'];
    } else {
      throw new Exception("Invalid ruleSetName passed '$ruleSetName' to RuleSet.byName().");
    }
  }

  static List<int> parseRuleSetString(String string) {
    return new RegExp(r'\d').allMatches(string).toList().map(
      (Match match) => int.parse(match.group(0).toString())
    ).toSet().toList();
  }
}