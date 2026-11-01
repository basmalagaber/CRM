import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';

class AdherenceCard extends StatelessWidget {
  const AdherenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ColorManager.primaryLightShade,
            ColorManager.primaryColor,
            ColorManager.primaryDarkShade,
          ],
        ),

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            PositionedDirectional(
              top: -40.h,
              end: -30.w,
              child: _Bubble(size: 130.r, opacity: 0.10),
            ),
            PositionedDirectional(
              bottom: -50.h,
              start: -20.w,
              child: _Bubble(size: 110.r, opacity: 0.08),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نسبة الالتزام بالمتابعة',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white.withOpacity(.9),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          '٪ --.-',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'لا توجد تأخيرات مفتوحة اليوم',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              color: Colors.white.withOpacity(.9),
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,

                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: ColorManager.primaryColor,
                      size: 32.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}