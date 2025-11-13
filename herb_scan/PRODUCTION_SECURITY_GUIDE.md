# 🔒 Hướng dẫn Bảo mật cho Production

## ⚠️ Vấn đề hiện tại

Rules hiện tại cho phép **bất kỳ ai cũng có thể ghi/xóa** vào `diseases` và `healthy` collections. Điều này rất nguy hiểm khi deploy app lên production vì:
- Người dùng có thể xóa/sửa bài viết
- Spam bài viết
- Tốn chi phí Firestore không kiểm soát

---

## ✅ Giải pháp đề xuất (từ đơn giản đến chuyên nghiệp)

### 🥉 **Phương án 1: Đơn giản nhất - Chỉ đọc từ app**

**Ưu điểm:** Dễ triển khai, không cần code thêm  
**Nhược điểm:** Phải dùng Firebase Console để đăng bài (không tiện)

#### Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // App chỉ đọc được
    match /diseases/{document} {
      allow read: if true;
      allow create, update, delete: if false; // Không ai ghi được từ app
    }
    
    match /healthy/{document} {
      allow read: if true;
      allow create, update, delete: if false; // Không ai ghi được từ app
    }
    
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Cách đăng bài:
- Vào Firebase Console → Firestore Database
- Thêm document thủ công vào `diseases` hoặc `healthy`
- Hoặc dùng admin page nhưng phải deploy lên server riêng với Firebase Admin SDK

---

### 🥈 **Phương án 2: Dùng Firebase Authentication (KHUYẾN NGHỊ)**

**Ưu điểm:** Bảo mật tốt, dễ quản lý, app đã có sẵn Firebase Auth  
**Nhược điểm:** Cần tạo admin account và lưu danh sách admin

#### Bước 1: Tạo collection `admins` trong Firestore

Tạo document với ID là UID của admin user:
```
admins/
  └── {admin_uid}/
      └── email: "admin@example.com"
      └── role: "admin"
      └── createdAt: timestamp
```

