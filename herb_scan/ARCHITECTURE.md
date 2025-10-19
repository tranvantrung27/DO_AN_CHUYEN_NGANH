# 🏗️ Cấu Trúc Dự Án Herb Scan

## 📁 Cấu Trúc Thư Mục

```
lib/
├── constants/           # Hằng số và cấu hình
│   ├── app_colors.dart     # Màu sắc ứng dụng
│   ├── app_animations.dart # Animation constants
│   ├── app_theme.dart      # Theme và styling
│   └── index.dart          # Barrel export
│
├── extensions/          # Extension methods
│   ├── context_extensions.dart  # Extensions cho BuildContext
│   ├── string_extensions.dart   # Extensions cho String
│   ├── widget_extensions.dart   # Extensions cho Widget
│   └── index.dart              # Barrel export
│
├── mixins/             # Mixins tái sử dụng
│   ├── loading_mixin.dart      # Loading state management
│   ├── validation_mixin.dart   # Form validation
│   └── index.dart             # Barrel export
│
├── models/             # Data models
│   ├── intro_content.dart     # Model cho intro content
│   └── index.dart            # Barrel export
│
├── screens/            # Màn hình ứng dụng
│   ├── intro/                # Màn hình giới thiệu
│   ├── home/                 # Màn hình chính
│   ├── scan/                 # Màn hình quét
│   ├── history/              # Màn hình lịch sử
│   ├── herballibrary/        # Thư viện cây thuốc
│   ├── settings/             # Cài đặt
│   └── login/                # Đăng nhập
│
├── services/           # Business logic và API calls
│   └── (sẽ tạo sau)
│
├── utils/              # Utility functions
│   ├── app_utils.dart        # Các helper functions
│   └── index.dart           # Barrel export
│
├── widgets/            # Custom widgets
│   ├── common/              # Widget components tái sử dụng
│   │   ├── animated_dot_indicator.dart
│   │   ├── app_button.dart
│   │   └── app_loading.dart
│   ├── intro_navigation.dart
│   └── index.dart          # Barrel export
│
└── main.dart           # Entry point
```

## 🎯 Nguyên Tắc Thiết Kế

### 1. **Tái Sử Dụng (Reusability)**
- Mọi component đều được thiết kế để tái sử dụng
- Sử dụng factory constructors cho các variants
- Extension methods để mở rộng functionality

### 2. **Bảo Trì (Maintainability)**
- Tách biệt concerns rõ ràng
- Barrel exports để import dễ dàng
- Constants được tập trung quản lý

### 3. **Mở Rộng (Scalability)**
- Cấu trúc modular
- Mixins cho shared functionality
- Service layer cho business logic

## 🧩 Các Component Chính

### **AppButton** - Button Component Tái Sử Dụng
```dart
// Các cách sử dụng
AppButton.primary(
  text: 'Tiếp tục',
  onPressed: () {},
)

AppButton.secondary(
  text: 'Quay lại',
  leftIcon: Icons.arrow_back,
  onPressed: () {},
)

AppButton.outline(
  text: 'Hủy',
  size: AppButtonSize.small,
  onPressed: () {},
)
```

### **AppLoading** - Loading Component
```dart
// Loading đơn giản
AppLoading.simple()

// Loading với text
AppLoading.withText(text: 'Đang tải...')

// Loading overlay
AppLoadingOverlay(
  isLoading: isLoading,
  child: YourWidget(),
)

// Shimmer loading
AppShimmer.text(width: 100, height: 16)
```

### **AnimatedDotIndicator** - Page Indicator
```dart
AnimatedDotIndicator(
  itemCount: 3,
  currentIndex: currentIndex,
  activeColor: AppColors.primaryGreen,
  showBounceEffect: true,
)
```

## 🔧 Extensions Hữu Ích

### **Context Extensions**
```dart
// Navigation
context.push(NextScreen());
context.pop();

// Snackbar
context.showSuccessSnackBar('Thành công!');
context.showErrorSnackBar('Có lỗi xảy ra!');

// Responsive
context.width(100); // 100.w
context.height(50); // 50.h
context.fontSize(16); // 16.sp

// Dialog
context.showLoadingDialog();
context.hideLoadingDialog();
```

### **Widget Extensions**
```dart
// Padding & Margin
Text('Hello').paddingAll(16);
Text('World').marginSymmetric(horizontal: 20);

// Sizing
Container().size(width: 100, height: 50);
Text('Expand').expanded;

// Animations
Text('Fade In').fadeIn();
Container().slideInLeft();
Text('Scale').scaleIn();

// Gestures
Text('Tap me').onTap(() => print('Tapped!'));
```

