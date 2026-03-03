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
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: labelString,
          prefixIcon: icondata != null
              ? Icon(icondata)
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(assetReference!, width: 10),
                ),
          labelStyle: TextStyle(fontSize: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.blueGrey),
          ),       
        ),
        obscureText: isObscure,
      ),
    );
  }
}