#### Bước 2: Cập nhật Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kiểm tra user có phải admin không
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // App đọc được, chỉ admin mới ghi được
    match /diseases/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    match /healthy/{document} {
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

#### Bước 3: Cập nhật Admin Page (`admin_add_disease.html`)

Thêm đăng nhập Firebase Auth vào admin page:

```javascript
// Thêm vào <head>
<script src="https://www.gstatic.com/firebasejs/10.12.1/firebase-auth-compat.js"></script>

// Thêm vào script
const auth = firebase.auth();

// Hàm đăng nhập admin
async function loginAdmin() {
  const email = prompt('Email admin:');
  const password = prompt('Password:');
  
  try {
    await auth.signInWithEmailAndPassword(email, password);
    alert('✅ Đăng nhập thành công!');
    loadArticles(); // Load lại danh sách
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}

// Kiểm tra đăng nhập khi load trang
auth.onAuthStateChanged((user) => {
  if (user) {
    console.log('✅ Đã đăng nhập:', user.email);
    document.getElementById('loginBtn').style.display = 'none';
  } else {
    console.log('❌ Chưa đăng nhập');
    document.getElementById('loginBtn').style.display = 'block';
  }
});

// Thêm button đăng nhập vào HTML
// <button id="loginBtn" onclick="loginAdmin()">🔐 Đăng nhập Admin</button>
```

#### Bước 4: Tạo admin account

1. Vào Firebase Console → Authentication → Users
2. Thêm user mới với email/password (hoặc dùng email đã có)
3. Copy UID của user đó
4. Vào Firestore → Tạo collection `admins` → Tạo document với ID = UID
5. Thêm field: `email: "admin@example.com"`, `role: "admin"`

---

### 🥇 **Phương án 3: Cloud Functions với Secret Token (CHUYÊN NGHIỆP NHẤT)**

**Ưu điểm:** Bảo mật cao nhất, có thể log, rate limiting  
**Nhược điểm:** Cần setup Cloud Functions, phức tạp hơn

#### Bước 1: Tạo Cloud Function

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const ADMIN_SECRET = 'your-super-secret-token-here'; // Đổi thành token bí mật

exports.addArticle = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.status(200).send('');
    return;
  }
  
  // Verify secret token
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (token !== ADMIN_SECRET) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }
  
  try {
    const { collection, data } = req.body;
    
    if (!['diseases', 'healthy'].includes(collection)) {
      res.status(400).json({ error: 'Invalid collection' });
      return;
    }
    
    // Thêm createdAt
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    data.isActive = data.isActive !== false;
    
    // Ghi vào Firestore (bypass security rules vì dùng Admin SDK)
    const docRef = await admin.firestore()
      .collection(collection)
      .add(data);
    
    res.status(200).json({ 
      success: true, 
      id: docRef.id 
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});
```

#### Bước 2: Security Rules (chỉ đọc):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /diseases/{document} {
      allow read: if true;
      allow write: if false; // Chỉ Cloud Function mới ghi được
    }
    
    match /healthy/{document} {
      allow read: if true;
      allow write: if false; // Chỉ Cloud Function mới ghi được
    }
  }
}
```

#### Bước 3: Cập nhật Admin Page

```javascript
const ADMIN_SECRET = 'your-super-secret-token-here';
const FUNCTION_URL = 'https://your-region-your-project.cloudfunctions.net/addArticle';

async function saveDoc() {
  // ... lấy data từ form ...
  
  try {
    const response = await fetch(FUNCTION_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ADMIN_SECRET}`
      },
      body: JSON.stringify({
        collection: currentCollection,
        data: {
          title: title,
          subtitle: subtitle,
          imageUrl: imageUrl,
          content: content,
          isActive: true
        }
      })
    });
    
    const result = await response.json();
    if (result.success) {
      alert('✅ Đã đăng bài thành công!');
      loadArticles();
    }
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}
```

---

## 📊 So sánh các phương án

| Tiêu chí | Phương án 1 | Phương án 2 | Phương án 3 |
|----------|-------------|-------------|-------------|
| **Độ khó setup** | ⭐ Dễ | ⭐⭐ Trung bình | ⭐⭐⭐ Khó |
| **Bảo mật** | ⭐⭐⭐ Tốt | ⭐⭐⭐ Tốt | ⭐⭐⭐ Rất tốt |
| **Tiện lợi** | ⭐ Kém | ⭐⭐⭐ Tốt | ⭐⭐⭐ Tốt |
| **Chi phí** | ⭐ Miễn phí | ⭐ Miễn phí | ⭐⭐ Có phí (Functions) |
| **Logging** | ❌ Không | ⭐ Cơ bản | ⭐⭐⭐ Đầy đủ |
| **Rate limiting** | ❌ Không | ❌ Không | ✅ Có thể |

---

## 🎯 Khuyến nghị

**Cho app nhỏ/vừa:** Dùng **Phương án 2** (Firebase Authentication)
- Dễ setup
- Bảo mật tốt
- Không tốn chi phí thêm
- App đã có sẵn Firebase Auth

**Cho app lớn/production:** Dùng **Phương án 3** (Cloud Functions)
- Bảo mật cao nhất
- Có thể thêm rate limiting, logging
- Dễ mở rộng sau này

---

## 🚀 Triển khai nhanh (Phương án 2)

### 1. Cập nhật Security Rules trên Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    match /diseases/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    match /healthy/{document} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    match /admins/{adminId} {
      allow read: if isAdmin();
      allow write: if false;
    }
    
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. Tạo admin account:
- Firebase Console → Authentication → Add user
- Copy UID
- Firestore → Tạo `admins/{uid}` với field `email` và `role: "admin"`

### 3. Cập nhật admin page để đăng nhập (xem code mẫu ở trên)

### 4. Test:
- Thử đăng bài từ admin page (sau khi đăng nhập) → ✅ Thành công
- Thử đăng bài từ app thường → ❌ Bị từ chối

---

## 📝 Lưu ý quan trọng

1. **Backup dữ liệu** trước khi thay đổi Security Rules
2. **Test kỹ** trên Firebase Console Rules Playground trước khi publish
3. **Giữ bí mật** admin credentials và tokens
4. **Monitor** Firestore usage để tránh chi phí bất ngờ
5. **Log** các thao tác admin để audit sau này

---

## 🔍 Kiểm tra bảo mật

Sau khi deploy, test các trường hợp:

1. ✅ App đọc được bài viết
2. ❌ App không thể tạo/sửa/xóa bài viết
3. ✅ Admin đăng nhập được vào admin page
4. ✅ Admin có thể tạo/sửa/xóa bài viết
5. ❌ User thường không thể truy cập admin page

---

## 💡 Tips bổ sung

- **Rate limiting:** Thêm vào Cloud Functions để giới hạn số request/giờ
- **IP whitelist:** Chỉ cho phép admin page từ IP nhất định
- **2FA:** Thêm 2-factor authentication cho admin account
- **Audit log:** Lưu log tất cả thao tác admin vào Firestore

