import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/calendar_widgets.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuoteViewScreen extends StatefulWidget {
  const QuoteViewScreen({super.key, required this.quote});

  final Map<String, dynamic> quote;

  @override
  State<QuoteViewScreen> createState() => _QuoteViewScreenState();
}

class _QuoteViewScreenState extends State<QuoteViewScreen> {
  int _tab = 0;

  Map<String, dynamic> get _q => widget.quote;

  String _v(List<String> keys) {
    for (final k in keys) {
      final v = (_q[k] ?? '').toString().trim();
      if (v.isNotEmpty) return v;
    }
    return '—';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'مرسل':
        return ReportColors.orange;
      case 'مقبول':
        return ReportColors.green;
      case 'مرفوض':
        return ReportColors.red;
      default:
        return ReportColors.blue;
    }
  }

  Color _approvalColor(String s) {
    switch (s) {
      case 'معتمد':
        return ReportColors.green;
      case 'مرفوض':
        return ReportColors.red;
      default:
        return ReportColors.orange;
    }
  }

  List<Map> get _items {
    final raw = _q['items'];
    return raw is List ? raw.whereType<Map>().toList() : <Map>[];
  }


  List<Widget> _basicTab() {
    final items = _items;

    return [
      ReportCard(
        title: 'البيانات الأساسية',
        child: Column(
          children: [
            _ReadField(
              label: 'اسم عرض السعر',
              value: _v(['name', 'title', 'quoteName']),
            ),
            _Pair(
              _ReadField(label: 'العميل', value: _v(['customer'])),
              _ReadField(label: 'رقم الهاتف', value: _v(['phone']), ltr: true),
            ),
            _Pair(
              _ReadField(
                label: 'تاريخ عرض السعر',
                value: _v(['quoteDate']),
                ltr: true,
              ),
              _ReadField(
                label: 'تاريخ الانتهاء',
                value: _v(['expiryDate', 'expireDate', 'validUntil']),
                ltr: true,
              ),
            ),
            _Pair(
              _ReadField(
                label: 'طريقة الدفع',
                value: _v(['paymentMethod', 'payment']),
              ),
              _ReadField(
                label: 'نسبة الخصم',
                value: _v(['discount', 'discountPercent']),
                ltr: true,
              ),
            ),
            _ReadField(
              label: 'ملاحظات',
              value: _v(['notes', 'note']),
              multiline: true,
            ),
          ],
        ),
      ),
      if (items.isNotEmpty)
        ReportCard(
          title: 'الاهتمامات العقارية',
          subtitle: 'الوحدات والمشاريع التي يهتم بها العميل',
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                _ItemTile(index: i + 1, item: items[i]),
            ],
          ),
        ),
      ReportCard(
        title: 'الإجماليات',
        child: _Pair(
          _ReadField(
            label: 'الإجمالي الفرعي',
            value: _v(['subtotal', 'subTotal']),
            ltr: true,
          ),
          _ReadField(label: 'الإجمالي', value: _v(['total']), ltr: true),
        ),
      ),
    ];
  }


  List<Widget> _detailsTab(BuildContext context) {
    final theme = Theme.of(context);
    final status = _v(['status']);
    final approval = _v(['approvalStatus']);

    return [
      ReportCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 22.sp,
                    color: ColorManager.primaryColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _v(['name', 'title', 'quoteName', 'customer']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        _v(['quoteNumber']),
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Cell(
                    label: 'الحالة',
                    child: status == '—'
                        ? const _Dash()
                        : ReportStatusChip(
                      text: status,
                      color: _statusColor(status),
                    ),
                  ),
                ),
                Expanded(
                  child: _Cell(
                    label: 'حالة الاعتماد',
                    child: approval == '—'
                        ? const _Dash()
                        : ReportStatusChip(
                      text: approval,
                      color: _approvalColor(approval),
                    ),
                  ),
                ),
                Expanded(
                  child: _Cell(
                    label: 'تاريخ الإنشاء',
                    child: Text(
                      _v(['createdAt', 'created', 'quoteDate']),
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ReportCard(
        title: 'بيانات العميل والتواصل',
        child: Column(
          children: [
            _Pair(
              _ReadField(label: 'العميل', value: _v(['customer'])),
              _ReadField(label: 'الهاتف', value: _v(['phone']), ltr: true),
            ),
            _Pair(
              _ReadField(
                label: 'الموبايل',
                value: _v(['mobile', 'phone']),
                ltr: true,
              ),
              _ReadField(label: 'الفرصة', value: _v(['opportunity'])),
            ),
            _ReadField(label: 'المسؤول', value: _v(['owner'])),
          ],
        ),
      ),
    ];
  }


  Widget _pill(BuildContext context, int index, String label) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final selected = _tab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: selected
                ? primary.withOpacity(0.10)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected ? primary : reportBorder(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? primary : primary.withOpacity(0.12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeightManager.bold,
                    color: selected ? Colors.white : primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeightManager.bold,
                    color: selected
                        ? primary
                        : theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CalendarHeader(
                title: 'عرض سعر',
                subtitle: _v(['quoteNumber']),
                backIcon: Icons.close_rounded,
                onBack: () => Navigator.pop(context),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    _pill(context, 0, 'البيانات الأساسية'),
                    SizedBox(width: 10.w),
                    _pill(context, 1, 'تفاصيل عرض السعر'),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  children: [
                    ..._tab == 0 ? _basicTab() : _detailsTab(context),
                    Row(
                      children: [
                        Expanded(
                          child: ReportButton(
                            label: 'إغلاق',
                            icon: Icons.close_rounded,
                            filled: false,
                            onTap: () => Navigator.pop(context),
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


class _Pair extends StatelessWidget {
  const _Pair(this.first, this.second);

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: 10.w),
        Expanded(child: second),
      ],
    );
  }
}

class _ReadField extends StatelessWidget {
  const _ReadField({
    required this.label,
    required this.value,
    this.ltr = false,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool ltr;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill =
        theme.inputDecorationTheme.fillColor ?? theme.scaffoldBackgroundColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: multiline ? 72.h : 0),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: reportBorder(context)),
            ),
            child: Text(
              value,
              textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
              textAlign: TextAlign.start,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(end: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: 6.h),
          child,
        ],
      ),
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) =>
      Text('—', style: Theme.of(context).textTheme.titleSmall);
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.index, required this.item});

  final int index;
  final Map item;

  String _get(List<String> keys) {
    for (final k in keys) {
      final v = (item[k] ?? '').toString().trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    final title = _get(['name', 'unit', 'project']);
    final lines = <MapEntry<String, String>>[
      MapEntry('النوع', _get(['type'])),
      MapEntry('نوع الصفقة', _get(['dealType'])),
      MapEntry('مستوى الاهتمام', _get(['interest', 'interestLevel'])),
      MapEntry('سعر الوحدة', _get(['price', 'unitPrice'])),
      MapEntry('ملاحظات', _get(['notes', 'note'])),
    ].where((e) => e.value.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: reportBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeightManager.bold,
                    color: primary,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title.isEmpty ? '—' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          if (lines.isNotEmpty) SizedBox(height: 10.h),
          for (final e in lines)
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: [
                  Text(e.key, style: theme.textTheme.bodySmall),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}