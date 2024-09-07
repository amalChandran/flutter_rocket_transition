import 'package:flutter/material.dart';
import 'package:flutter_rocket_transition/rocket_exhaust.dart';

class AnimatedButtonScreen extends StatefulWidget {
  const AnimatedButtonScreen({Key? key}) : super(key: key);

  @override
  _AnimatedButtonScreenState createState() => _AnimatedButtonScreenState();
}

class _AnimatedButtonScreenState extends State<AnimatedButtonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _riseToLaunchStationAnimation;
  late Animation<double> _liftOffFromLaunchStationAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isVisible = false;
        });
      }
    });

    _riseToLaunchStationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _liftOffFromLaunchStationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInCirc),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateButton() {
    setState(() {
      _isVisible = true;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 116, 4, 208),
            ),
          ),
          AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return RocketExhaustWidget(
                    launchProgress: _liftOffFromLaunchStationAnimation.value > 0
                        ? ((screenHeight * 2) *
                                _liftOffFromLaunchStationAnimation.value +
                            screenHeight / 4)
                        : screenHeight /
                            4 *
                            _riseToLaunchStationAnimation.value);
              }),
          if (_isVisible)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: _liftOffFromLaunchStationAnimation.value > 0
                      ? ((screenHeight * 2) *
                              _liftOffFromLaunchStationAnimation.value +
                          screenHeight / 4)
                      : screenHeight / 4 * _riseToLaunchStationAnimation.value,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _animateButton,
                      child: const Icon(Icons.rocket),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
