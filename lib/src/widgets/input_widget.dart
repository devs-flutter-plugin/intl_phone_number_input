import 'package:dlibphonenumber/dlibphonenumber.dart' as dlib;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sealed_countries/sealed_countries.dart' hide Country;

import '../models/country_model.dart';
import '../utils/phone_number.dart';
import '../utils/selector_config.dart';

/// International phone number input backed by Google's libphonenumber data.
class InternationalPhoneNumberInput extends StatefulWidget {
  const InternationalPhoneNumberInput({
    super.key,
    this.selectorConfig = const SelectorConfig(),
    required this.onInputChanged,
    this.onInputValidated,
    this.onSubmit,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.fieldKey,
    this.textFieldController,
    this.keyboardAction,
    this.keyboardType = TextInputType.phone,
    this.initialValue,
    this.hintText = 'Phone number',
    this.hintCharacter,
    this.errorMessage = 'Invalid phone number',
    this.selectorButtonOnErrorPadding = 24,
    this.spaceBetweenSelectorAndTextField = 12,
    this.maxLength = 15,
    this.isEnabled = true,
    this.formatInput = true,
    this.autoFocus = false,
    this.autoFocusSearch = false,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.ignoreBlank = false,
    this.countrySelectorScrollControlled = true,
    this.locale,
    this.textStyle,
    this.selectorTextStyle,
    this.inputBorder,
    this.inputDecoration,
    this.searchBoxDecoration,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.scrollPadding = const EdgeInsets.all(20),
    this.focusNode,
    this.cursorColor,
    this.autofillHints,
    this.countries,
  });

  final SelectorConfig selectorConfig;
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;
  final VoidCallback? onSubmit;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final ValueChanged<PhoneNumber>? onSaved;
  final Key? fieldKey;
  final TextEditingController? textFieldController;
  final TextInputType keyboardType;
  final TextInputAction? keyboardAction;
  final PhoneNumber? initialValue;
  final String? hintText;
  final String? hintCharacter;
  final String? errorMessage;
  final double selectorButtonOnErrorPadding;
  final double spaceBetweenSelectorAndTextField;
  final int maxLength;
  final bool isEnabled;
  final bool formatInput;
  final bool autoFocus;
  final bool autoFocusSearch;
  final AutovalidateMode autoValidateMode;
  final bool ignoreBlank;
  final bool countrySelectorScrollControlled;
  final String? locale;
  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;
  final InputBorder? inputBorder;
  final InputDecoration? inputDecoration;
  final InputDecoration? searchBoxDecoration;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsets scrollPadding;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final List<String>? countries;

  @override
  State<InternationalPhoneNumberInput> createState() =>
      _InternationalPhoneNumberInputState();
}

