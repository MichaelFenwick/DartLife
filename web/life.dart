library Life;

import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'package:color/color.dart';

part 'life_board.dart';
part 'life_engine.dart';
part 'rule_set.dart';
part 'cell.dart';
part 'pausable_timer.dart';

void main() {
  CanvasElement canvas = querySelector('#canvas');

  LifeBoard lifeBoard = new LifeBoard.empty(
      canvas,
      width: int.parse((querySelector('#gridWidthSlider') as RangeInputElement).value),
      height: int.parse((querySelector('#gridHeightSlider') as RangeInputElement).value),
      wrap: true,
      drawGrid: true
  );

  LifeEngine lifeEngine = new LifeEngine(lifeBoard, new RuleSet.byName('conway'));

  PausableTimer simulationTimer = new PausableTimer(
      new Duration(milliseconds: int.parse((querySelector('#simulationSpeedSlider') as RangeInputElement).value)),
      (Timer timer) {
        lifeEngine.tick();
      }
  )..cancel();

  void requestDraw() {
    window.animationFrame.then((_) {
      lifeBoard.draw();
      requestDraw();
    });
  }

  void buildInterface() {
    ButtonElement buildRuleSetButton({RuleSet ruleSet, String name, String value}) {
      String birthString = ruleSet is RuleSet ? ruleSet.birthRules.join() : "???";
      String surviveString = ruleSet is RuleSet ? ruleSet.surviveRules.join() : "???";
      String rulesSummary = "B$birthString/S$surviveString";
      return new ButtonElement()..classes.add('ruleSetButton')
        ..value = value
        ..text = name
        ..append(new SpanElement()..classes.add('rule')..text = rulesSummary);
    }

    DivElement buttonContainer = querySelector('#ruleSetButtons');
    RuleSet.builtIns.forEach((String key, Map ruleSetInfo) {
      buttonContainer.append(buildRuleSetButton(ruleSet: ruleSetInfo['ruleSet'], name: ruleSetInfo['name'], value: key));
    });
    buttonContainer.append(buildRuleSetButton(name: "Custom", value: 'custom'));
    (buttonContainer.firstChild as ButtonElement).classes.add('active');
  }

  void setupEventListeners() {
    querySelector('#pauseButton').onClick.listen((Event e) {
      ButtonElement button = e.target;
      if (simulationTimer.toggle()) {
        button.text = "Pause";
      } else {
        button.text = "Start";
      }
    });

    querySelector('#simulationSpeedSlider').onChange.listen((Event e) {
      RangeInputElement simulationSpeedSlider = e.target;
      int newSimulationSpeed = int.parse(simulationSpeedSlider.value);
      querySelector('#simulationSpeedValue').text = newSimulationSpeed.toString();
      simulationTimer.setDuration(new Duration(milliseconds: newSimulationSpeed));
    });

    querySelector('#gridWidthSlider').onChange.listen((Event e) {
      RangeInputElement widthSlider = e.target;
      int newWidth = int.parse(widthSlider.value);
      querySelector('#widthValue').text = newWidth.toString();
      lifeBoard.width = newWidth;
    });

    querySelector('#gridHeightSlider').onChange.listen((Event e) {
      RangeInputElement heightSlider = e.target;
      int newHeight = int.parse(heightSlider.value);
      querySelector('#heightValue').text = newHeight.toString();
      lifeBoard.height = newHeight;
    });

    CanvasElement canvas = querySelector('#canvas');

    canvas.onMouseDown.listen((MouseEvent mouseDownEvent) {
      StreamSubscription moveSubscription;
      StreamSubscription mouseUpSubscription;
      Cell hoverCell = null;

      void toggleHoverCell(MouseEvent event) {
        Cell targetCell = lifeBoard.getCellByCanvasCoords(event.offset.x, event.offset.y);
        if (targetCell is Cell && hoverCell != targetCell) {
          targetCell.toggle();
        }
        hoverCell = targetCell;
      }

      moveSubscription = canvas.onMouseMove.listen((MouseEvent moveEvent) {
        toggleHoverCell(moveEvent);
      });

      mouseUpSubscription = document.onMouseUp.listen((MouseEvent mouseUpEvent) {
        toggleHoverCell(mouseUpEvent);
        moveSubscription.cancel();
        mouseUpSubscription.cancel();
      });
    });

    querySelector('#clearButton').onClick.listen((Event e) {
      lifeBoard.clear();
    });

    querySelector('#randomButton').onClick.listen((Event e) {
      lifeBoard.randomize();
    });

    querySelector('#invertButton').onClick.listen((Event e) {
      lifeBoard.invert();
    });

    querySelector('#gridButton').onClick.listen((Event e) {
      querySelector('#gridButtonValue').text = lifeBoard.toggleGrid() ? "On" : "Off";
    });

    querySelector('#wrapButton').onClick.listen((Event e) {
      querySelector('#wrapButtonValue').text = lifeBoard.toggleWrap() ? "On" : "Off";
    });

    ElementList ruleSetButtons = querySelectorAll('.ruleSetButton');

    void setActiveRulesSetButton(ButtonElement activeButton) {
      ruleSetButtons.classes.remove('active');
      activeButton.classes.add('active');
    }

    void updateRulesSet() {
      ButtonElement activeButton = querySelector('.ruleSetButton.active');
      TextInputElement birthRulesTextbox = querySelector('#birthRulesTextbox');
      TextInputElement surviveRulesTextbox = querySelector('#surviveRulesTextbox');
      String newRuleSetName = activeButton.value;
      RuleSet newRuleSet;

      if (newRuleSetName == 'custom') {
        newRuleSet = new RuleSet(
            RuleSet.parseRuleSetString(birthRulesTextbox.value),
            RuleSet.parseRuleSetString(surviveRulesTextbox.value),
            1
        );
      } else {
        newRuleSet = new RuleSet.byName(activeButton.value);
      }

      lifeEngine.ruleSet = newRuleSet;

      birthRulesTextbox.value = newRuleSet.birthRules.join();
      surviveRulesTextbox.value = newRuleSet.surviveRules.join();
    }

    ruleSetButtons.onClick.listen((Event e) {
      Element target = e.target;
      while (target is! ButtonElement && target is! HtmlDocument) {
        target = target.parent;
      }
      setActiveRulesSetButton(target);
      updateRulesSet();
    });

    querySelectorAll('#birthRulesTextbox, #surviveRulesTextbox').onChange.listen((Event e) {
      setActiveRulesSetButton(querySelector('.ruleSetButton[value="custom"]'));
      updateRulesSet();
    });

    ElementList colorButtons = querySelectorAll('.colorBox');

    void setActiveColorButton(ButtonElement activeButton) {
      colorButtons.classes.remove('active');
      activeButton.classes.add('active');
    }

    void toggleColorButton(ButtonElement button) {
      if (button.classes.contains('active')) {
        button.classes.remove('active');
      } else {
        button.classes.add('active');
      }
    }

    colorButtons.onClick.listen((MouseEvent event) {
      ButtonElement clickedButton = event.target;
      if (event.ctrlKey || event.altKey) {
        toggleColorButton(clickedButton);
      } else {
        setActiveColorButton(clickedButton);
      }
      activeColors = getActiveColors();
    });
  }

  buildInterface();
  setupEventListeners();
  requestDraw();
}

List<Color> activeColors = getActiveColors();

List<Color> getActiveColors() => querySelectorAll('.colorBox.active').toList().map(
  (Element element) => new Color.hex(element.dataset['color'])
).toList();

Color getActiveColor() {
  return activeColors[new Random().nextInt(activeColors.length)];
}