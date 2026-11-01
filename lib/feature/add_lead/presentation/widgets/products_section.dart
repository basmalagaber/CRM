import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import 'add_interest_sheet.dart';
import 'lead_section_card.dart';

class ProductsSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final ValueChanged<Map<String, dynamic>> onAddProduct;
  final ValueChanged<int> onDeleteProduct;
  final void Function(int index, Map<String, dynamic> product) onEditProduct;

  const ProductsSection({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onDeleteProduct,
    required this.onEditProduct,
  });

  Future<void> _showAdd(BuildContext context) async {
    final result = await showAddInterestDialog(context);
    if (result != null) onAddProduct(result);
  }

  Future<void> _showEdit(
      BuildContext context,
      int index,
      Map<String, dynamic> product,
      ) async {
    final result = await showAddInterestDialog(context, initial: product);
    if (result != null) onEditProduct(index, result);
  }

  (Color, Color) _levelColors(bool isDark, String level) {
    switch (level) {
      case 'عالي':
        return isDark
            ? (
        ColorManager.approvalApprovedBgDark,
        ColorManager.approvalApprovedFgDark,
        )
            : (
        ColorManager.approvalApprovedBgLight,
        ColorManager.approvalApprovedFgLight,
        );
      case 'متوسط':
        return isDark
            ? (
        ColorManager.approvalPendingBgDark,
        ColorManager.approvalPendingFgDark,
        )
            : (
        ColorManager.approvalPendingBgLight,
        ColorManager.approvalPendingFgLight,
        );
      default:
        return isDark
            ? (
        ColorManager.approvalNeutralChipBgDark,
        ColorManager.approvalNeutralChipFgDark,
        )
            : (
        ColorManager.approvalNeutralChipBgLight,
        ColorManager.approvalNeutralChipFgLight,
        );
    }
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 17.sp, color: color),
      ),
    );
  }

  Widget _infoCell({
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.sp, color: fg.withOpacity(0.85)),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 10.sp,
                    fontWeight: FontWeightManager.regular,
                    color: fg.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeightManager.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context,
      ThemeData theme,
      int index,
      Map<String, dynamic> product,
      ) {
    final isDark = theme.brightness == Brightness.dark;

    final num unitPrice = (product['unitPrice'] ?? 0) as num;
    final String code = (product['code'] ?? '').toString();
    final String name = (product['name'] ?? '').toString();

    final String interestType = (product['interestType'] ?? 'وحدة').toString();
    final String dealType = (product['dealType'] ?? 'بيع').toString();
    final String level = (product['interestLevel'] ?? 'متوسط').toString();
    final String notes = (product['notes'] ?? '').toString().trim();

    final (levelBg, levelFg) = _levelColors(isDark, level);
    final neutralBg = isDark
        ? ColorManager.approvalNeutralChipBgDark
        : ColorManager.approvalNeutralChipBgLight;
    final neutralFg = isDark
        ? ColorManager.approvalNeutralChipFgDark
        : ColorManager.approvalNeutralChipFgLight;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────── الهيدر: رقم + الاسم/الكود + أزرار ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeightManager.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: FontSize.s14.sp,
                      ),
                    ),
                    if (code.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _actionButton(
                icon: Icons.edit_outlined,
                color: ColorManager.primaryColor,
                onTap: () => _showEdit(context, index, product),
              ),
              SizedBox(width: 6.w),
              _actionButton(
                icon: Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
                onTap: () => onDeleteProduct(index),
              ),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(height: 1, color: theme.dividerColor),
          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoCell(
                  icon: interestType == 'مشروع'
                      ? Icons.domain_rounded
                      : Icons.apartment_rounded,
                  label: context.tr('مهتم بـ'),
                  value: context.tr(interestType),
                  bg: neutralBg,
                  fg: neutralFg,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _infoCell(
                  icon: Icons.sell_outlined,
                  label: context.tr('نوع الصفقة'),
                  value: context.tr(dealType),
                  bg: neutralBg,
                  fg: neutralFg,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _infoCell(
                  icon: Icons.local_fire_department_outlined,
                  label: context.tr('مستوى الاهتمام'),
                  value: context.tr(level),
                  bg: levelBg,
                  fg: levelFg,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: ColorManager.primaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr(
                      interestType == 'مشروع' ? 'السعر المبدئي' : 'سعر الوحدة',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Text(
                  formatInterestPrice(unitPrice),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s16.sp,
                    fontWeight: FontWeightManager.bold,
                    color: ColorManager.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          if (notes.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 15.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      notes,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LeadSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  size: 20.sp,
                  color: ColorManager.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  context.tr('الاهتمامات العقارية'),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAdd(context),
                icon: Icon(Icons.add_rounded, size: 18.sp),
                label: Text(
                  context.tr('إضافة اهتمام'),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s12.sp,
                    fontWeight: FontWeightManager.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 38.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Text(
            context.tr('الوحدات والمشاريع التي يهتم بها هذا العميل المحتمل.'),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
          ),

          SizedBox(height: 14.h),

          if (products.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: ColorManager.primaryColor.withOpacity(0.18),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    size: 30.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    context.tr('لا توجد اهتمامات عقارية بعد.'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(
                products.length,
                    (index) => _buildCard(context, theme, index, products[index]),
              ),
            ),
        ],
      ),
    );
  }
}