import 'package:flutter/material.dart';

class InputTextWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final IconData? icondata;
  final String? assetReference;
  final String labelString;
  final bool isObscure;

  const InputTextWidget({
    super.key,
    required this.textEditingController,
    this.icondata,
    this.assetReference,
    required this.labelString,
    required this.isObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      
    );
  }
}
