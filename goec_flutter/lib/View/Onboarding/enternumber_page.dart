import 'package:get/get.dart';
import '../../constants.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/View/Widgets/appbar.dart';
import 'package:freelancer_app/View/Widgets/apptext.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/View/Widgets/appbutton.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:freelancer_app/Controller/loginpage_controller.dart';

class EnterNumberPage extends GetView<LoginPageController> {
  const EnterNumberPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kwhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.09),
        child: CustomAppBar(
            // text: "Skip",
            // icon: Icon(
            //   Icons.arrow_forward,
            //   color: Colors.white,
            // ),
            ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LinearProgressBar(
                    maxSteps: 5,
                    progressType: LinearProgressBar
                        .progressTypeLinear, // Use Linear progress
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xff00FFB3)),
                    currentStep: 1,
                    minHeight: 8.h,
                    progressColor: Color(0xff00FFB3),
                    backgroundColor: Colors.transparent,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.055,

                      // top: size.height * 0.020,
                      // bottom: size.height * 0.045,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.08,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: CustomBigText(
                                text: "Sign up with your Phone Number")),
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        // enterphnnumber button
                        Container(
                          padding: EdgeInsets.only(
                            left: size.width * 0.05,
                          ),
                          height: size.height * 0.1,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                width: 2,
                                color: Color(0xffE0E0E0),
                              )),
                          child: Row(
                            children: [
                              Obx(
                                () {
                                  return InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        favorite: ['IN', 'NP'],
                                        showPhoneCode: true,
                                        onSelect: (Country country) {
                                          controller.country.value =
                                              country.phoneCode;
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "+${controller.country.value}",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        Icon(
                                          Icons.expand_more,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  );
                                },
                                // icon: Container(
                                //     margin: EdgeInsets.only(right: 5),
                                //     height: size.height * 0.03,
                                //     width: size.width * 0.03,
                                //     child:
                                //         Image.asset("assets/images/chevron_left.png")),
                              ),
                              SizedBox(
                                width: size.width * 0.014,
                              ),
                              Container(
                                height: size.height * 0.06,
                                width: size.width * 0.008,
                                color: Color(0xffE0E0E0),
                              ),
                              SizedBox(
                                width: size.width * 0.035,
                              ),
                              Form(
                                child: Container(
                                  height: size.height * 0.065,
                                  width: size.width * 0.5,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.0034),
                                    child: TextFormField(
                                      controller: controller.phoneController,
                                      onChanged: (String value) {
                                        controller.textfield.value = value;
                                      },
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      maxLines: 1,
                                      inputFormatters: [
                                        // LengthLimitingTextInputFormatter(10),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "Phone Number",
                                        hintStyle: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xffBDBDBD),
                                        ),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        height(size.height * .01),
                        // AppTextField(
                        //   color: controller.tempEmailController == true
                        //       ? Color(0xff0047C3)
                        //       : Color(0xffE0E0E0),
                        //   onTap: () {
                        //     controller.mailTextFieldColorChange();
                        //   },
                        //   hintText: "Email",
                        //   icon: Image.asset("assets/images/sms.png"),
                        //   keyboardtype: TextInputType.emailAddress,
                        //   Controller: controller.tempEmailController,
                        //   onChanged: (String val) {},
                        // ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        CustomSmallText(
                            text: "We will send an OTP to verify yor Number"),
                        SizedBox(
                          height: size.height * 0.435,
                        ),
                        SizedBox(
                          height: size.height * 0.08,
                        ),
                        //send OTP button
                        // StartedButton(
                        //   color: Color(0xff0047C3),
                        //   text: "Send OTP",
                        //   textColor: Color(
                        //     0xffF2F2F2,
                        //   ),
                        //   isIcon: true,
                        //   iconColor: Color(0xffF2F2F2),
                        //   onTap: () {
                        //     controller.login();
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.055,
                vertical: size.height * 0.04,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StartedButton(
                      color: Color(0xff0047C3),
                      text: "Send OTP",
                      textColor: Color(
                        0xffF2F2F2,
                      ),
                      isIcon: true,
                      iconColor: Color(0xffF2F2F2),
                      onTap: () {
                        controller.login();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
