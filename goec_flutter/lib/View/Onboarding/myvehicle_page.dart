import 'package:get/get.dart';
import '../../constants.dart';
import '../Widgets/appbar.dart';
import '../../Utils/routes.dart';
import '../Widgets/apptext.dart';
import '../../Utils/toastUtils.dart';
import 'package:flutter/material.dart';
import '../../Model/vehicleModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Widgets/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer_app/View/Widgets/appbutton.dart';
import 'package:freelancer_app/View/Widgets/customText.dart';
import 'package:freelancer_app/Controller/my_vehicles_screen_controller.dart';

class MyVehiclePage extends GetView<MyVehiclesScreenController> {
  const MyVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.09),
        child: CustomAppBar(
          backButton: Get.arguments != 'isFirstTime'
              ? InkWell(
                  onTap: () {
                    Get.offAllNamed(Routes.homePageRoute);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      'assets/svg/arrow_back_ios.svg',
                      colorFilter: ColorFilter.mode(kwhite, BlendMode.srcIn),
                    ),
                  ),
                )
              : null,
          logo: CustomBigText(
            text: "My Vehicle",
            size: 15.sp,
            color: Color(0xffF2F2F2),
          ),
          icon: Image.asset("assets/images/add.png"),
          icononTap: () {
            Get.offNamed(Routes.addvehiclesRoute);
          },
          skiponTap: () {
            Get.offNamed(Routes.addvehiclesRoute);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.045,
            right: size.width * 0.045,
            top: size.height * 0.020,
            bottom: size.height * 0.045,
          ),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Expanded(
                child: Obx(
                  () => (controller.myVehicleList.isEmpty)
                      ? Align(
                          alignment: Alignment.center,
                          child: CustomText(text: 'No Vehicles Available'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.myVehicleList.length,
                          itemBuilder: ((context, index) {
                            controller.myVehicleList
                                .where((p0) => p0.defaultVehicle)
                                .toList();
                            // kLog(controller.myVehicleList[index].id.toString());
                            // if (def.isNotEmpty && index == 0) {
                            //   return _myVehicle(def[0]);
                            // } else {
                            //   return controller.myVehicleList[index]
                            //               .defaultVehicle ==
                            //           'Y'
                            //       ? Container()
                            //       : _myVehicle(controller.myVehicleList[index]);
                            // }
                            return _myVehicle(controller.myVehicleList[index]);
                          }),
                        ),
                ),
              ),
              StartedButton(
                onTap: () {
                  Get.offAllNamed(Routes.homePageRoute);
                },
                color: Color(0xff0047C3),
                text: Get.arguments == 'isFirstTime' ? 'Finished' : "Confirm",
                textColor: Color(0xffF2F2F2),
                isIcon: true,
                iconColor: Color(0xffF2F2F2),
              ),
              // LoginButton(color: Color(0xff0047C3), text: "Get Charged"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _myVehicle(VehicleModel model) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: size.height * .16,
        padding: EdgeInsets.all(5.w),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: model.defaultVehicle ? Color(0xffEFFFF6) : kwhite,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 2,
            color: model.defaultVehicle
                ? Color.fromRGBO(135, 221, 171, 0.6)
                : Color(0xffE0E0E0),
          ),
        ),
        child: InkWell(
          onTap: () {
            controller.setAsDefaultVehicle(model);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              width(5.w),
              cachedNetworkImage(
                model.icon,
                width: 120.w,
              ),
              width(5.w),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomSmallText(
                            text: model.brand,
                            color: Color(0xff828282),
                          ),
                          CustomBigText(
                            text: model.modelName,
                            size: 16,
                            color: Color(0xff4F4F4F),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CustomBigText(
                          text: "Vehicle No: ",
                          size: 14.sp,
                        ),
                        width(5.w),
                        Expanded(
                          child: CustomBigText(
                            text: model.evRegNumber,
                            size: 14.sp,
                            color: Color(0xff333333),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: model.compactable_port.length,
                        itemBuilder: ((context, index1) => Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 22,
                                margin: EdgeInsets.only(right: 5.w),
                                color: Color.fromRGBO(184, 210, 255, 0.6),
                                child: Center(
                                  child: CustomSmallText(
                                    text: model.compactable_port[index1],
                                    color: Color(0xff0047C3),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
