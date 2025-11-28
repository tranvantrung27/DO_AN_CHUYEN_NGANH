import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget container chứa các setting items
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
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: ShapeDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular((borderRadius ?? 5).r),
        ),
      ),
      child: Column(
        children: _buildItemsWithDividers(context),
      ),
    );
  }

  List<Widget> _buildItemsWithDividers(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> items = [];
    
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      
      // Thêm divider giữa các items (không thêm sau item cuối)
      if (i < children.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor,
          ),
        );
      }
    }
    
    return items;
  }
}

