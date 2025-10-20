<p align="center">
  <!-- Hero/Banner image. Put your background image at assets/readme/background.png -->
  <img src="herb_scan/assets/images/backgroud.png" alt="HerbScan Banner" width="100%">
</p>

<br>
<br>

# 🌿 HerbScan - Ứng Dụng Nhận Diện Thảo Dược Việt Nam

<div align="center">

![HerbScan Logo](herb_scan/assets/IconApp/app_icon.png)

**Ứng dụng AI nhận diện thảo dược Việt Nam với công nghệ Machine Learning**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

</div>

## 📱 Giới Thiệu

**HerbScan** là ứng dụng di động thông minh sử dụng công nghệ AI để nhận diện và cung cấp thông tin chi tiết về các loại thảo dược Việt Nam. Ứng dụng giúp người dùng dễ dàng tìm hiểu về công dụng, cách sử dụng và lưu trữ lịch sử nhận diện.

## ✨ Tính Năng Chính

### 🔍 **Nhận Diện Thảo Dược**
- Chụp ảnh hoặc chọn ảnh từ thư viện
- AI phân tích và nhận diện loại thảo dược
- Độ chính xác cao với cơ sở dữ liệu thảo dược Việt Nam

### 📚 **Kho Thảo Dược**
- Thư viện phong phú các loại thảo dược
- Thông tin chi tiết về công dụng, cách sử dụng
- Hình ảnh chất lượng cao và mô tả khoa học

### 📰 **Tin Tức Sức Khỏe**
- Tích hợp tin tức y tế từ các nguồn uy tín
- Xen kẽ đều đặn từ VnExpress, Sức Khỏe Đời Sống, Nhân Dân
- Cập nhật thông tin y tế mới nhất

### 📊 **Lịch Sử Nhận Diện**
- Lưu trữ tất cả lần quét thảo dược
- Tìm kiếm và lọc theo thời gian
- Xuất dữ liệu và chia sẻ

### ⚙️ **Cài Đặt & Tùy Chỉnh**
- Giao diện thân thiện, dễ sử dụng
- Tùy chỉnh ngôn ngữ và chế độ hiển thị
- Đồng bộ dữ liệu đám mây

## 🛠️ Công Nghệ Sử Dụng

### **Frontend**
- **Flutter** - Framework đa nền tảng
- **Dart** - Ngôn ngữ lập trình chính
- **Material Design** - Thiết kế giao diện

### **Backend & AI**
- **Firebase** - Backend as a Service
- **Firebase Auth** - Xác thực người dùng
- **Cloud Firestore** - Cơ sở dữ liệu NoSQL
- **Firebase Storage** - Lưu trữ hình ảnh
- **TensorFlow Lite** - Machine Learning on-device

### **Tích Hợp**
- **RSS/Atom Parser** - Thu thập tin tức
- **URL Launcher** - Mở liên kết ngoài
- **Image Picker** - Chọn ảnh từ thiết bị
- **Camera** - Chụp ảnh trực tiếp

## 📦 Cài Đặt

### **Yêu Cầu Hệ Thống**
- Flutter SDK >= 3.7.2
- Dart SDK >= 3.0.0
- Android API 21+ / iOS 11.0+
- Camera và quyền truy cập ảnh

### **Cài Đặt Dependencies**
```bash
# Clone repository
git clone https://github.com/yourusername/herb-scan.git
cd herb-scan

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

### **Cấu Hình Firebase**
1. Tạo project trên [Firebase Console](https://console.firebase.google.com/)
2. Thêm ứng dụng Android/iOS
3. Tải file `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
4. Đặt vào thư mục `android/app/` hoặc `ios/Runner/`

## 🏗️ Kiến Trúc Ứng Dụng

```
lib/
├── 📁 constants/          # Hằng số và theme
├── 📁 models/            # Data models
│   ├── 📁 news/          # Models cho tin tức
│   └── 📁 articles/      # Models cho thảo dược
├── 📁 services/          # Business logic
│   ├── 📁 news/          # Service tin tức
│   └── auth_service.dart # Xác thực
├── 📁 screens/           # Màn hình chính
│   ├── 📁 home/          # Trang chủ
│   ├── 📁 scan/          # Quét thảo dược
│   ├── 📁 herballibrary/ # Kho thảo dược
│   └── 📁 history/       # Lịch sử
├── 📁 widgets/           # UI components
├── 📁 utils/             # Utilities
└── 📁 config/            # Cấu hình
```

## 🎯 Tính Năng Nổi Bật

### **Hệ Thống Tin Tức "Plug-and-Play"**
- Chỉ cần thêm cấu hình RSS là có nguồn tin mới
- Parser tự động cho RSS/Atom/JSON
- Xen kẽ đều đặn giữa các nguồn tin
- Xử lý encoding UTF-8 thông minh

### **AI Nhận Diện Thông Minh**
- Machine Learning on-device
- Không cần kết nối internet để nhận diện
- Cơ sở dữ liệu thảo dược Việt Nam phong phú
- Cập nhật model thường xuyên

## 📱 Screenshots

<div align="center">

| Trang Chủ | Quét Thảo Dược | Kho Thảo Dược |
|-----------|----------------|---------------|
| ![Home](herb_scan/assets/screenshots/home.png) | ![Scan](herb_scan/assets/screenshots/scan.png) | ![Library](herb_scan/assets/screenshots/library.png) |

| Tin Tức | Lịch Sử | Cài Đặt |
|---------|---------|---------|
| ![News](herb_scan/assets/screenshots/news.png) | ![History](herb_scan/assets/screenshots/history.png) | ![Settings](herb_scan/assets/screenshots/settings.png) |

</div>

## 🚀 Roadmap

### **Version 1.1** (Q1 2025)
- [ ] Thêm nhận diện bằng giọng nói
- [ ] Tích hợp bản đồ vị trí thảo dược
- [ ] Chế độ offline hoàn toàn

### **Version 1.2** (Q2 2025)
- [ ] AI chat hỗ trợ tư vấn thảo dược
- [ ] Hệ thống đánh giá và review
- [ ] Tích hợp với bác sĩ Đông y

### **Version 2.0** (Q3 2025)
- [ ] AR (Augmented Reality) nhận diện
- [ ] Blockchain cho tính xác thực
- [ ] API mở cho nhà phát triển

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Hãy:

1. **Fork** repository này
2. Tạo **feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit** thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. **Push** lên branch (`git push origin feature/AmazingFeature`)
5. Mở **Pull Request**

## 📄 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 👥 Team

- **Nguyễn Văn A** - *Lead Developer* - [@nguyenvana](https://github.com/nguyenvana)
- **Trần Thị B** - *AI Engineer* - [@tranthib](https://github.com/tranthib)
- **Lê Văn C** - *UI/UX Designer* - [@levanc](https://github.com/levanc)

## 📞 Liên Hệ

- **Email**: contact@herbscan.vn
- **Website**: https://herbscan.vn
- **Facebook**: [HerbScan Vietnam](https://facebook.com/herbscan)
- **GitHub**: [@herbscan](https://github.com/herbscan)

---

<div align="center">

**Được phát triển với ❤️ tại Việt Nam**

![Made in Vietnam](https://img.shields.io/badge/Made%20in-Vietnam-red?style=for-the-badge&logo=vietnam&logoColor=white)

</div>
