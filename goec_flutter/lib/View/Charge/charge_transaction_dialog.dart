import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:freelancer_app/constants.dart';
import 'package:freelancer_app/Utils/utils.dart';
import '../../Model/chargeTransactionModel.dart';
import '../../Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/View/Widgets/apptext.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ChargeTransactionDialog({
  required final ChargeTransactionModel model,
}) {
  final a = 5;
  final b = 4;
  int hour = 0, minute = 0;
  List<int> time = getTimeDifferenceforHistory(
      startTime: model.chargingStartTime, endTime: model.chargingStopTime);
  if (time.length >= 2) {
    hour = time[0];
    minute = time[1];
  } else {
    hour = 0;
    minute = 0;
  }
  return Container(
    height: 600.h,
    width: size.width,
    child: Column(
      children: [
        _reservationAppBar(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30.h,
              ),
              _detailsSection(
                  stationName: model.stationName,
                  stationAddress: model.stationAddress),
              SizedBox(
                height: 35.h,
              ),
              Row(
                children: [
                  Expanded(
                      flex: a,
                      child: _text_title_value(
                        'Date',
                        // model.chargingStartTime
                        getTimeFromTimeStamp(
                            dateFromTimeStamp(model.chargingStartTime),
                            'dd MMM yyyy'),
                      )),
                  Expanded(
                      flex: b,
                      child: _text_title_value('CP ID', model.chargerName)),
                ],
              ),
              height(30.h),
              Row(
                children: [
                  Expanded(
                      flex: a,
                      child: _text_title_value('Tarrif',
                          '$kCurrency ${model.tariff.toStringAsFixed(2)} /kWh')),
                  Expanded(
                      flex: b,
                      child: _text_title_value(
                          'Duration', '$hour hrs $minute min')),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(),
              ),
              Row(
                children: [
                  Expanded(
                      flex: a,
                      child: _text_title_value('Charging fee',
                          '$kCurrency ${(model.amount - model.taxAmount).toStringAsFixed(2)}')),
                  Expanded(
                      flex: b,
                      child: _text_title_value('Tax(${model.tax}%)',
                          '$kCurrency ${model.taxAmount.toStringAsFixed(2)}')),
                ],
              ),
              height(20.h),
              _card(
                  energy: '${model.unitConsumed.toStringAsFixed(2)}',
                  amount: '${model.amount.toStringAsFixed(2)}'),
              Visibility(visible: true, child: height(30.h)),
              Visibility(
                visible: true,
                child: InkWell(
                  onTap: () {
                    /// on download invoice
                    CommonFunctions()
                        .downloadBookingInvoice(model.transactionId);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svg/download.svg'),
                      width(size.width * .02),
                      CustomBigText(
                        text: 'Download invoice',
                        color: Color(0xff0047C3),
                        size: 15,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _card({required String energy, required String amount}) {
  return Container(
    height: 85.h,
    width: double.maxFinite,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(
        width: 1.3.w,
        color: Color(0xff219653),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h, right: 8.w),
                child: Center(
                  child: CustomSmallText(
                    text: "Total Energy",
                    size: 12.sp,
                    // color: Color(0xff0047C3),
                  ),
                ),
              ),
              Row(
                children: [
                  CustomBigText(
                    text: energy,
                    size: 24.sp,
                    color: Color(0xff4F4F4F),
                  ),
                  width(4.w),
                  CustomSmallText(
                    text: "kWh",
                    size: 14.sp,
                  )
                ],
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h, right: 8.w),
                child: Center(
                  child: CustomSmallText(
                    text: "Amount Debited",
                    size: 12.sp,
                    // color: Color(0xff0047C3),
                  ),
                ),
              ),
              Row(
                children: [
                  CustomBigText(
                    text: amount,
                    size: 24.sp,
                    color: Color(0xff4F4F4F),
                  ),
                  width(5.w),
                  CustomSmallText(
                    text: "Coins",
                    size: 14.sp,
                  )
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _reservationAppBar() {
  return Container(
    height: size.height * 0.08,
    decoration: BoxDecoration(
      color: Color(0xffDEEAFF),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.only(left: size.width * 0.04),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.all(8.h),
              child: Icon(
                Icons.arrow_back_ios,
                size: size.width * 0.05,
                color: Color(0xff828282),
              ),
            ),
          ),
          SizedBox(
            width: size.width * 0.01,
          ),
          CustomBigText(
            text: "Charging Summery",
            size: 14,
          )
        ],
      ),
    ),
  );
}

Widget _detailsSection(
    {required final String stationName, required final String stationAddress}) {
  return Container(
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            kaChargingHistory,
            height: size.height * 0.085,
            width: size.width * 0.19,
          ),
        ),
        SizedBox(
          width: size.width * 0.05,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: CustomBigText(
                      text: stationName,
                      size: 16,
                      color: Color(0xff4F4F4F),
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Row(
                children: [
                  Flexible(
                    child: CustomSmallText(
                      text: stationAddress,
                      size: 12,
                      color: Color(0xff4F4F4F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _text_title_value(
  String title,
  String value,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSmallText(
        text: title,
        size: 14.sp,
        color: Color(0xffacacac),
      ),
      height(5.h),
      Text(
        value,
        style: kAppSmallTextStyle.copyWith(
          fontSize: 17,
          color: Color(0xff5C5C5C),
          fontWeight: FontWeight.w600,
        ),
      )
    ],
  );
}
