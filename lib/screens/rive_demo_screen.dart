import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveDemoScreen extends StatelessWidget {
  const RiveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شخصيتك التفاعلية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 250,
              height: 250,
              child: RiveAnimation.asset(
                'assets/rive/character.riv', // سنضيف الملف لاحقًا أو نستخدم رابط شبكي
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ستيف ينتظر تحقيق أهدافك!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'اكمل 10,000 خطوة لتراه يرقص',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}