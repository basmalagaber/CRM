import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_details_card.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_images_field.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/lead_date_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class SmsDetailsSection extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final Future<String?> Function()? onPickFromDevice;

  const SmsDetailsSection({super.key, this.onChanged, this.onPickFromDevice});

  @override
  State<SmsDetailsSection> createState() => _SmsDetailsSectionState();
}

class _SmsDetailsSectionState extends State<SmsDetailsSection> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> images = [];

  DateTime sendDateTime = DateTime.now();

  String? direction;
  String? status;
  bool _isInitialized = false;

  List<String> get directions => [context.tr('واردة'), context.tr('صادرة')];
  List<String> get statuses => [
    context.tr('تم الإرسال'),
    context.tr('تم الاستلام'),
    context.tr('تم الرد'),
    context.tr('فشل'),
  ];

  @override
  void initState() {
    super.initState();
    titleController.addListener(_notify);
    contentController.addListener(_notify);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      direction = context.tr('واردة');
      status = context.tr('تم الإرسال');
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged?.call({
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
      'images': List<String>.from(images),
      'sendDateTime': sendDateTime.toIso8601String(),
      'direction': direction,
      'status': status,
    });
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
          '  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: sendDateTime,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(sendDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      sendDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    _notify();
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
    return Directionality(
      textDirection: context.dir,
      child: ActivityDetailsCard(
        title: context.tr('تفاصيل الرسالة النصية'),
        icon: Icons.sms_outlined,
        children: [
          LeadLabeledField(
            label: context.tr('عنوان الرسالة'),
            child: LeadTextField(
              controller: titleController,
              hintText: context.tr('اكتب عنوان الرسالة'),
            ),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('محتوى الرسالة'),
            child: LeadTextField(
              controller: contentController,
              hintText: context.tr('اكتب محتوى الرسالة'),
              maxLines: 6,
            ),
          ),
          SizedBox(height: 16.h),
          ActivityImagesField(
            label: context.tr('صور الرسالة'),
            controller: imageUrlController,
            images: images,
            onAddUrl: _addImageUrl,
            onPickFromDevice: _pickFromDevice,
            onRemove: (i) {
              setState(() => images.removeAt(i));
              _notify();
            },
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('تاريخ ووقت الإرسال'),
            child: LeadDateField(text: _fmt(sendDateTime), onTap: _pickDateTime),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('اتجاه الرسالة'),
            child: LeadDropdown(
              value: direction,
              items: directions,
              hint: context.tr('اختر...'),
              onChanged: (v) {
                setState(() => direction = v);
                _notify();
              },
            ),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('حالة الرسالة'),
            child: LeadDropdown(
              value: status,
              items: statuses,
              hint: context.tr('اختر...'),
              onChanged: (v) {
                setState(() => status = v);
                _notify();
              },
            ),
          ),
        ],
      ),
    );
  }
}