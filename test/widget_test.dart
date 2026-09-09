import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders and emits a Brazilian phone number', (tester) async {
    PhoneNumber? emitted;
    bool? valid;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'BR'),
            onInputChanged: (number) => emitted = number,
            onInputValidated: (value) => valid = value,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('+55'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '11987654321');
    await tester.pump();

    expect(emitted?.isoCode, 'BR');
    expect(emitted?.phoneNumber, '+5511987654321');
    expect(valid, isTrue);
  });
}
