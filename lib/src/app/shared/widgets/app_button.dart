import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, this.onPressed, required this.text});

  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        fixedSize: Size(size.width, size.height * 0.048),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}
