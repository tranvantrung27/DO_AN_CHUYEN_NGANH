import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget container chứa các setting items với shadow đẹp
class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final double? borderRadius;

  const SettingsCard({
    super.key,
    required this.children,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular((borderRadius ?? 12).r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: _buildItemsWithDividers(context),
      ),
    );
  }

  List<Widget> _buildItemsWithDividers(BuildContext context) {
    final List<Widget> items = [];
    
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      
      // Thêm divider giữa các items (không thêm sau item cuối)
      if (i < children.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
            indent: 52.w, // Indent để align với text (40 icon + 12 spacing)
          ),
        );
      }
    }
    
    return items;
  }
}
