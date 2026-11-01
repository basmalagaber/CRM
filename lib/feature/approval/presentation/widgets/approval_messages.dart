import 'dart:typed_data';

import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void addApprovalMessage(
    Map<String, dynamic> approval, {
      required String sender,
      required String text,
      Uint8List? imageBytes,
    }) {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  final time = '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  final date = '${now.year}-${two(now.month)}-${two(now.day)}';

  final list = (approval['messages'] as List?)?.toList() ?? [];
  list.add({
    'sender': sender,
    'date': '$time $date',
    'text': text,
    'image': imageBytes,
    'isMe': true,
  });
  approval['messages'] = list;
}

Future<void> showApprovalMessagesDialog(
    BuildContext context, {
      required Map<String, dynamic> approval,
    }) {
  return showDialog(
    context: context,
    builder: (_) => ApprovalMessagesDialog(approval: approval),
  );
}

class ApprovalMessagesDialog extends StatelessWidget {
  final Map<String, dynamic> approval;

  const ApprovalMessagesDialog({super.key, required this.approval});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = ((approval['messages'] as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: theme.cardTheme.color,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560.w, maxHeight: 600.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: ColorManager.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.forum_outlined,
                        size: 22.sp,
                        color: ColorManager.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'رسائل الطلب',
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s20.sp,
                          fontWeight: FontWeightManager.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.close_rounded,
                          size: 24.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              Flexible(
                child: messages.isEmpty
                    ? Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Text(
                    'لا توجد رسائل لهذا الطلب',
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s16.sp,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16.r),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) =>
                      _MessageCard(message: messages[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final Map<String, dynamic> message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sender = (message['sender'] ?? '').toString();
    final date = (message['date'] ?? '').toString();
    final text = (message['text'] ?? '').toString();
    final image = message['image'] as Uint8List?;
    final isMe = message['isMe'] == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isMe
              ? ColorManager.primaryColor.withOpacity(0.5)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s16.sp,
                        fontWeight: FontWeightManager.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      date,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s12.sp,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'أنا',
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s12.sp,
                      fontWeight: FontWeightManager.bold,
                      color: ColorManager.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            text,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s16.sp,
              height: 1.6,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          if (image != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(
                image,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }
}