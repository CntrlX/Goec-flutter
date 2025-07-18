import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/Controller/loginpage_controller.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';

class AppTextField extends GetView<LoginPageController> {
  final String hintText;
  final Widget icon;
  final TextInputType keyboardtype;
  final TextEditingController Controller;
  final void Function(String) onChanged;
  final void Function()? onTap;
  final Color color;
  AppTextField(
      {Key? key,
      required this.hintText,
      required this.icon,
      required this.keyboardtype,
      required this.Controller,
      required this.onChanged,
      required this.color,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        left: size.width * 0.07,
        right: size.width * 0.07,
      ),
      height: size.height * 0.08,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(70),
        border: Border.all(
          width: 2,
          color: color,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.04,
            width: size.width * 0.05,
            alignment: Alignment.center,
            child: icon,
          ),
          SizedBox(
            width: size.width * 0.04,
          ),
          Form(
            child: Container(
              height: size.height * 0.065,
              width: size.width * 0.5,
              child: TextFormField(
                controller: Controller,
                onChanged: onChanged,
                onTap: onTap,
                keyboardType: keyboardtype,
                // maxLines: 1,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),

                decoration: InputDecoration(
                  hintText: hintText,
                  isDense: true,
                  isCollapsed: false,
                  contentPadding: EdgeInsets.only(top: 15.5.h, bottom: 15.5.h),
                  hintStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff828282),
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
