import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApprovalAcceptResult {
  final String note;
  final bool allowPreviousActivity;

  const ApprovalAcceptResult({
    required this.note,
    required this.allowPreviousActivity,
  });
}

Future<ApprovalAcceptResult?> showApprovalAccept(
    BuildContext context, {
      required String code,
      String? title,
    }) {
  return showDialog<ApprovalAcceptResult>(
    context: context,
    builder: (_) => ApprovalAccept(code: code, title: title ?? context.tr('قبول طلب إعادة الإسناد')),
  );
}

class ApprovalAccept extends StatefulWidget {
  final String code;
  final String title;

  const ApprovalAccept({
    super.key,
    required this.code,
    required this.title,
  });

  @override
  State<ApprovalAccept> createState() => _ApprovalAcceptState();
}

class _ApprovalAcceptState extends State<ApprovalAccept> {
  final _noteController = TextEditingController();
  bool _allowPreviousActivity = false;

  static const Color _green = ColorManager.statusColor1;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.pop(
      context,
      ApprovalAcceptResult(
        note: _noteController.text.trim(),
        allowPreviousActivity: _allowPreviousActivity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final mutedColor = theme.textTheme.bodyMedium?.color;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: theme.dividerColor),
    );

    return Directionality(
      textDirection: context.dir,
      child: Dialog(
        backgroundColor: theme.cardTheme.color ?? theme.dialogBackgroundColor,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 22.sp,
                        color: _green,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s18.sp,
                          fontWeight: FontWeightManager.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.r),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22.sp,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.trArgs('هل أنت متأكد من قبول الطلب {code}؟', {'code': widget.code}),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        color: mutedColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      context.tr('ملاحظة المدير (اختياري)'),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        fontWeight: FontWeightManager.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _noteController,
                      minLines: 5,
                      maxLines: 5,
                      textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr('اكتب ملاحظة المدير...'),
                        hintStyle: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s14.sp,
                          color: mutedColor?.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor:
                        theme.scaffoldBackgroundColor.withOpacity(0.6),
                        contentPadding: EdgeInsets.all(14.r),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(
                            color: ColorManager.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () => setState(
                            () => _allowPreviousActivity = !_allowPreviousActivity,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                          theme.scaffoldBackgroundColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _allowPreviousActivity,
                              activeColor: _green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              onChanged: (v) => setState(
                                    () => _allowPreviousActivity = v ?? false,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                context.tr('السماح للموظف الجديد برؤية النشاط السابق الذي تم على العميل'),
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  fontSize: FontSize.s14.sp,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _GradientButton(
                            label: context.tr('قبول'),
                            icon: Icons.check_rounded,
                            colors: const [
                              ColorManager.statusColor1,
                              Color(0xFF1FA862),
                            ],
                            onTap: _confirm,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
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
                                  fontSize: FontSize.s14.sp,
                                  fontWeight: FontWeightManager.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: colors,
        ),

      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}