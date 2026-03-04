import 'package:flutter/material.dart';

class InputTextWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final IconData? icondata;
  final String? assetReference;
  final String labelString;
  final bool isObscure;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const InputTextWidget({
    super.key,
    required this.textEditingController,
    this.icondata,
    this.assetReference,
    required this.labelString,
    required this.isObscure,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextFormField( 
        controller: textEditingController,
        obscureText: isObscure,
        validator: validator, 
        decoration: InputDecoration(
          labelText: labelString,

          prefixIcon: icondata != null
              ? Icon(icondata)
              : assetReference != null
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.network(assetReference!, width: 20),
                    )
                  : null,

          suffixIcon: suffixIcon,

          labelStyle: const TextStyle(fontSize: 18),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.blueGrey),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.blueGrey),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}