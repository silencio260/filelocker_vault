import 'package:flutter/material.dart';

class PinInputController extends ChangeNotifier {
  final int pinLength;
  String _pin = '';

  PinInputController({this.pinLength = 6});

  String get pin => _pin;
  bool get isFull => _pin.length >= pinLength;

  void addDigit(String digit) {
    if (_pin.length < pinLength) {
      _pin += digit;
      notifyListeners();
    }
  }

  void removeDigit() {
    if (_pin.isNotEmpty) {
      _pin = _pin.substring(0, _pin.length - 1);
      notifyListeners();
    }
  }

  void clear() {
    _pin = '';
    notifyListeners();
  }
}

class PinInputWidget extends StatefulWidget {
  final PinInputController controller;
  final void Function(String pin) onComplete;
  final String? errorText;

  const PinInputWidget({
    super.key,
    required this.controller,
    required this.onComplete,
    this.errorText,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPinChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPinChanged);
    super.dispose();
  }

  void _onPinChanged() {
    setState(() {});
    if (widget.controller.isFull) {
      widget.onComplete(widget.controller.pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PinDots(
          currentLength: widget.controller.pin.length,
          totalLength: widget.controller.pinLength,
          color: theme.colorScheme.primary,
          errorText: widget.errorText,
        ),
        const SizedBox(height: 32),
        _NumPad(controller: widget.controller),
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  final int currentLength;
  final int totalLength;
  final Color color;
  final String? errorText;

  const _PinDots({
    required this.currentLength,
    required this.totalLength,
    required this.color,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalLength, (i) {
            final filled = i < currentLength;
            final dotColor = errorText != null
                ? Theme.of(context).colorScheme.error
                : filled
                    ? color
                    : color.withValues(alpha: 0.3);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            );
          }),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _NumPad extends StatelessWidget {
  final PinInputController controller;

  const _NumPad({required this.controller});

  @override
  Widget build(BuildContext context) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: digits.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 72);
            return _NumKey(
              label: key,
              onTap: () {
                if (key == '⌫') {
                  controller.removeDigit();
                } else {
                  controller.addDigit(key);
                }
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: label == '⌫' ? 22 : 26,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
