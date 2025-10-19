import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/index.dart';

/// Custom text field widget tái sử dụng
class AppTextField extends StatefulWidget {
  /// Controller cho text field
  final TextEditingController? controller;
  
  /// Label text
  final String? labelText;
  
  /// Hint text
  final String? hintText;
  
  /// Error text
  final String? errorText;
  
  /// Prefix icon
  final IconData? prefixIcon;
  
  /// Suffix icon
  final IconData? suffixIcon;
  
  /// Có phải password field không
  final bool isPassword;
  
  /// Keyboard type
  final TextInputType keyboardType;
  
  /// Text input action
  final TextInputAction textInputAction;
  
  /// Callback khi text thay đổi
  final ValueChanged<String>? onChanged;
  
  /// Callback khi submit
  final VoidCallback? onSubmitted;
  
  /// Callback khi suffix icon được tap
  final VoidCallback? onSuffixTap;
  
  /// Có enabled không
  final bool enabled;
  
  /// Có required không
  final bool required;
  
  /// Max lines
  final int maxLines;
  
  /// Focus node
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixTap,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.required) ...[
                SizedBox(width: 4.w),
                Text(
                  '*',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
        ],
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            style: AppTheme.bodyMedium.copyWith(
              color: widget.enabled ? AppColors.textPrimary : AppColors.textLight,
            ),
            onChanged: widget.onChanged,
            onFieldSubmitted: (_) => widget.onSubmitted?.call(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              errorText: widget.errorText,
              errorStyle: AppTheme.bodyMedium.copyWith(
                color: AppColors.error,
                fontSize: 12.sp,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused 
                          ? AppColors.primaryGreen 
                          : AppColors.textLight,
                      size: 20.r,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              filled: true,
              fillColor: widget.enabled ? Colors.white : AppColors.borderLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: widget.errorText != null 
                      ? AppColors.error 
                      : AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: widget.errorText != null 
                      ? AppColors.error 
                      : AppColors.primaryGreen,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textLight,
          size: 20.r,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.textLight,
          size: 20.r,
        ),
        onPressed: widget.onSuffixTap,
      );
    }
    
    return null;
  }
}
