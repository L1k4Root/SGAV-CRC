import 'package:flutter/material.dart';

enum TrafficLightState { idle, green, red, yellow }

class TrafficLight extends StatelessWidget {
  final TrafficLightState state;
  const TrafficLight({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final color = {
      TrafficLightState.green: Colors.green,
      TrafficLightState.red: Colors.red,
      TrafficLightState.yellow: Colors.amber,
      TrafficLightState.idle: Colors.grey,
    }[state]!;

    final text = {
      TrafficLightState.green: 'AUTORIZADO',
      TrafficLightState.red: 'NO REGISTRADO',
      TrafficLightState.yellow: 'EXPIRADO',
      TrafficLightState.idle: '—',
    }[state]!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey<TrafficLightState>(state),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 6),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
