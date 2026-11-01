import 'dart:typed_data';
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showApprovalChatDialog(
    BuildContext context, {
      required Map<String, dynamic> approval,
      required String userName,
      required Future<void> Function(String comment, XFile? image) onSubmit,
    }) {
  return showDialog<void>(
    context: context,
    builder: (_) => ApprovalChatDialog(
      approval: approval,
      userName: userName,
      onSubmit: onSubmit,
    ),
  );
}

const LinearGradient _brandGradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    ColorManager.primaryLightShade,
    ColorManager.primaryColor,
    ColorManager.primaryDarkShade,
  ],
);

class ApprovalChatDialog extends StatefulWidget {
  final Map<String, dynamic> approval;
  final String userName;
  final Future<void> Function(String comment, XFile? image) onSubmit;

  const ApprovalChatDialog({
    super.key,
    required this.approval,
    required this.userName,
    required this.onSubmit,
  });

  @override
  State<ApprovalChatDialog> createState() => _ApprovalChatDialogState();
}

class _ApprovalChatDialogState extends State<ApprovalChatDialog> {
  static const Color _red = ColorManager.errorTitle;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _messages {
    final List<Map<String, dynamic>> list = [];

    final String managerComment =
    (widget.approval['managerComment'] ?? '').toString().trim();

    if (managerComment.isNotEmpty) {
      list.add({
        'sender': context.tr('المدير'),
        'date': '',
        'text': managerComment,
        'image': null,
        'isMe': false,
      });
    }

    final List msgs = (widget.approval['messages'] as List?) ?? [];

    for (final item in msgs) {
      list.add(Map<String, dynamic>.from(item as Map));
    }

    return list;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage() async {
    if (_loading) return;

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null || !mounted) return;

      final Uint8List bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _image = file;
        _imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('تعذر اختيار الصورة، حاولي مرة أخرى'))),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _imageBytes = null;
    });
  }

  Future<void> _send() async {
    if (_loading) return;

    final String text = _controller.text.trim();

    if (text.isEmpty && _image == null) return;

    setState(() => _loading = true);

    try {
      await widget.onSubmit(text, _image);

      if (!mounted) return;

      _controller.clear();
      _removeImage();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('تعذر إرسال الرسالة، حاولي مرة أخرى'))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AC c = AC.of(context);
    final List<Map<String, dynamic>> messages = _messages;

    return Directionality(
      textDirection: context.dir,
      child: Dialog(
        backgroundColor: c.surface,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560.w, maxHeight: 680.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: const BoxDecoration(gradient: _brandGradient),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 23.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('الشات'),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: 17.sp,
                              fontWeight: FontWeightManager.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            context.tr('محادثة الطلب'),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: 11.sp,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: context.tr('إغلاق'),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: c.chatBg,
                  child: messages.isEmpty
                      ? Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        context.tr('لا توجد رسائل لهذا الطلب'),
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: 13.sp,
                          color: c.muted,
                        ),
                      ),
                    ),
                  )
                      : ListView.separated(
                    controller: _scroll,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 18.h,
                    ),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, index) {
                      return _ChatBubble(
                        message: messages[index],
                        currentUserName: widget.userName,
                      );
                    },
                  ),
                ),
              ),
              if (_imageBytes != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border(top: BorderSide(color: c.chatDivider)),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.memory(
                            _imageBytes!,
                            width: 100.w,
                            height: 85.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        PositionedDirectional(
                          top: 4.r,
                          start: 4.r,
                          child: Material(
                            color: _red,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: _removeImage,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(4.r),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 15.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(top: BorderSide(color: c.chatDivider)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _loading ? null : _pickImage,
                      tooltip: context.tr('إرفاق صورة'),
                      icon: Icon(
                        Icons.attach_file_rounded,
                        size: 25.sp,
                        color: c.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.inputBg,
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(color: c.inputBorder),
                        ),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          cursorColor: c.primary,
                          textInputAction: TextInputAction.newline,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: 14.sp,
                            color: c.inputText,
                          ),
                          decoration: InputDecoration(
                            hintText: context.tr('اكتب رسالتك هنا...'),
                            hintStyle: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: 13.sp,
                              color: c.hint,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 11.h,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _brandGradient,

                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _loading ? null : _send,
                          customBorder: const CircleBorder(),
                          child: Center(
                            child: _loading
                                ? SizedBox(
                              width: 19.r,
                              height: 19.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Transform.flip(
                              flipX: context.isArabic,
                              child: Icon(
                                Icons.send_rounded,
                                size: 21.sp,
                                color: Colors.white,
                              ),
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
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final String currentUserName;

  const _ChatBubble({
    required this.message,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final AC c = AC.of(context);

    final String date = (message['date'] ?? '').toString();
    final String text = (message['text'] ?? '').toString();

    final dynamic rawImage = message['image'];
    final Uint8List? image = rawImage is Uint8List ? rawImage : null;

    final String sender = (message['sender'] ?? '').toString().trim();

    final bool isMe = sender.isNotEmpty && sender == currentUserName.trim();

    final Color textColor = isMe ? Colors.white : c.inputText;
    final Color secondaryColor =
    isMe ? Colors.white.withOpacity(0.8) : c.muted;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 350.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.r, 9.r, 12.r, 7.r),
          decoration: BoxDecoration(
            color: isMe ? null : c.incomingBubble,
            gradient: isMe
                ? const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                ColorManager.primaryColor,
                ColorManager.primaryDarkShade,
              ],
            )
                : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomRight: Radius.circular(isMe ? 5.r : 18.r),
              bottomLeft: Radius.circular(isMe ? 18.r : 5.r),
            ),

          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sender.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    sender,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 11.sp,
                      fontWeight: FontWeightManager.bold,
                      color: isMe ? Colors.white.withOpacity(0.9) : c.primary,
                    ),
                  ),
                ),
              if (text.isNotEmpty)
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 14.sp,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
              if (image != null) ...[
                if (text.isNotEmpty) SizedBox(height: 7.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.memory(image, fit: BoxFit.contain),
                ),
              ],
              if (date.isNotEmpty || isMe) ...[
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (date.isNotEmpty)
                      Text(
                        date,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: 10.sp,
                          color: secondaryColor,
                        ),
                      ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.done_all_rounded,
                        size: 15.sp,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}