class _InternationalPhoneNumberInputState
    extends State<InternationalPhoneNumberInput> {
  final dlib.PhoneNumberUtil _phoneUtil = dlib.PhoneNumberUtil.instance;

  late TextEditingController _controller;
  late bool _ownsController;
  List<Country> _countries = const [];
  Country? _country;
  bool _internalControllerChange = false;
  bool _lastValid = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.textFieldController);
    _loadCountries();
    _applyInitialValue();
    _controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleControllerChanged();
      }
    });
  }

  @override
  void didUpdateWidget(covariant InternationalPhoneNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.textFieldController != widget.textFieldController) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      _attachController(widget.textFieldController);
      _controller.addListener(_handleControllerChanged);
    }

    if (oldWidget.countries != widget.countries ||
        oldWidget.selectorConfig.countryComparator !=
            widget.selectorConfig.countryComparator) {
      final previousIso = _country?.alpha2Code;
      _loadCountries(preferredIso: previousIso);
    }

    if (oldWidget.initialValue?.hash != widget.initialValue?.hash) {
      _loadCountries(preferredIso: widget.initialValue?.isoCode);
      _applyInitialValue();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _attachController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
  }

  void _loadCountries({String? preferredIso}) {
    final supported = _phoneUtil.supportedRegions.toSet();
    final allowed = widget.countries
        ?.map((code) => code.trim().toUpperCase())
        .where((code) => code.isNotEmpty)
        .toSet();

    final values = WorldCountry.list
        .where((country) => supported.contains(country.codeShort))
        .where(
          (country) => allowed == null || allowed.contains(country.codeShort),
        )
        .map(
          (country) => Country(
            name: country.name.common,
            alpha2Code: country.codeShort,
            alpha3Code: country.code,
            dialCode:
                '+${_phoneUtil.getCountryCodeForRegion(country.codeShort)}',
            emoji: country.emoji,
          ),
        )
        .toList(growable: false);

    final comparator = widget.selectorConfig.countryComparator;
    final sorted = values.toList();
    if (comparator != null) {
      sorted.sort(comparator);
    } else {
      sorted.sort((a, b) => a.name.compareTo(b.name));
    }

    _countries = sorted;
    if (_countries.isEmpty) {
      _country = null;
      return;
    }

    final requestedIso = (preferredIso ?? widget.initialValue?.isoCode)
        ?.trim()
        .toUpperCase();
    _country = _findCountry(requestedIso) ??
        _findCountry('US') ??
        _countries.first;
  }

  Country? _findCountry(String? isoCode) {
    if (isoCode == null || isoCode.isEmpty) {
      return null;
    }
    for (final country in _countries) {
      if (country.alpha2Code == isoCode.toUpperCase()) {
        return country;
      }
    }
    return null;
  }

  void _applyInitialValue() {
    final initial = widget.initialValue;
    if (initial == null ||
        initial.phoneNumber == null ||
        initial.phoneNumber!.trim().isEmpty) {
      return;
    }

    final iso = initial.isoCode?.toUpperCase() ?? _country?.alpha2Code;
    try {
      final parsed = _phoneUtil.parse(initial.phoneNumber, iso);
      final national = _phoneUtil.format(parsed, dlib.PhoneNumberFormat.national);
      _setControllerText(widget.formatInput ? national : _digitsOnly(national));
    } on Object {
      _setControllerText(initial.parseNumber());
    }
  }

  void _handleControllerChanged() {
    if (_internalControllerChange || _country == null) {
      return;
    }

    final raw = _controller.text;
    if (widget.formatInput && raw.isNotEmpty) {
      final formatted = _formatAsYouType(raw);
      if (formatted != raw) {
        _setControllerText(formatted);
      }
    }

    final resolved = _resolveNumber(_controller.text);
    final valid = resolved.$2;
    if (_lastValid != valid && mounted) {
      setState(() => _lastValid = valid);
    } else {
      _lastValid = valid;
    }

    widget.onInputChanged?.call(resolved.$1);
    widget.onInputValidated?.call(valid);
  }

  void _setControllerText(String value) {
    _internalControllerChange = true;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _internalControllerChange = false;
  }

  String _formatAsYouType(String input) {
    final country = _country;
    if (country == null) {
      return input;
    }

    final normalized = _normalizeInput(input);
    if (normalized.isEmpty) {
      return '';
    }

    try {
      final formatter = _phoneUtil.getAsYouTypeFormatter(country.alpha2Code);
      var output = '';
      for (final rune in normalized.runes) {
        output = formatter.inputDigit(String.fromCharCode(rune));
      }
      return output;
    } on Object {
      return normalized;
    }
  }

  String _normalizeInput(String input) {
    final stripped = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (stripped.isEmpty) {
      return '';
    }
    if (stripped.startsWith('+')) {
      return '+${stripped.substring(1).replaceAll('+', '')}';
    }
    return stripped.replaceAll('+', '');
  }

  String _digitsOnly(String input) => input.replaceAll(RegExp(r'[^0-9+]'), '');

  (PhoneNumber, bool) _resolveNumber(String input) {
    final country = _country;
    if (country == null) {
      return (PhoneNumber(phoneNumber: input), false);
    }

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return (
        PhoneNumber(
          phoneNumber: '',
          dialCode: country.dialCode,
          isoCode: country.alpha2Code,
        ),
        widget.ignoreBlank,
      );
    }

    try {
      final parsed = _phoneUtil.parse(trimmed, country.alpha2Code);
      final valid = _phoneUtil.isValidNumber(parsed);
      final region = _phoneUtil.getRegionCodeForNumber(parsed);
      return (
        PhoneNumber(
          phoneNumber: _phoneUtil.format(parsed, dlib.PhoneNumberFormat.e164),
          dialCode: '+${parsed.countryCode}',
          isoCode: region ?? country.alpha2Code,
        ),
        valid,
      );
    } on Object {
      final normalized = _normalizeInput(trimmed);
      final fallback = normalized.startsWith('+')
          ? normalized
          : '${country.dialCode}$normalized';
      return (
        PhoneNumber(
          phoneNumber: fallback,
          dialCode: country.dialCode,
          isoCode: country.alpha2Code,
        ),
        false,
      );
    }
  }

  String? _validate(String? value) {
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    final current = value ?? '';
    if (current.trim().isEmpty && widget.ignoreBlank) {
      return null;
    }
    return _resolveNumber(current).$2 ? null : widget.errorMessage;
  }

  void _selectCountry(Country country) {
    if (_country == country) {
      return;
    }
    setState(() => _country = country);
    if (_controller.text.isNotEmpty && widget.formatInput) {
      _setControllerText(_formatAsYouType(_controller.text));
    }
    _handleControllerChanged();
  }

  Future<void> _openCountrySelector() async {
    if (!widget.isEnabled || _countries.isEmpty) {
      return;
    }

    final picker = _CountryPicker(
      countries: _countries,
      selected: _country,
      showFlags: widget.selectorConfig.showFlags &&
          widget.selectorConfig.useEmoji,
      autoFocus: widget.autoFocusSearch,
      searchBoxDecoration: widget.searchBoxDecoration,
    );

    final Country? selected;
    switch (widget.selectorConfig.selectorType) {
      case PhoneInputSelectorType.BOTTOM_SHEET:
        selected = await showModalBottomSheet<Country>(
          context: context,
          isScrollControlled: widget.countrySelectorScrollControlled,
          useSafeArea: widget.selectorConfig.useBottomSheetSafeArea,
          builder: (context) => SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
            child: picker,
          ),
        );
      case PhoneInputSelectorType.DIALOG:
        selected = await showDialog<Country>(
          context: context,
          builder: (context) => Dialog(
            constraints: const BoxConstraints(maxWidth: 560, minHeight: 360),
            child: SizedBox(height: 560, child: picker),
          ),
        );
      case PhoneInputSelectorType.DROPDOWN:
        return;
    }

    if (selected != null && mounted) {
      _selectCountry(selected);
    }
  }

  Widget _selectorContents({required bool inputButton}) {
    final country = _country;
    if (country == null) {
      return const SizedBox.shrink();
    }

    final config = widget.selectorConfig;
    final showConfiguredFlag = inputButton
        ? (config.showInputFlag ?? config.showFlags)
        : config.showFlags;
    final showFlag = showConfiguredFlag && config.useEmoji;
    final dialCode = config.trailingSpace && country.dialCode.length <= 2
        ? '${country.dialCode} '
        : country.dialCode;

    return Padding(
      padding: EdgeInsets.only(left: config.leadingPadding ?? 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFlag) ...[
            Text(country.emoji, style: widget.selectorTextStyle),
            const SizedBox(width: 8),
          ],
          Text(dialCode, style: widget.selectorTextStyle),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    if (widget.selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN) {
      return PopupMenuButton<Country>(
        enabled: widget.isEnabled,
        tooltip: 'Select country',
        onSelected: _selectCountry,
        itemBuilder: (context) => _countries
            .map(
              (country) => PopupMenuItem<Country>(
                value: country,
                child: Row(
                  children: [
                    if (widget.selectorConfig.showFlags &&
                        widget.selectorConfig.useEmoji) ...[
                      Text(country.emoji),
                      const SizedBox(width: 10),
                    ],
                    Expanded(child: Text(country.name)),
                    const SizedBox(width: 12),
                    Text(country.dialCode),
                  ],
                ),
              ),
            )
            .toList(growable: false),
        child: _selectorContents(inputButton: true),
      );
    }

    return TextButton(
      onPressed: widget.isEnabled ? _openCountrySelector : null,
      child: _selectorContents(inputButton: true),
    );
  }

  InputDecoration _buildDecoration({Widget? prefixIcon}) {
    final base = widget.inputDecoration ?? const InputDecoration();
    return base.copyWith(
      hintText: base.hintText ?? _resolvedHintText(),
      border: base.border ?? widget.inputBorder,
      prefixIcon: prefixIcon ?? base.prefixIcon,
    );
  }

  String? _resolvedHintText() {
    final explicit = widget.hintText;
    final country = _country;
    if (country == null || widget.hintCharacter == null) {
      return explicit;
    }

    try {
      final example = _phoneUtil.getExampleNumber(country.alpha2Code);
      if (example == null) {
        return explicit;
      }
      final national =
          _phoneUtil.format(example, dlib.PhoneNumberFormat.national);
      return national.replaceAll(RegExp(r'[0-9]'), widget.hintCharacter!);
    } on Object {
      return explicit;
    }
  }

  Widget _buildTextField({Widget? prefixIcon}) {
    final formatters = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
      LengthLimitingTextInputFormatter(widget.maxLength + 1),
    ];

    return TextFormField(
      key: widget.fieldKey,
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.isEnabled,
      autofocus: widget.autoFocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.keyboardAction,
      inputFormatters: formatters,
      style: widget.textStyle,
      cursorColor: widget.cursorColor,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      scrollPadding: widget.scrollPadding,
      autofillHints: widget.autofillHints,
      autovalidateMode: widget.autoValidateMode,
      decoration: _buildDecoration(prefixIcon: prefixIcon),
      validator: _validate,
      onEditingComplete: widget.onSubmit,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: (value) => widget.onSaved?.call(_resolveNumber(value ?? '').$1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selector = _buildSelector();

    if (widget.selectorConfig.setSelectorButtonAsPrefixIcon) {
      return _buildTextField(prefixIcon: selector);
    }

    final bottomPadding =
        _controller.text.isNotEmpty && !_lastValid
            ? widget.selectorButtonOnErrorPadding
            : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: selector,
        ),
        SizedBox(width: widget.spaceBetweenSelectorAndTextField),
        Expanded(child: _buildTextField()),
      ],
    );
  }
}

