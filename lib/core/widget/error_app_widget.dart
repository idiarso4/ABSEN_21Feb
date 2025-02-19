import 'package:absen_smkn1_punggelan/core/helper/global_helper.dart';
import 'package:flutter/material.dart';

class ErrorAppWidget extends StatelessWidget {
  final String message;
  final void Function() onRetry;
  final FilledButton? alternatifButton;

  const ErrorAppWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.alternatifButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 100,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            message,
            style: GlobalHelper.getTextStyle(context,
                appTextStyle: AppTextStyle.HEADLINE_SMALL),
          ),
          const SizedBox(
            height: 30,
          ),
          alternatifButton ??
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
        ],
      ),
    );
  }
}
