import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<String?> showApprovalReject(
    BuildContext context, {
      required String code,
    }) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ApprovalReject(code: code),
  );
}

class ApprovalReject extends StatefulWidget {
  final String code;

  const ApprovalReject({super.key, required this.code});

  @override
  State<ApprovalReject> createState() => _ApprovalRejectState();
}

class _ApprovalRejectState extends State<ApprovalReject> {
  static const _red = ColorManager.errorTitle;

  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final mutedColor = theme.textTheme.bodyMedium?.color;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return Directionality(
      textDirection: context.dir,
      child: Dialog(
        backgroundColor: theme.cardTheme.color,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          size: 22.sp,
                          color: _red,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          context.tr('رفض طلب إعادة الإسناد'),
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s20.sp,
                            fontWeight: FontWeightManager.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(Icons.close_rounded,
                              size: 24.sp, color: mutedColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('أدخل سبب رفض الطلب '),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s14.sp,
                              color: mutedColor,
                            ),
                          ),
                          Text(
                            widget.code,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s14.sp,
                              color: mutedColor,
                            ),
                          ),
                          Text(
                            context.tr('.'),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s14.sp,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        context.tr('سبب الرفض'),
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s16.sp,
                          fontWeight: FontWeightManager.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _controller,
                        minLines: 5,
                        maxLines: 7,
                        onChanged: (_) {
                          if (_showError &&
                              _controller.text.trim().isNotEmpty) {
                            setState(() => _showError = false);
                          }
                        },
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s16.sp,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('اكتب سبب الرفض...'),
                          hintStyle: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: mutedColor?.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor:
                          theme.scaffoldBackgroundColor.withOpacity(0.6),
                          contentPadding: EdgeInsets.all(14.r),
                          border: border(theme.dividerColor),
                          enabledBorder: border(
                            _showError ? _red : theme.dividerColor,
                          ),
                          focusedBorder: border(
                            _showError ? _red : ColorManager.primaryColor,
                            1.5,
                          ),
                        ),
                      ),
                      if (_showError) ...[
                        SizedBox(height: 6.h),
                        Text(
                          context.tr('سبب الرفض مطلوب.'),
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s14.sp,
                            color: _red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 20.r),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFFE5456B), Color(0xFFB91C3F)],
                            ),

                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14.r),
                              onTap: _submit,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    context.tr('رفض'),
                                    style: TextStyle(
                                      fontFamily: FontConstants.fontFamily,
                                      fontSize: FontSize.s16.sp,
                                      fontWeight: FontWeightManager.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorManager.primaryColor,
                              side: BorderSide(
                                color: ColorManager.primaryColor
                                    .withOpacity(0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              context.tr('إلغاء'),
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: FontSize.s16.sp,
                                fontWeight: FontWeightManager.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}