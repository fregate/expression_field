import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

import 'keybd.dart';

class ExpressionField extends StatefulWidget {
  const ExpressionField({
    Key? key,
    this.focusNode,
    this.decoration,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled,
    this.style,
    this.autofocus = false,
  }) : super(key: key);

  final InputDecoration? decoration;
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool? enabled;
  final TextStyle? style;
  final bool autofocus;

  @override
  _ExpressionFieldState createState() => _ExpressionFieldState();
}

class _ExpressionFieldState extends State<ExpressionField>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final _keyboardSlideController = AnimationController(
    duration: const Duration(milliseconds: 250),
    vsync: this,
  );
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();

    _keyboardSlideController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      } else if (status == AnimationStatus.completed) {
        // _showFieldOnScreen();
      }
    });
  }

  void _closeKeyboard() {
    _keyboardSlideController.reverse();
  }

  void _openKeyboard(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return ExpressionKeyboard(
          controller: _controller,
          onDismiss: _closeKeyboard,
        );
      },
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _handleFocusChanged(BuildContext context, {required bool open}) {
    if (!open) {
      _keyboardSlideController.reverse();
    } else {
      _openKeyboard(context);
      _keyboardSlideController.forward(from: 0);
    }

    setState(() {
      // Mark as dirty in order to respond to the focus node update.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (primary) => _handleFocusChanged(context, open: primary),
      child: TextFormField(
        enabled: widget.enabled,
        style: widget.style,
        focusNode: widget.focusNode,
        controller: _controller,
        showCursor: true,
        readOnly: true,
        decoration: widget.decoration,
        autofocus: widget.autofocus,
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _keyboardSlideController.dispose();
    super.dispose();
  }
}

class ExpressionFormField extends FormField<String> {
  ExpressionFormField({
    Key? key,
    this.controller,
    FocusNode? focusNode,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    AutovalidateMode? autovalidateMode = AutovalidateMode.disabled,
    bool? enabled,
    TextStyle? style,
    bool autofocus = false,
  }) : super(
            key: key,
            initialValue: controller != null ? controller.text : '',
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Wrong math expression";
              }
              try {
                final v = value.interpret();
                return validator?.call(v.toString());
              } catch (e) {
                return "Wrong math expression";
              }
            },
            autovalidateMode: autovalidateMode,
            onSaved: (String? value) =>
                onSaved?.call(value?.interpret().toString()),
            builder: (FormFieldState<String> field) {
              final state = field as _ExpressionFormFieldState;
              void onChangedHandler(String value) {
                field.didChange(value);
                if (onChanged != null) {
                  onChanged(value);
                }
              }

              return ExpressionField(
                autofocus: autofocus,
                enabled: enabled,
                style: style,
                controller: state._controller,
                focusNode: focusNode,
                decoration: decoration.copyWith(errorText: field.errorText),
                onChanged: onChangedHandler,
              );
            });

  final TextEditingController? controller;

  @override
  _ExpressionFormFieldState createState() => _ExpressionFormFieldState();
}

class _ExpressionFormFieldState extends FormFieldState<String> {
  late TextEditingController _controller;

  @override
  ExpressionFormField get widget => super.widget as ExpressionFormField;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = TextEditingController();
    } else {
      _controller = widget.controller!;
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(ExpressionFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        widget.controller!.addListener(_handleControllerChanged);
        _controller = widget.controller!;
      } else if (widget.controller == null) {
        oldWidget.controller!.removeListener(_handleControllerChanged);
        _controller = TextEditingController();
      } else {
        oldWidget.controller!.removeListener(_handleControllerChanged);
        widget.controller!.addListener(_handleControllerChanged);
        _controller = widget.controller!;
      }
      setValue(_controller.text);
    }
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    // todo: allow changing the value from outside of the controller.
  }

  @override
  void reset() {
    // setState will be called in the superclass, so even though state is being
    // manipulated, no setState call is needed here.
    _controller.clear();
    super.reset();
  }

  void _handleControllerChanged() {
    if (_controller.text != value) {
      didChange(_controller.text);
    }
  }
}
