import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/pin_keypad.dart';

void main() {
  testWidgets('PinKeypad accepts up to 4 digits and supports delete', (
    tester,
  ) async {
    var pin = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildDarkTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PinKeypad(
                pinLength: pin.length,
                onDigitPressed: (digit) {
                  setState(() {
                    if (pin.length < 4) pin += digit;
                  });
                },
                onDeletePressed: () {
                  setState(() {
                    if (pin.isNotEmpty) {
                      pin = pin.substring(0, pin.length - 1);
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(pin, '123');

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    expect(pin, '12');

    await tester.tap(find.text('3'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(pin, '1234');
  });
}
