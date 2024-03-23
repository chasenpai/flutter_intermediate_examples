import 'package:delivery/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: INPUT_BORDER_COLOR,
        width: 1.0,
      ),
    );

    return TextFormField(
      cursorColor: PRIMARY_COLOR,
      obscureText: obscureText, //비밀번호 등 입력 시
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20), //필드안에 패딩을 추가로 적용할 때
        hintText: hintText, //PlaceHolder
        errorText: errorText,
        hintStyle: TextStyle(
          color: BODY_TEXT_COLOR,
          fontSize: 14.0,
        ),
        fillColor: INPUT_BG_COLOR, //배경색 채우기
        filled: true,
        border: baseBorder, //기본 스타일 -> 왜 적용 안되지?
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: PRIMARY_COLOR,
          ),
        ),
      ),
    );
  }
}
