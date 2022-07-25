import 'package:flutter/material.dart';

class ChatCountBadge extends StatelessWidget {
  final String badge;
  const ChatCountBadge({
    Key? key,
    required this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      alignment: Alignment.center,
      height: 30,
      width: 30,
      child: Text(
        badge,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
