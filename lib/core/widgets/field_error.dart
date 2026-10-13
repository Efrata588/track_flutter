import 'package:flutter/material.dart';

class FieldError extends StatelessWidget {
  final String? message;

  const FieldError({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