### **String Extensions**
```dart
// Validation
'email@test.com'.isValidEmail; // true
'0123456789'.isValidVietnamesePhone; // true
'password123'.isStrongPassword; // false

// Formatting
'Nguyễn văn a'.capitalizeWords; // 'Nguyễn Văn A'
'100000'.formatCurrency; // '100,000 ₫'
'Nguyễn Văn A'.initials; // 'NVA'

// Vietnamese
'Tiếng Việt'.removeVietnameseDiacritics; // 'tieng viet'
```

## 🎨 Mixins

### **LoadingMixin**
```dart
class MyScreen extends StatefulWidget {
  // ...
}

class _MyScreenState extends State<MyScreen> with LoadingMixin {
  void fetchData() async {
    await withLoading(() async {
      // Your async operation
    }, message: 'Đang tải dữ liệu...');
  }

  @override
  Widget build(BuildContext context) {
    return AppLoadingOverlay(
      isLoading: isLoading,
      child: YourContent(),
    );
  }
}
```

### **ValidationMixin**
```dart
class LoginForm extends StatefulWidget {
  // ...
}

class _LoginFormState extends State<LoginForm> with ValidationMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: getController('email'),
          decoration: getInputDecoration(
            key: 'email',
            labelText: 'Email',
          ),
          onChanged: (value) => validateEmail('email', value),
        ),
        // ...
      ],
    );
  }
}
```

## 📱 Theme System

### **Colors**
```dart
AppColors.primaryGreen      // Màu chính
AppColors.secondaryGreen    // Màu phụ
AppColors.backgroundCream   // Màu nền
AppColors.textPrimary       // Màu chữ chính
AppColors.success           // Màu thành công
AppColors.error             // Màu lỗi
```

### **Typography**
```dart
AppTheme.headingLarge       // Heading lớn (splash)
AppTheme.headingMedium      // Heading vừa (intro)
AppTheme.bodyLarge          // Body text lớn
AppTheme.bodyMedium         // Body text vừa
AppTheme.buttonText         // Text trên button
AppTheme.caption            // Caption/hint text
```

### **Animations**
```dart
AppAnimations.fast          // 150ms
AppAnimations.normal        // 300ms
AppAnimations.slow          // 500ms
AppAnimations.bounce        // Curves.elasticOut
AppAnimations.easeInOut     // Curves.easeInOut
```

## 🚀 Cách Sử Dụng

### **Import Style**
```dart
// ✅ Tốt - sử dụng barrel exports
import 'package:herb_scan/constants/index.dart';
import 'package:herb_scan/widgets/index.dart';
import 'package:herb_scan/extensions/index.dart';

// ❌ Tránh - import từng file
import 'package:herb_scan/constants/app_colors.dart';
import 'package:herb_scan/constants/app_theme.dart';
```

### **Responsive Design**
```dart
// Luôn sử dụng ScreenUtil cho responsive
Container(
  width: 100.w,          // 100 logical pixels
  height: 50.h,          // 50 logical pixels
  padding: EdgeInsets.all(16.r),  // 16 radius
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp),  // 16 scaled pixels
  ),
)
```

### **State Management Pattern**
```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> 
    with LoadingMixin, ValidationMixin {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppLoadingOverlay(
        isLoading: isLoading,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Content here
      ],
    );
  }
}
```

## ⚡ Performance Tips

1. **Sử dụng const constructors** khi có thể
2. **Tránh rebuild không cần thiết** với proper state management
3. **Sử dụng AnimationController** thay vì AnimatedContainer cho complex animations
4. **Cache images** với CachedNetworkImage
5. **Lazy load lists** với ListView.builder

## 🔄 Quy Trình Thêm Feature Mới

1. **Tạo model** trong `models/`
2. **Tạo service** trong `services/` (nếu cần)
3. **Tạo screen** trong `screens/`
4. **Tạo widgets** trong `widgets/common/` (nếu tái sử dụng)
5. **Thêm constants** vào `constants/` (nếu cần)
6. **Update barrel exports** trong các file `index.dart`
7. **Viết tests** (sẽ thêm sau)

## 🎯 Best Practices

### **Naming Convention**
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`

### **Code Organization**
- 1 class per file
- Private methods ở cuối class
- Group related methods together
- Comment cho complex logic

### **Widget Building**
- Extract widgets thành methods riêng
- Sử dụng factory constructors cho variants
- Implement proper dispose methods
- Handle null safety properly

Cấu trúc này đảm bảo:
- ✅ **Dễ bảo trì**: Code được tổ chức rõ ràng
- ✅ **Tái sử dụng cao**: Components có thể dùng ở nhiều nơi
- ✅ **Dễ mở rộng**: Thêm feature mới không ảnh hưởng code cũ
- ✅ **Performance tốt**: Sử dụng best practices
- ✅ **Developer friendly**: Extensions và utilities giúp code nhanh hơn
