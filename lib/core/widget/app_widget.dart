import 'package:absen_smkn1_punggelan/core/di/dependency.dart';
import 'package:absen_smkn1_punggelan/core/helper/dialog_helper.dart';
import 'package:absen_smkn1_punggelan/core/provider/app_provider.dart';
import 'package:absen_smkn1_punggelan/core/widget/error_app_widget.dart';
import 'package:absen_smkn1_punggelan/core/widget/loading_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AppWidget<T extends AppProvider, P1, P2>
    extends StatelessWidget {
  AppWidget({super.key, this.param1, this.param2});

  T? _notifier;
  T get notifier => _notifier!;
  final P1? param1;
  final P2? param2;
  FilledButton? _alternatifErrorButton;

  set alternatifErrorButton(FilledButton? param) =>
      _alternatifErrorButton = param;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => sl(param1: param1, param2: param2),
      builder: (context, child) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    _notifier = Provider.of<T>(context);
    checkVariableBeforeUi(context);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (notifier.snackbarMessage.isNotEmpty) {
          DialogHelper.showSnackbar(
              context: context, text: notifier.snackbarMessage);
          notifier.snackbarMessage = '';
        }

        checkVariableAfterUi(context);
      },
    );

    return Scaffold(
      appBar: appBarBuild(context),
      body: (notifier.isLoading)
          ? LoadingAppWidget()
          : (notifier.errorMessage.isNotEmpty)
              ? ErrorAppWidget(
                  message: notifier.errorMessage,
                  alternatifButton: _alternatifErrorButton,
                  onRetry: () {
                    notifier.errorMessage = '';
                    onRetry(context);
                  },
                )
              : bodyBuild(context),
    );
  }

  PreferredSizeWidget? appBarBuild(BuildContext context) => null;

  Widget bodyBuild(BuildContext context);

  void checkVariableBeforeUi(BuildContext context) {}

  void checkVariableAfterUi(BuildContext context) {}

  void onRetry(BuildContext context) {}
}
