import 'dart:math' as math;

import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class LeadDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const LeadDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<LeadDropdown> createState() => _LeadDropdownState();
}

class _LeadDropdownState extends State<LeadDropdown> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _entry;

  bool get _isOpen => _entry != null;

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void _open() {
    if (widget.items.isEmpty) return;
    FocusScope.of(context).unfocus();

    final box = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;
    final fieldPos = box.localToGlobal(Offset.zero);

    final media = MediaQuery.of(context);
    final gap = 8.h;
    final margin = 12.h;

    final spaceBelow = media.size.height -
        media.viewInsets.bottom -
        (fieldPos.dy + size.height) -
        gap -
        margin;

    final spaceAbove = fieldPos.dy - media.padding.top - gap - margin;

    final desiredHeight =
    math.min(240.h, widget.items.length * 48.h + 12.h);

    final openUp = spaceBelow < desiredHeight && spaceAbove > spaceBelow;

    final available = openUp ? spaceAbove : spaceBelow;
    final maxHeight = math.min(240.h, math.max(available, 100.h));

    _entry = OverlayEntry(
      builder: (_) => Directionality(
        textDirection: context.dir,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: openUp ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor:
              openUp ? Alignment.bottomLeft : Alignment.topLeft,
              offset: Offset(0, openUp ? -gap : gap),
              child: SizedBox(
                width: size.width,
                child: _buildMenu(maxHeight: maxHeight, openUp: openUp),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _select(String item) {
    widget.onChanged(item);
    _close();
  }

  Widget _buildMenu({required double maxHeight, required bool openUp}) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * (openUp ? 8 : -8)),
          child: child,
        ),
      ),
      child: Material(
        color: theme.cardTheme.color,
        elevation: 8,
        shadowColor: primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            shrinkWrap: true,
            itemCount: widget.items.length,
            itemBuilder: (context, i) {
              final item = widget.items[i];
              final selected = item == widget.value;

              return InkWell(
                onTap: () => _select(item),
                child: Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  color:
                  selected ? primary.withOpacity(0.08) : Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr(item),
                          textAlign: context.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s14.sp,
                            fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? primary : textColor,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_rounded, size: 18.sp, color: primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasValue =
        widget.value != null && widget.items.contains(widget.value);
    final hasError = widget.errorText != null;

    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompositedTransformTarget(
            link: _link,
            child: GestureDetector(
              key: _fieldKey,
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: hasError
                        ? Colors.redAccent
                        : (_isOpen
                        ? primary.withOpacity(0.5)
                        : theme.dividerColor.withOpacity(0.5)),
                  ),

                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasValue
                            ? context.tr(widget.value!)
                            : context.tr(widget.hint),
                        textAlign: context.isArabic
                            ? TextAlign.right
                            : TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s14.sp,
                          fontWeight:
                          hasValue ? FontWeight.w600 : FontWeight.w400,
                          color: hasValue
                              ? theme.textTheme.bodyLarge?.color
                              : theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24.sp,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 5.h),
            Text(
              widget.errorText!,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s12.sp,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}