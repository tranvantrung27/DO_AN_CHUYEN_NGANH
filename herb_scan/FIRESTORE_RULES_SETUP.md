# 🔐 Hướng dẫn cấu hình Firestore Security Rules

## ⚠️ Lỗi "Missing or insufficient permissions"

Lỗi này xảy ra vì Firestore Security Rules chưa cho phép ghi dữ liệu. Bạn cần cấu hình Security Rules trong Firebase Console.

## 📝 Các bước thực hiện:

### Bước 1: Tạo tài khoản Admin trong Firebase Authentication

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Authentication** → **Users**
4. Click **Add user**
5. Nhập email và mật khẩu (ví dụ: `admin@herbscan.com`)
6. Click **Add user**
7. **Copy UID** của user vừa tạo (sẽ dùng ở bước sau)

### Bước 2: Tạo collection `admins` trong Firestore

1. Vào **Firestore Database**
2. Click **Start collection**
3. Collection ID: `admins`
4. Document ID: **Paste UID** từ bước 1
5. Thêm các fields:
   - `email` (string): Email của admin (ví dụ: `admin@herbscan.com`)
   - `role` (string): `admin`
   - `createdAt` (timestamp): Thời gian hiện tại
6. Click **Save**

### Bước 3: Cập nhật Firestore Security Rules

1. Vào **Firestore Database** → **Rules**
2. Thay thế toàn bộ rules hiện tại bằng code sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kiểm tra user có phải admin không
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Diseases collection - App đọc được, chỉ admin mới ghi được
    match /diseases/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // Healthy collection - App đọc được, chỉ admin mới ghi được
    match /healthy/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // Herballibrary collection - App đọc được, chỉ admin mới ghi được
    match /herballibrary/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // Herb categories collection - App đọc được, chỉ admin mới ghi được
    match /herb_categories/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // Admins collection - chỉ admin mới đọc được
    match /admins/{adminId} {
      allow read: if isAdmin();
      allow write: if false; // Chỉ tạo từ Firebase Console
    }
    
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**

### Bước 4: Đăng nhập vào Admin Panel

1. Mở file `admin_add_disease.html` trong trình duyệt
2. Nhập email và mật khẩu admin đã tạo ở Bước 1
3. Click **Đăng nhập**
4. Sau khi đăng nhập thành công, bạn có thể thêm/sửa/xóa bài viết

## ✅ Kiểm tra

Sau khi hoàn thành các bước trên:
- ✅ App Flutter vẫn đọc được dữ liệu
- ✅ Admin panel có thể đăng nhập
- ✅ Admin panel có thể thêm/sửa/xóa bài viết
- ❌ User thường không thể ghi vào Firestore từ app

## 🔒 Lưu ý bảo mật

1. **Không chia sẻ** thông tin đăng nhập admin
2. **Backup** Security Rules trước khi thay đổi
3. **Test** kỹ trên Rules Playground trước khi publish
4. **Monitor** Firestore usage để tránh chi phí bất ngờ

## 🆘 Nếu vẫn gặp lỗi

1. Kiểm tra lại UID trong collection `admins` có đúng không
2. Kiểm tra email/password đăng nhập có đúng không
3. Kiểm tra Security Rules đã được publish chưa
4. Xem Console (F12) để biết lỗi chi tiết

