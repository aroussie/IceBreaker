import 'dart:convert';
import 'dart:math';
import 'package:challenge/MyQuestionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<String> _icebreakers = ["Welcome on Icebreaker!\nTap on the screen to display "
      "a new question and get to know the people you're with!"];

  AnimationController _colorAnimController, _textAnimController;
  Animation<Color> _colorAnimation;
  Tween<Color> _colorTween;
  int _currentColorIndex, _currentQuestionIndex = 0;
  String _currentQuestion;

  @override
  void initState() {
    super.initState();
    _colorAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _textAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _colorTween = ColorTween(begin: Colors.orange, end: Colors.orange);
    _colorAnimation = _colorTween.animate(_colorAnimController);

    rootBundle.loadString("assets/questions.json").then((data) {
      _icebreakers.addAll((json.decode(data) as List)
          .map(((element) => element.toString()))
          .toList());
    });
    _currentQuestion = _icebreakers[0];
  }

  @override
  void dispose() {
    super.dispose();
    _colorAnimController.dispose();
    _textAnimController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: _animateColorAndText,
            child: AnimatedBuilder(
                animation: _colorAnimation,
                builder: (_, child) {
                  return Scaffold(
                      backgroundColor: _colorAnimation.value,
                      body: MyQuestionWidget(
                          question: _currentQuestion,
                          controller: _textAnimController));
                })));
  }

  void _animateColorAndText() {
    _colorTween.begin = _colorTween.end;
    _colorAnimController.reset();
    _colorTween.end = _getNewColor();
    _colorAnimController.forward();

    _textAnimController.forward().whenComplete(() {
      _currentQuestionIndex = _currentQuestionIndex == _icebreakers.length - 1
          ? 0
          : _currentQuestionIndex += 1;
      _currentQuestion = _icebreakers[_currentQuestionIndex];
      _textAnimController.reverse();
    });
  }

  Color _getNewColor() {
    var availableColors = Colors.primaries.sublist(0, 9);
    int randomIndex = Random().nextInt(availableColors.length);
    if (randomIndex != _currentColorIndex) {
      _currentColorIndex = randomIndex;
      return availableColors[randomIndex];
    } else
      return _getNewColor();
  }
}
