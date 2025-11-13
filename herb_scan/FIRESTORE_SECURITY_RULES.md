# Firestore Security Rules - Hướng dẫn cập nhật

## Vấn đề
Khi app cố gắng đọc collection `healthy`, bạn gặp lỗi:
```
PERMISSION_DENIED: Missing or insufficient permissions
```

## Giải pháp

### Bước 1: Mở Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Firestore Database** → **Rules**

### Bước 2: Cập nhật Security Rules

Copy và paste đoạn rules sau vào Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Cho phép đọc tất cả collections: diseases, healthy, users
    match /{collection}/{document} {
      allow read: if true;
    }
    
    // Cho phép ghi cho admin (chỉ dùng trong admin page)
    // Lưu ý: Trong production, nên bảo vệ bằng authentication
    match /diseases/{document} {
      allow read: if true;
      allow create, update, delete: if true; // Tạm thời cho phép tất cả
    }
    
    match /healthy/{document} {
      allow read: if true;
      allow create, update, delete: if true; // Tạm thời cho phép tất cả
    }
    
    // Users collection - chỉ user đó mới đọc/ghi được dữ liệu của mình
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Bước 3: Publish Rules
1. Click nút **Publish** ở trên cùng
2. Đợi vài giây để rules được áp dụng

### Bước 4: Test lại app
- Restart app
- Đăng bài mới trên Firebase
- Badge sẽ tự động hiện số bài mới

## ⚠️ Lưu ý bảo mật QUAN TRỌNG

**Rules hiện tại chỉ dùng cho DEVELOPMENT!** 

Khi deploy lên production, bạn **PHẢI** cập nhật Security Rules để bảo mật.

👉 **Xem hướng dẫn chi tiết:** [`PRODUCTION_SECURITY_GUIDE.md`](./PRODUCTION_SECURITY_GUIDE.md)

### Tóm tắt nhanh:

**Phương án khuyến nghị:** Dùng Firebase Authentication để verify admin

1. Tạo collection `admins` trong Firestore
2. Cập nhật Security Rules (xem file hướng dẫn)
3. Thêm đăng nhập vào admin page
4. Chỉ admin mới ghi được, app chỉ đọc được

## Kiểm tra Rules đã áp dụng

Sau khi publish, bạn có thể test trong Firebase Console:
1. Vào **Firestore Database** → **Rules** → **Rules Playground**
2. Chọn collection: `healthy`
3. Chọn operation: `get`
4. Click **Run** → Nên thấy ✅ Success

