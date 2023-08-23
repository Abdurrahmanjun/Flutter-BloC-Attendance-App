import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otaqu/common/utils/colors.dart';
import 'package:otaqu/common/utils/common.dart';

class ForgotPasswordDialog extends StatefulWidget {
  static String tag = '/ForgotPasswordScreen';

  @override
  ForgotPasswordDialogState createState() => ForgotPasswordDialogState();
}

class ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  TextEditingController forgotEmailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Forget Password", style: boldTextStyle(size: 20)),
          8.height,
          Text(
              "A reset password link will be sent to the above enteren email address",
              style: secondaryTextStyle()),
          16.height,
          AppTextField(
            controller: forgotEmailController,
            textFieldType: TextFieldType.EMAIL,
            keyboardType: TextInputType.emailAddress,
            decoration: inputDecoration(
              context,
              label: "Email",
              textStyle: secondaryTextStyle(color: bodyColor),
            ).copyWith(
                prefixIcon: const Icon(Icons.email_outlined).paddingAll(12)),
            errorInvalidEmail: "Enter valid email",
            errorThisFieldRequired: errorThisFieldRequired,
          ),
          16.height,
          AppButton(
            width: context.width(),
            color: navyDark,
            onTap: () {},
            child: Text("RESET PASSWORD",
                style: boldTextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
