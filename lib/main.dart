// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Binary to Decimal',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple.shade300,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 500,
              child: BinaryToDecimal(),
            ),
          ),
        ),
      ),
    );
  }
}

class BinaryToDecimal extends StatefulWidget {
  const BinaryToDecimal({super.key});

  @override
  State<BinaryToDecimal> createState() => _BinaryToDecimalState();
}

class _BinaryToDecimalState extends State<BinaryToDecimal> {
  TextEditingController binController = TextEditingController();
  int decimal = 0;
  bool isDeleteHover = false;
  bool isPasteHover = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    binController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void addBinaryDigit(String digit) {
    setState(() {
      binController.text += digit;
      decimal = binaryToDecimal(binController.text);
      focusNode.requestFocus();
    });
  }

  void clearTextField() {
    if (binController.text.isNotEmpty) {
      setState(() {
        binController.text =
            binController.text.substring(0, binController.text.length - 1);
        decimal = binaryToDecimal(binController.text);
        focusNode.requestFocus();
      });
    }
  }

  void _getClipboardText() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text ?? "";
    if (_isNumeric(clipboardText)) {
      setState(() {
        binController.text += clipboardText;
        decimal = binaryToDecimal(binController.text);
        focusNode.requestFocus();
      });
    } else {
      if (!mounted) return;
      if (kIsWeb) {
        js.context.callMethod('alert', ['Clipboard not number']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard not number'),
          ),
        );
      }
    }
  }

  bool _isNumeric(String? str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void handleRawKeyDownEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        addBinaryDigit('1');
      } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
        addBinaryDigit('0');
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        clearTextField();
      } else if (event.isMetaPressed &&
          event.logicalKey == LogicalKeyboardKey.keyV) {
        _getClipboardText();
      }
    }
  }

  int binaryToDecimal(String binary) {
    int decimal = 0;
    int power = 0;

    for (int i = binary.length - 1; i >= 0; i--) {
      int digit = int.parse(binary[i]);
      decimal += digit * (1 << power);
      power++;
    }

    return decimal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Decimal: $decimal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: focusNode,
                    onKey: handleRawKeyDownEvent,
                    child: TextField(
                      controller: binController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Enter a binary number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        decimal = binaryToDecimal(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onHover: (value) {
                    setState(() {
                      isDeleteHover = value;
                    });
                  },
                  child: Tooltip(
                    onTriggered: () {
                      isDeleteHover = true;
                    },
                    message: 'Delete',
                    waitDuration: const Duration(milliseconds: 200),
                    child: IconButton.filledTonal(
                      onPressed: () {
                        clearTextField();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onHover: (value) {
                    setState(() {
                      isDeleteHover = value;
                    });
                  },
                  child: Tooltip(
                    onTriggered: () {
                      isPasteHover = true;
                    },
                    message: 'Paste',
                    waitDuration: const Duration(milliseconds: 200),
                    child: IconButton.filledTonal(
                      onPressed: () {
                        _getClipboardText();
                      },
                      icon: const Icon(Icons.paste_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    addBinaryDigit('1');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    child: Text(
                      '1',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    addBinaryDigit('0');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    child: Text(
                      '0',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