class _CountryPicker extends StatefulWidget {
  const _CountryPicker({
    required this.countries,
    required this.selected,
    required this.showFlags,
    required this.autoFocus,
    required this.searchBoxDecoration,
  });

  final List<Country> countries;
  final Country? selected;
  final bool showFlags;
  final bool autoFocus;
  final InputDecoration? searchBoxDecoration;

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final visible = normalizedQuery.isEmpty
        ? widget.countries
        : widget.countries
            .where(
              (country) =>
                  country.name.toLowerCase().contains(normalizedQuery) ||
                  country.alpha2Code.toLowerCase().contains(normalizedQuery) ||
                  country.alpha3Code.toLowerCase().contains(normalizedQuery) ||
                  country.dialCode.contains(normalizedQuery),
            )
            .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            autofocus: widget.autoFocus,
            decoration: widget.searchBoxDecoration ??
                const InputDecoration(
                  hintText: 'Search country',
                  prefixIcon: Icon(Icons.search),
                ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No countries found'))
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final country = visible[index];
                      return ListTile(
                        selected: country == widget.selected,
                        leading:
                            widget.showFlags ? Text(country.emoji) : null,
                        title: Text(country.name),
                        subtitle: Text(country.alpha2Code),
                        trailing: Text(country.dialCode),
                        onTap: () => Navigator.of(context).pop(country),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
