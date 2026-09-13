//Add Invoice Details Page
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Controller/addInvoice_page_controller.dart';
import '../../Utils/toastUtils.dart';
import '../../constants.dart';
import '../Widgets/apptext.dart';
import '../Widgets/customText.dart';
import '../Widgets/phonenumtext_field.dart';

class AddInvoiceDetails extends GetView<AddInvoiceDetailsController> {
  const AddInvoiceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kscaffoldBackgroundColor2,
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Obx(() => Container(
                padding: EdgeInsets.all(0.0 + 0 * controller.reload.value))),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * .062, vertical: size.height * .03),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                            padding: EdgeInsets.all(5),
                            child: SvgPicture.asset(
                                'assets/svg/arrow_back_ios.svg'))),
                    width(14.w),
                    Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            child: CustomText(
                                text: 'Invoice Details',
                                size: 15,
                                color: Color(0xff828282),
                                fontWeight: FontWeight.bold))),
                    TextButton(
                        onPressed: () {
                          controller.onClear();
                        },
                        child: CustomBigText(
                          text: "Clear",
                          size: 15,
                          color: kOnboardingColors,
                        )),
                    //width(24)
                  ],
                )),

            height(size.height * 0.02),
            EditTextField(
              size: size,
              controller: controller.companyNameController,
              hintText: 'Company Name',
            ),
            //height(size.height * 0.01),
            PhoneNumberTextFieldSlim(
                hintText: "Phone Number",
                controller1: controller.phnNumberController),
            //height(size.height * 0.002),

            // EditTextField(
            //   size: size,
            //   controller: controller.cityNameController,
            //   hintText: 'City',
            // ),
            //height(size.height * 0.01),
            EditTextField(
              size: size,
              controller: controller.postalCodeController,
              hintText: 'Postal Code',
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * .08,
                    vertical: size.height * 0.008),
                child: Obx(
                  () => Container(
                    width: size.width + 0 * controller.reload.value,
                    height: size.height * 0.073,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          width: 1,
                          color: Color.fromARGB(255, 158, 158, 158),
                        )),
                    child: DropdownButton<String>(
                      value: controller.selectedState,
                      hint: Text(
                        'State',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 155, 154, 154),
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff4F4F4F),
                      ),
                      dropdownColor: kwhite,
                      isExpanded: true,
                      elevation: 0,
                      underline: SizedBox(),
                      items: controller.states
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          child: Text(value),
                          value: value,
                        );
                      }).toList(),
                      icon:
                          SvgPicture.asset("assets/svg/arrow_downward_ios.svg"),
                      onChanged: (String? value) {
                        controller.onChangeStateGetCityList(value);
                      },
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                )),

            //height(size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * .08, vertical: size.height * 0.008),
              child: Obx(
                () => Container(
                  width: size.height + 0 * controller.reload.value,
                  height: size.height * 0.073,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        width: 1,
                        color: Color.fromARGB(255, 158, 158, 158),
                      )),
                  child: DropdownButton<String>(
                    value: controller.selectedCity,
                    hint: Text(
                      'City',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 155, 154, 154),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff4F4F4F),
                    ),
                    dropdownColor: kwhite,
                    isExpanded: true,
                    elevation: 0,
                    underline: SizedBox(),
                    items: controller.stateCitys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    icon: SvgPicture.asset("assets/svg/arrow_downward_ios.svg"),
                    onChanged: (String? val) {
                      controller.onChangeCity(val);
                    },
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ),

            // EditTextField(
            //   size: size,
            //   controller: controller.stateNameController,
            //   hintText: 'State',
            // ),
            //height(size.height * 0.01),
            EditTextField(
              size: size,
              controller: controller.countryNameController,
              hintText: 'Country',
            ),
            //height(size.height * 0.01),
            EditTextField(
              size: size,
              controller: controller.gstNoController,
              hintText: 'GST No',
            ),

            Center(
                child: Padding(
              padding: EdgeInsets.only(top: 50.h, bottom: 10.h),
              child: SaveButton(onTaop: () {
                controller.onSave();
              }),
            )),
          ]),
        ),
      ),
    );
  }
}

// Text Field
Widget EditTextField({
  required TextEditingController controller,
  required String hintText,
  required Size size,
  Widget? icon,
  bool enabled = true,
}) {
  Color borderColor = Color.fromARGB(255, 158, 158, 158);
  Color focusedBorderColor = Color.fromARGB(255, 62, 119, 216);
  RxString errorText = ''.obs;
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: size.width * .08, vertical: size.height * 0.008),
    child: Container(
      width: size.width,
      child: Obx(
        () => Column(
          children: [
            TextField(
              controller: controller,
              enabled: enabled,
              onTapOutside: (event) => {
                if (controller.text.isEmpty)
                  {
                    errorText.value = "Please Enter",
                    focusedBorderColor = Colors.red,
                    borderColor = Colors.red
                  },
              },
              onChanged: (value) => {
                if (value.isEmpty)
                  {
                    errorText.value = "Please Enter",
                    focusedBorderColor = Colors.red,
                    borderColor = Colors.red
                  }
                else
                  {
                    errorText.value = "",
                    focusedBorderColor = Color.fromARGB(255, 62, 119, 216),
                    borderColor = Color.fromARGB(255, 158, 158, 158)
                  }
              },
              style: TextStyle(
                color: Color(0xff828282),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                contentPadding: EdgeInsets.only(left: 20, bottom: 17, top: 17),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: focusedBorderColor, width: 2)),
                prefixIcon: icon == null
                    ? null
                    : Container(
                        width: 20,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        alignment: Alignment.center,
                        child: icon,
                      ),
              ),
            ),
            errorText.value != ""
                ? Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: CustomBigText(
                          text: "${errorText.value} $hintText",
                          size: 10,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                : Center(),
          ],
        ),
      ),
    ),
  );
}

//Save Button
class SaveButton extends StatelessWidget {
  final Function onTaop;
  const SaveButton({super.key, required this.onTaop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTaop(),
      child: Container(
        height: size.height * .067,
        width: size.width * .65,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40), color: kOnboardingColors),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.save_outlined, color: Color(0xffFFFFFF)),
          width(size.width * .02),
          CustomText(
              text: 'Save',
              color: Color(0xffFFFFFF),
              size: 14,
              fontWeight: FontWeight.bold)
        ]),
      ),
    );
  }
}
