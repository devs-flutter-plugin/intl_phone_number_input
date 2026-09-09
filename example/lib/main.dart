import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intl Phone Number Input',
      theme: ThemeData(useMaterial3: true),
      home: const PhoneExamplePage(),
    );
  }
}

class PhoneExamplePage extends StatefulWidget {
  const PhoneExamplePage({super.key});

  @override
  State<PhoneExamplePage> createState() => _PhoneExamplePageState();
}

class _PhoneExamplePageState extends State<PhoneExamplePage> {
  PhoneNumber? _number;
  bool _valid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('International phone input')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'BR'),
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              setSelectorButtonAsPrefixIcon: true,
            ),
            onInputChanged: (number) => setState(() => _number = number),
            onInputValidated: (valid) => setState(() => _valid = valid),
          ),
          const SizedBox(height: 24),
          Text('E.164: ${_number?.phoneNumber ?? '-'}'),
          Text('ISO: ${_number?.isoCode ?? '-'}'),
          Text('Valid: $_valid'),
        ],
      ),
    );
  }
}
