import 'package:flutter/material.dart';
import '../../Model/chargeTransactionModel.dart';
import 'charging_summary_modal_sheet.dart';

export 'charging_summary_modal_sheet.dart';

/// Legacy wrapper for backwards compatibility if used inside a dialog or container.
Widget ChargeTransactionDialog({
  required final ChargeTransactionModel model,
}) {
  return ChargingSummaryModalContent(model: model);
}
