import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_details_card.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_images_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CallDetailsSection extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final Future<String?> Function()? onPickFromDevice;

  const CallDetailsSection({super.key, this.onChanged, this.onPickFromDevice});

  @override
  State<CallDetailsSection> createState() => _CallDetailsSectionState();
}

class _CallDetailsSectionState extends State<CallDetailsSection> {
  final phoneController = TextEditingController();
  final durationController = TextEditingController(text: '0');
  final imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> images = [];

  String? callType;
  String? callStatus;

  List<String> get callTypes => [context.tr('واردة'), context.tr('صادرة')];
  List<String> get callStatuses => [
    context.tr('تم الرد'),
    context.tr('لم يتم الرد'),
    context.tr('مشغول'),
  ];

  @override
  void initState() {
    super.initState();
    callType = 'واردة';
    callStatus = 'تم الرد';
    phoneController.addListener(_notify);
    durationController.addListener(_notify);
  }

  @override
  void dispose() {
    phoneController.dispose();
    durationController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged?.call({
      'toNumber': phoneController.text.trim(),
      'durationMinutes': int.tryParse(durationController.text) ?? 0,
      'callType': callType,
      'callStatus': callStatus,
      'images': List<String>.from(images),
    });
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _addImageUrl() {
    final url = imageUrlController.text.trim();
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    final valid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    if (!valid) {
      _showMsg(context.tr('الرابط غير صحيح'));
      return;
    }
    if (images.contains(url)) {
      _showMsg(context.tr('الصورة مضافة بالفعل'));
      return;
    }

    setState(() {
      images.add(url);
      imageUrlController.clear();
    });
    _notify();
  }

  Future<void> _pickFromDevice() async {
    if (widget.onPickFromDevice != null) {
      final path = await widget.onPickFromDevice!();
      if (path == null || !mounted) return;
      setState(() => images.add(path));
      _notify();
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Directionality(
          textDirection: context.dir,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.tr('اختيار من المعرض')),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(context.tr('التقاط صورة بالكاميرا')),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final List<String> paths = [];

      if (source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage(imageQuality: 80);
        paths.addAll(files.map((f) => f.path));
      } else {
        final file = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (file != null) paths.add(file.path);
      }

      if (paths.isEmpty || !mounted) return;

      setState(() {
        for (final p in paths) {
          if (!images.contains(p)) images.add(p);
        }
      });
      _notify();
    } catch (e) {
      _showMsg(context.tr('تعذر اختيار الصورة، تأكدي من الصلاحيات'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActivityDetailsCard(
      title: context.tr('تفاصيل المكالمة'),
      icon: Icons.call_outlined,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LeadLabeledField(
                label: context.tr('إلى الرقم'),
                child: LeadTextField(
                  controller: phoneController,
                  hintText: '01xxxxxxxxx',
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: LeadLabeledField(
                label: context.tr('مدة المكالمة (دقائق)'),
                child: LeadTextField(
                  controller: durationController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LeadLabeledField(
                label: context.tr('نوع المكالمة'),
                child: LeadDropdown(
                  value: callType,
                  items: callTypes,
                  hint: context.tr('اختر...'),
                  onChanged: (v) {
                    setState(() => callType = v);
                    _notify();
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: LeadLabeledField(
                label: context.tr('حالة المكالمة'),
                child: LeadDropdown(
                  value: callStatus,
                  items: callStatuses,
                  hint: context.tr('اختر...'),
                  onChanged: (v) {
                    setState(() => callStatus = v);
                    _notify();
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ActivityImagesField(
          label: context.tr('صور المكالمة'),
          controller: imageUrlController,
          images: images,
          onAddUrl: _addImageUrl,
          onPickFromDevice: _pickFromDevice,
          onRemove: (i) {
            setState(() => images.removeAt(i));
            _notify();
          },
        ),
      ],
    );
  }
}