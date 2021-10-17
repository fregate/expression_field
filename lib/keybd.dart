import 'package:flutter/material.dart';

typedef DismissFun = void Function();

class _KeyboardOutliner extends CustomPainter {
  final double functionalRowHeight;
  final double functionalRowCount;
  final double numbersRowHeight;
  final double numbersInRowCount;
  final double numbersRowsCount;

  final Color color;

  const _KeyboardOutliner(this.color,
      this.functionalRowHeight,
      this.functionalRowCount,
      this.numbersRowHeight,
      this.numbersInRowCount,
      this.numbersRowsCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 0.5
      ..color = color;

    // draw functional row dividers
    for (var idx = 1; idx < functionalRowCount; idx++) {
      canvas.drawLine(
          Offset(size.width / functionalRowCount * idx, 0),
          Offset(size.width / functionalRowCount * idx, functionalRowHeight),
          paint);
    }

    // draw numbers dividers
    for (var idx = 1; idx < numbersInRowCount; idx++) {
      canvas.drawLine(
          Offset(size.width / numbersInRowCount * idx, functionalRowHeight),
          Offset(size.width / numbersInRowCount * idx, size.height),
          paint);
    }

    for (var idx = 1; idx < numbersRowsCount; idx++) {
      canvas.drawLine(
          Offset(0, functionalRowHeight + numbersRowHeight * idx),
          Offset(size.width, functionalRowHeight + numbersRowHeight * idx),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ExpressionKeyboard extends StatelessWidget {
  const ExpressionKeyboard({
    Key? key,
    required this.controller,
    this.slideAnimation,
    this.onDismiss,
  }) : super(key: key);

  final TextEditingController controller;
  final Animation<double>? slideAnimation;

  final double _functionalRowHeight = 32;
  final double _functionalRowCount = 5;
  final double _numbersRowHeight = 64;
  final double _numbersInRowCount = 3;
  final double _numbersRowsCount = 4;

  final DismissFun? onDismiss;

  void _handleButtonPress(String symbol) {
    final text = controller.text;
    final textSelection = controller.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      symbol,
    );
    final myTextLength = symbol.length;
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void _handleBackspace() {
    final text = controller.text;
    final textSelection = controller.selection;
    final selectionLength = textSelection.end - textSelection.start;
    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      controller.text = newText;
      controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }
    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }
    // Delete the previous character
    final newStart = textSelection.start - 1;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  void _handleDismissKeyboard() {
    onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            type: MaterialType.transparency,
            child: ColoredBox(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: _functionalRowHeight +
                      _numbersRowsCount * _numbersRowHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        // size: const Size(200, 200),
                        painter: _KeyboardOutliner(
                            const Color(0x0F000000),
                            _functionalRowHeight,
                            _functionalRowCount,
                            _numbersRowHeight,
                            _numbersInRowCount,
                            _numbersRowsCount),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: _functionalRowHeight,
                            child: Container(
                              color: Colors.black12,
                              child: Row(
                                // direction: Axis.horizontal,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                      onPressed: () => _handleButtonPress("+"),
                                      child: const Text('＋')),
                                  TextButton(
                                      onPressed: () => _handleButtonPress("-"),
                                      child: const Text('－')),
                                  TextButton(
                                      onPressed: () => _handleButtonPress("*"),
                                      child: const Text('×')),
                                  TextButton(
                                      onPressed: () => _handleButtonPress("/"),
                                      child: const Text('÷')),
                                  TextButton(
                                      onPressed: () => _handleDismissKeyboard(),
                                      child: const Icon(
                                          Icons.keyboard_arrow_down)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: _numbersRowHeight,
                            child: Row(
                              // direction: Axis.horizontal,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _handleButtonPress("1"),
                                    child: const Text('1'),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _handleButtonPress("2"),
                                    child: const Text('2'),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _handleButtonPress("3"),
                                    child: const Text('3'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: _numbersRowHeight,
                            child: Row(
                              // direction: Axis.horizontal,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("4"),
                                        child: const Text('4'))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("5"),
                                        child: const Text('5'))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("6"),
                                        child: const Text('6'))),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: _numbersRowHeight,
                            child: Row(
                              // direction: Axis.horizontal,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("7"),
                                        child: const Text('7'))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("8"),
                                        child: const Text('8'))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("9"),
                                        child: const Text('9'))),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: _numbersRowHeight,
                            child: Row(
                              // direction: Axis.horizontal,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("."),
                                        child: const Text(','))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () =>
                                            _handleButtonPress("0"),
                                        child: const Text('0'))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () => _handleBackspace(),
                                        child: const Icon(Icons.backspace))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
