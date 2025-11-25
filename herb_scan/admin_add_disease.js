// Firebase Config
const firebaseConfig = {
  apiKey: "AIzaSyABB_cjZ4mV9VdJlMdwaB2fVgprTMNpAVw",
  authDomain: "herb-b7af4.firebaseapp.com",
  projectId: "herb-b7af4",
  storageBucket: "herb-b7af4.firebasestorage.app",
  messagingSenderId: "38629570189",
  appId: "1:38629570189:android:d5ae045249ec8c28b1d4c4"
};

firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const storage = firebase.storage();
const auth = firebase.auth();

// State
let currentTab = 'diseases';
let currentView = 'list'; // 'list', 'detail', 'form', 'manageCategories'
let editingDocId = null;
let viewingDocId = null;
let editingCategoryId = null; // Store category ID being edited
let categories = []; // Store categories for herballibrary

// Store the event handler to avoid duplicate listeners
let editorKeydownHandler = null;

// Undo/Redo history
let editorHistory = [];
let historyIndex = -1;
let isUndoRedo = false;

// Save state to history
function saveToHistory() {
  const contentTextarea = document.getElementById('content');
  if (!contentTextarea || isUndoRedo) return;

  const currentValue = contentTextarea.value;
  const currentSelection = {
    start: contentTextarea.selectionStart,
    end: contentTextarea.selectionEnd
  };

  // Remove any history after current index (when user makes new change after undo)
  if (historyIndex < editorHistory.length - 1) {
    editorHistory = editorHistory.slice(0, historyIndex + 1);
  }

  // Add new state
  editorHistory.push({
    value: currentValue,
    selection: currentSelection
  });

  // Limit history to 50 states
  if (editorHistory.length > 50) {
    editorHistory.shift();
  } else {
    historyIndex++;
  }
}

// Undo
function undoEditor() {
  const contentTextarea = document.getElementById('content');
  if (!contentTextarea || historyIndex <= 0) return;

  isUndoRedo = true;
  historyIndex--;
  const state = editorHistory[historyIndex];
  contentTextarea.value = state.value;
  contentTextarea.setSelectionRange(state.selection.start, state.selection.end);
  contentTextarea.focus();
  setTimeout(() => { isUndoRedo = false; }, 100);
}

// Redo
function redoEditor() {
  const contentTextarea = document.getElementById('content');
  if (!contentTextarea || historyIndex >= editorHistory.length - 1) return;

  isUndoRedo = true;
  historyIndex++;
  const state = editorHistory[historyIndex];
  contentTextarea.value = state.value;
  contentTextarea.setSelectionRange(state.selection.start, state.selection.end);
  contentTextarea.focus();
  setTimeout(() => { isUndoRedo = false; }, 100);
}

// Initialize history when form is shown
function initEditorHistory() {
  const contentTextarea = document.getElementById('content');
  if (!contentTextarea) return;

  editorHistory = [{
    value: contentTextarea.value,
    selection: {
      start: contentTextarea.selectionStart,
      end: contentTextarea.selectionEnd
    }
  }];
  historyIndex = 0;
}

// Setup keyboard shortcuts for editor
function setupEditorShortcuts() {
  const contentTextarea = document.getElementById('content');
  if (!contentTextarea) return;

  // Remove old listener if exists
  if (editorKeydownHandler) {
    contentTextarea.removeEventListener('keydown', editorKeydownHandler);
  }

  // Create new handler
  editorKeydownHandler = function(e) {
    // Ctrl+Z for Undo
    if (e.ctrlKey && e.key === 'z' && !e.shiftKey) {
      e.preventDefault();
      undoEditor();
      return;
    }
    // Ctrl+Y or Ctrl+Shift+Z for Redo
    else if ((e.ctrlKey && e.key === 'y') || (e.ctrlKey && e.shiftKey && e.key === 'Z')) {
      e.preventDefault();
      redoEditor();
      return;
    }
    // Ctrl+B for Bold
    else if (e.ctrlKey && e.key === 'b') {
      e.preventDefault();
      saveToHistory();
      formatText('bold');
    }
    // Ctrl+I for Italic
    else if (e.ctrlKey && e.key === 'i') {
      e.preventDefault();
      saveToHistory();
      formatText('italic');
    }
    // Ctrl+U for Underline
    else if (e.ctrlKey && e.key === 'u') {
      e.preventDefault();
      saveToHistory();
      formatText('underline');
    }
    // Ctrl+Shift+S for Strikethrough (avoid conflict with save)
    else if (e.ctrlKey && e.shiftKey && e.key === 'S') {
      e.preventDefault();
      saveToHistory();
      formatText('strikethrough');
    }
  };

  // Add new listener
  contentTextarea.addEventListener('keydown', editorKeydownHandler);

  // Save to history on input (with debounce)
  let inputTimeout;
  contentTextarea.addEventListener('input', function() {
    if (isUndoRedo) return;
    clearTimeout(inputTimeout);
    inputTimeout = setTimeout(() => {
      saveToHistory();
    }, 500); // Debounce 500ms
  });
}

// Format text with history (for button clicks)
function formatTextWithHistory(type) {
  saveToHistory();
  formatText(type);
}

// Format text in textarea
function formatText(type) {
  const textarea = document.getElementById('content');
  if (!textarea) return;

  const start = textarea.selectionStart;
  const end = textarea.selectionEnd;
  const selectedText = textarea.value.substring(start, end);
  const beforeText = textarea.value.substring(0, start);
  const afterText = textarea.value.substring(end);

  let formattedText = '';
  let newCursorPos = start;

  switch(type) {
    case 'bold':
      if (selectedText) {
        formattedText = `**${selectedText}**`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '****';
        newCursorPos = start + 2;
      }
      break;
    case 'italic':
      if (selectedText) {
        formattedText = `*${selectedText}*`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '**';
        newCursorPos = start + 1;
      }
      break;
    case 'underline':
      if (selectedText) {
        formattedText = `<u>${selectedText}</u>`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '<u></u>';
        newCursorPos = start + 3;
      }
      break;
    case 'strikethrough':
      if (selectedText) {
        formattedText = `~~${selectedText}~~`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '~~~~';
        newCursorPos = start + 2;
      }
      break;
    case 'h1':
      if (selectedText) {
        formattedText = `# ${selectedText}`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '# ';
        newCursorPos = start + formattedText.length;
      }
      break;
    case 'h2':
      if (selectedText) {
        formattedText = `## ${selectedText}`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '## ';
        newCursorPos = start + formattedText.length;
      }
      break;
    case 'h3':
      if (selectedText) {
        formattedText = `### ${selectedText}`;
        newCursorPos = start + formattedText.length;
      } else {
        formattedText = '### ';
        newCursorPos = start + formattedText.length;
      }
      break;
  }

  textarea.value = beforeText + formattedText + afterText;
  textarea.focus();
  textarea.setSelectionRange(newCursorPos, newCursorPos);
  
  // Save new state to history after formatting
  if (!isUndoRedo) {
    // Update the last history entry with the new formatted state
    if (editorHistory.length > 0 && historyIndex >= 0) {
      editorHistory[historyIndex] = {
        value: textarea.value,
        selection: { start: newCursorPos, end: newCursorPos }
      };
    }
  }
}

// Get collection name based on current tab
function getCollectionName() {
  switch(currentTab) {
    case 'diseases':
      return 'diseases';
    case 'healthy':
      return 'healthy';
    case 'herballibrary':
      return 'herballibrary';
    default:
      return 'diseases';
  }
}

// Switch tab
function switchTab(tab) {
  currentTab = tab;
  editingDocId = null;
  viewingDocId = null;
  
  document.querySelectorAll('.menu-item').forEach(item => {
    item.classList.remove('active');
  });
  document.getElementById('menu-' + tab).classList.add('active');
  
  const titles = {
    'diseases': '📋 Danh sách bài viết - Các bệnh',
    'healthy': '📋 Danh sách bài viết - Sống khỏe',
    'herballibrary': '📚 Danh sách bài thuốc - Kho thuốc'
  };
  document.getElementById('listTitle').textContent = titles[tab] || titles['diseases'];
  
      // Show/hide category, date, related articles, tags, and content fields based on tab
      const categoryGroup = document.getElementById('categoryGroup');
      const dateGroup = document.getElementById('dateGroup');
      const relatedArticlesGroup = document.getElementById('relatedArticlesGroup');
      const tagsGroup = document.getElementById('tagsGroup');
      const contentGroup = document.getElementById('contentGroup');
      const subtitleHint = document.getElementById('subtitleHint');
      const subtitleField = document.getElementById('subtitle');
      
      if (categoryGroup && dateGroup && relatedArticlesGroup && tagsGroup && contentGroup) {
        if (tab === 'herballibrary') {
          categoryGroup.style.display = 'block';
          dateGroup.style.display = 'block';
          relatedArticlesGroup.style.display = 'none'; // Hidden for now
          tagsGroup.style.display = 'none'; // Hidden for now
          contentGroup.style.display = 'none';
          // Make content not required for herballibrary
          const contentField = document.getElementById('content');
          if (contentField) contentField.removeAttribute('required');
          
          // Show hint for herballibrary
          if (subtitleHint) subtitleHint.style.display = 'block';
          if (subtitleField) {
            subtitleField.placeholder = 'Nhập công dụng của bài thuốc.';
          }
          
          // Load categories for dropdown
          loadCategories();
        } else {
          categoryGroup.style.display = 'none';
          dateGroup.style.display = 'none';
          relatedArticlesGroup.style.display = 'none';
          tagsGroup.style.display = 'none';
          contentGroup.style.display = 'block';
          // Make content required for diseases/healthy
          const contentField = document.getElementById('content');
          if (contentField) contentField.setAttribute('required', 'required');
          
          // Hide hint for other tabs
          if (subtitleHint) subtitleHint.style.display = 'none';
          if (subtitleField) {
            subtitleField.placeholder = 'Nhập tiêu đề phụ/mô tả ngắn';
          }
        }
      }
  
  showList();
}

// Show list view
function showList() {
  currentView = 'list';
  document.getElementById('listView').style.display = 'block';
  document.getElementById('detailView').style.display = 'none';
  document.getElementById('formView').style.display = 'none';
  const manageCategoriesView = document.getElementById('manageCategoriesView');
  if (manageCategoriesView) manageCategoriesView.style.display = 'none';
  
  // Show/hide manage categories button
  const manageCategoriesBtn = document.getElementById('manageCategoriesBtn');
  if (manageCategoriesBtn) {
    manageCategoriesBtn.style.display = currentTab === 'herballibrary' ? 'block' : 'none';
  }
  
  loadArticles();
}

// Show manage categories view
function showManageCategories() {
  currentView = 'manageCategories';
  document.getElementById('listView').style.display = 'none';
  document.getElementById('detailView').style.display = 'none';
  document.getElementById('formView').style.display = 'none';
  const manageCategoriesView = document.getElementById('manageCategoriesView');
  if (manageCategoriesView) manageCategoriesView.style.display = 'block';
  
  // Reset form and editing state
  editingCategoryId = null;
  cancelEditCategory();
  
  loadCategories();
}

// Show add form
function showAddForm() {
  currentView = 'form';
  editingDocId = null;
  document.getElementById('listView').style.display = 'none';
  document.getElementById('detailView').style.display = 'none';
  document.getElementById('formView').style.display = 'block';
  
  const formTitles = {
    'diseases': '🪴 Đăng bài mới - Các bệnh',
    'healthy': '💚 Đăng bài mới - Sống khỏe',
    'herballibrary': '🌿 Đăng bài thuốc mới - Kho thuốc'
  };
  document.getElementById('formTitle').textContent = formTitles[currentTab] || formTitles['diseases'];
  
  // Reset form
  document.getElementById('imageUrl').value = '';
  document.getElementById('imageFile').value = '';
  document.getElementById('title').value = '';
  document.getElementById('subtitle').value = '';
  document.getElementById('content').value = '';
  const imagePreview = document.getElementById('imagePreview');
  if (imagePreview) imagePreview.style.display = 'none';
  const categoryField = document.getElementById('category');
  const dateField = document.getElementById('date');
  const relatedArticlesField = document.getElementById('relatedArticles');
  const tagsField = document.getElementById('tags');
  if (categoryField) categoryField.value = '';
  if (dateField) {
    // Auto-set date for herballibrary when adding new
    if (currentTab === 'herballibrary') {
      dateField.value = formatDate(new Date());
    } else {
      dateField.value = '';
    }
  }
  if (relatedArticlesField) relatedArticlesField.value = '';
  if (tagsField) tagsField.value = '';
  document.getElementById('status').className = 'status';
  document.getElementById('status').textContent = '';
  
  // Show/hide category, date, related articles, tags, and content fields
  const categoryGroup = document.getElementById('categoryGroup');
  const dateGroup = document.getElementById('dateGroup');
  const relatedArticlesGroup = document.getElementById('relatedArticlesGroup');
  const tagsGroup = document.getElementById('tagsGroup');
  const contentGroup = document.getElementById('contentGroup');
  const subtitleHint = document.getElementById('subtitleHint');
  const subtitleField = document.getElementById('subtitle');
  
  if (categoryGroup && dateGroup && relatedArticlesGroup && tagsGroup && contentGroup) {
    if (currentTab === 'herballibrary') {
      categoryGroup.style.display = 'block';
      dateGroup.style.display = 'block';
      relatedArticlesGroup.style.display = 'none'; // Hidden for now
      tagsGroup.style.display = 'none'; // Hidden for now
      contentGroup.style.display = 'none';
      const contentField = document.getElementById('content');
      if (contentField) contentField.removeAttribute('required');
      
      // Show hint for herballibrary
      if (subtitleHint) subtitleHint.style.display = 'block';
      if (subtitleField) {
        subtitleField.placeholder = 'Nhập công dụng của bài thuốc.';
      }
    } else {
      categoryGroup.style.display = 'none';
      dateGroup.style.display = 'none';
      relatedArticlesGroup.style.display = 'none';
      tagsGroup.style.display = 'none';
      contentGroup.style.display = 'block';
      const contentField = document.getElementById('content');
      if (contentField) contentField.setAttribute('required', 'required');
      
      // Hide hint for other tabs
      if (subtitleHint) subtitleHint.style.display = 'none';
      if (subtitleField) {
        subtitleField.placeholder = 'Nhập tiêu đề phụ/mô tả ngắn';
      }
    }
  }
  
  // Setup editor shortcuts and initialize history
  setTimeout(() => {
    initEditorHistory();
    setupEditorShortcuts();
  }, 100);
}

// Show edit form
function showEditForm(docId) {
  currentView = 'form';
  editingDocId = docId;
  document.getElementById('listView').style.display = 'none';
  document.getElementById('detailView').style.display = 'none';
  document.getElementById('formView').style.display = 'block';
  document.getElementById('formTitle').textContent = '✏️ Sửa bài viết';
  
  // Load data
  const collectionName = getCollectionName();
  db.collection(collectionName).doc(docId).get().then(doc => {
    if (doc.exists) {
      const data = doc.data();
      const imageUrl = data.imageUrl || '';
      document.getElementById('imageUrl').value = imageUrl;
      // Show preview if image URL exists
      if (imageUrl) {
        updateImagePreview(imageUrl);
      }
      document.getElementById('title').value = data.title || data.name || '';
      // For herballibrary, remove ALL "Công dụng: " prefixes when editing
      let subtitleValue = (data.subtitle || data.description || '').trim();
      if (currentTab === 'herballibrary') {
        // Remove all occurrences of "Công dụng: " prefix (handle duplicates and variations)
        // Handle case-insensitive and with/without spaces
        const prefixVariations = [
          'Công dụng:',
          'Công dụng :',
          'Công dụng: ',
          'Công dụng : ',
          'công dụng:',
          'CÔNG DỤNG:',
        ];
        
        let changed = true;
        while (changed) {
          changed = false;
          for (const prefix of prefixVariations) {
            if (subtitleValue.toLowerCase().startsWith(prefix.toLowerCase())) {
              subtitleValue = subtitleValue.substring(prefix.length).trim();
              changed = true;
              break;
            }
          }
        }
      }
      document.getElementById('subtitle').value = subtitleValue;
      document.getElementById('content').value = data.content || '';
      
      // Load category, date, related articles, and tags for herballibrary
      const categoryField = document.getElementById('category');
      const dateField = document.getElementById('date');
      const relatedArticlesField = document.getElementById('relatedArticles');
      const tagsField = document.getElementById('tags');
      if (categoryField) categoryField.value = data.category || '';
      if (dateField) dateField.value = data.date || '';
      if (relatedArticlesField) {
        // Convert array to comma-separated string
        if (Array.isArray(data.relatedArticles)) {
          relatedArticlesField.value = data.relatedArticles.join(', ');
        } else if (data.relatedArticles) {
          relatedArticlesField.value = data.relatedArticles;
        } else {
          relatedArticlesField.value = '';
        }
      }
      if (tagsField) {
        // Convert array to comma-separated string
        if (Array.isArray(data.tags)) {
          tagsField.value = data.tags.join(', ');
        } else if (data.tags) {
          tagsField.value = data.tags;
        } else {
          tagsField.value = '';
        }
      }
      
      // Show/hide category, date, related articles, tags, and content fields
      const categoryGroup = document.getElementById('categoryGroup');
      const dateGroup = document.getElementById('dateGroup');
      const relatedArticlesGroup = document.getElementById('relatedArticlesGroup');
      const tagsGroup = document.getElementById('tagsGroup');
      const contentGroup = document.getElementById('contentGroup');
      if (categoryGroup && dateGroup && relatedArticlesGroup && tagsGroup && contentGroup) {
        if (currentTab === 'herballibrary') {
          categoryGroup.style.display = 'block';
          dateGroup.style.display = 'block';
          relatedArticlesGroup.style.display = 'none'; // Hidden for now
          tagsGroup.style.display = 'none'; // Hidden for now
          contentGroup.style.display = 'none';
          const contentField = document.getElementById('content');
          if (contentField) contentField.removeAttribute('required');
        } else {
          categoryGroup.style.display = 'none';
          dateGroup.style.display = 'none';
          relatedArticlesGroup.style.display = 'none';
          tagsGroup.style.display = 'none';
          contentGroup.style.display = 'block';
          const contentField = document.getElementById('content');
          if (contentField) contentField.setAttribute('required', 'required');
        }
      }
      
      // Setup editor shortcuts and initialize history after loading data
      setTimeout(() => {
        initEditorHistory();
        setupEditorShortcuts();
      }, 100);
    }
  });
}

// Show detail view
function showDetail(docId) {
  currentView = 'detail';
  viewingDocId = docId;
  document.getElementById('listView').style.display = 'none';
  document.getElementById('detailView').style.display = 'block';
  document.getElementById('formView').style.display = 'none';
  
  const collectionName = getCollectionName();
  db.collection(collectionName).doc(docId).get().then(doc => {
    if (doc.exists) {
      const data = doc.data();
      const createdAt = data.createdAt ? data.createdAt.toDate().toLocaleString('vi-VN') : 'Chưa có';
      const title = data.title || data.name || '';
      const subtitle = data.subtitle || data.description || '';
      
      let detailHTML = `
        <img src="${data.imageUrl}" alt="${title}" class="detail-image" onerror="this.src='https://via.placeholder.com/400x300?text=No+Image'">
        <div class="detail-info">
          <div class="detail-label">${currentTab === 'herballibrary' ? 'Tên bài thuốc' : 'Tiêu đề lớn'}</div>
          <div class="detail-value">${title}</div>
          
          <div class="detail-label">${currentTab === 'herballibrary' ? 'Mô tả' : 'Tiêu đề phụ'}</div>
          <div class="detail-value">${subtitle}</div>
      `;
      
      // Show category, date, and related articles for herballibrary
      if (currentTab === 'herballibrary') {
        if (data.category) {
          detailHTML += `
            <div class="detail-label">Triệu chứng thường gặp</div>
            <div class="detail-value">${data.category}</div>
          `;
        }
        if (data.date) {
          detailHTML += `
            <div class="detail-label">Ngày đăng</div>
            <div class="detail-value">${data.date}</div>
          `;
        }
        
        // Show related articles section
        if (data.relatedArticles && data.relatedArticles.length > 0) {
          const relatedIds = Array.isArray(data.relatedArticles) 
            ? data.relatedArticles 
            : data.relatedArticles.split(',').map(id => id.trim()).filter(id => id);
          
          if (relatedIds.length > 0) {
            detailHTML += `
              <div class="detail-label" style="margin-top: 20px; font-size: 16px; font-weight: 600;">Bài viết liên quan</div>
              <div id="relatedArticlesList" style="margin-top: 10px;">
                <div style="text-align: center; padding: 20px;">⏳ Đang tải...</div>
              </div>
            `;
          }
        }
      }
      
      // Show content if exists (for diseases/healthy)
      if (data.content) {
        detailHTML += `
          <div class="detail-label">Nội dung</div>
          <div class="detail-value" style="white-space: pre-wrap; max-height: 200px; overflow-y: auto;">${data.content}</div>
        `;
      }
      
      detailHTML += `
          <div class="detail-label">Link ảnh</div>
          <div class="detail-value"><a href="${data.imageUrl}" target="_blank">${data.imageUrl}</a></div>
          
          <div class="detail-label">Ngày tạo</div>
          <div class="detail-value">${createdAt}</div>
          
          <div class="detail-label">Trạng thái</div>
          <div class="detail-value">
            <span class="article-badge ${data.isActive !== false ? 'badge-active' : 'badge-inactive'}">
              ${data.isActive !== false ? '✅ Đang hiển thị' : '❌ Đã ẩn'}
            </span>
          </div>
        </div>
        <div class="action-buttons">
          <button class="btn btn-warning" onclick="showEditForm('${docId}')">✏️ Sửa</button>
          <button class="btn btn-secondary" onclick="toggleActive('${docId}', ${data.isActive !== false ? false : true})">
            ${data.isActive !== false ? '👁️ Ẩn' : '👁️ Hiện'}
          </button>
          <button class="btn btn-danger" onclick="deleteDoc('${docId}')">🗑️ Xóa</button>
        </div>
      `;
      
      document.getElementById('detailContent').innerHTML = detailHTML;
      
      // Load related articles if exists
      if (currentTab === 'herballibrary' && data.relatedArticles) {
        const relatedIds = Array.isArray(data.relatedArticles) 
          ? data.relatedArticles 
          : data.relatedArticles.split(',').map(id => id.trim()).filter(id => id);
        
        if (relatedIds.length > 0) {
          loadRelatedArticles(relatedIds, 'relatedArticlesList');
        }
      }
    }
  });
}

// Load and display related articles
function loadRelatedArticles(articleIds, containerId) {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  const collectionName = getCollectionName();
  const promises = articleIds.map(id => 
    db.collection(collectionName).doc(id.trim()).get()
  );
  
  Promise.all(promises).then(docs => {
    let html = '';
    docs.forEach((doc, index) => {
      if (doc.exists) {
        const data = doc.data();
        const title = data.title || data.name || 'Không có tiêu đề';
        const subtitle = data.subtitle || data.description || '';
        const imageUrl = data.imageUrl || '';
        
        html += `
          <div class="article-item" onclick="showDetail('${doc.id}')" style="margin-bottom: 12px;">
            <img src="${imageUrl}" alt="${title}" class="article-thumb" onerror="this.src='https://via.placeholder.com/120x120?text=No+Image'">
            <div class="article-info">
              <div class="article-title">${title}</div>
              <div class="article-subtitle">${subtitle}</div>
            </div>
          </div>
        `;
      }
    });
    
    if (html === '') {
      container.innerHTML = '<div style="text-align: center; padding: 20px; color: #999;">Không tìm thấy bài viết liên quan</div>';
    } else {
      container.innerHTML = html;
    }
  }).catch(error => {
    container.innerHTML = `<div class="status error">❌ Lỗi tải bài viết liên quan: ${error.message}</div>`;
  });
}

// Load articles
function loadArticles() {
  const collectionName = getCollectionName();
  const listContainer = document.getElementById('articleList');
  listContainer.innerHTML = '<div style="text-align: center; padding: 40px;">⏳ Đang tải...</div>';
  
  const query = db.collection(collectionName);
  
  // Try to order by createdAt, but handle case where it might not exist
  query
    .get()
    .then(snapshot => {
      if (snapshot.empty) {
        listContainer.innerHTML = `
          <div class="empty-state">
            <div class="empty-state-icon">📭</div>
            <div>Chưa có ${currentTab === 'herballibrary' ? 'bài thuốc' : 'bài viết'} nào</div>
            <button class="btn btn-primary" onclick="showAddForm()" style="margin-top: 20px;">➕ Đăng ${currentTab === 'herballibrary' ? 'bài thuốc' : 'bài viết'} đầu tiên</button>
          </div>
        `;
        return;
      }
      
      // Sort by createdAt if exists, otherwise by document ID
      const docs = snapshot.docs.sort((a, b) => {
        const aTime = a.data().createdAt ? a.data().createdAt.toMillis() : 0;
        const bTime = b.data().createdAt ? b.data().createdAt.toMillis() : 0;
        return bTime - aTime; // Descending order
      });
      
      let html = '';
      docs.forEach(doc => {
        const data = doc.data();
        const createdAt = data.createdAt ? data.createdAt.toDate().toLocaleString('vi-VN') : 'Chưa có';
        const isActive = data.isActive !== false;
        const title = data.title || data.name || 'Không có tiêu đề';
        const subtitle = data.subtitle || data.description || '';
        const displayDate = currentTab === 'herballibrary' && data.date ? data.date : createdAt;
        
        html += `
          <div class="article-item ${!isActive ? 'inactive' : ''}" onclick="showDetail('${doc.id}')">
            <img src="${data.imageUrl}" alt="${title}" class="article-thumb" onerror="this.src='https://via.placeholder.com/120x120?text=No+Image'">
            <div class="article-info">
              <div class="article-title">${title}</div>
              <div class="article-subtitle">${subtitle}</div>
              ${currentTab === 'herballibrary' && data.category ? `<div class="article-meta">📂 ${data.category}</div>` : ''}
              <div class="article-meta">📅 ${displayDate}</div>
              <span class="article-badge ${isActive ? 'badge-active' : 'badge-inactive'}">
                ${isActive ? '✅ Đang hiển thị' : '❌ Đã ẩn'}
              </span>
            </div>
          </div>
        `;
      });
      listContainer.innerHTML = html;
    })
    .catch(error => {
      listContainer.innerHTML = `<div class="status error">❌ Lỗi: ${error.message}</div>`;
    });
}

// Save document (add or update)
async function saveDoc() {
  const submitBtn = document.getElementById('submitBtn');
  const status = document.getElementById('status');
  const imageUrl = document.getElementById('imageUrl').value.trim();
  const title = document.getElementById('title').value.trim();
  const subtitle = document.getElementById('subtitle').value.trim();
  const content = document.getElementById('content').value.trim();
  const categoryField = document.getElementById('category');
  const dateField = document.getElementById('date');
  const relatedArticlesField = document.getElementById('relatedArticles');
  const tagsField = document.getElementById('tags');
  const category = categoryField ? categoryField.value.trim() : '';
  const date = dateField ? dateField.value.trim() : '';
  const relatedArticlesInput = relatedArticlesField ? relatedArticlesField.value.trim() : '';
  const tagsInput = tagsField ? tagsField.value.trim() : '';
  
  // Parse related articles (comma-separated IDs)
  let relatedArticles = [];
  if (relatedArticlesInput) {
    relatedArticles = relatedArticlesInput.split(',')
      .map(id => id.trim())
      .filter(id => id.length > 0);
  }
  
  // Parse tags (comma-separated tags)
  let tags = [];
  if (tagsInput) {
    tags = tagsInput.split(',')
      .map(tag => tag.trim())
      .filter(tag => tag.length > 0);
  }

  // Validation
  if (!imageUrl || !title || !subtitle) {
    status.className = 'status error';
    status.textContent = '❌ Vui lòng điền đầy đủ các trường bắt buộc!';
    return;
  }

  // For diseases/healthy, content is required
  if (currentTab !== 'herballibrary' && !content) {
    status.className = 'status error';
    status.textContent = '❌ Vui lòng điền đầy đủ các trường bắt buộc!';
    return;
  }

  try {
    new URL(imageUrl);
  } catch (e) {
    status.className = 'status error';
    status.textContent = '❌ Link ảnh không hợp lệ!';
    return;
  }

  submitBtn.disabled = true;
  submitBtn.textContent = '⏳ Đang lưu...';

  try {
    const collectionName = getCollectionName();
    const docData = {
      imageUrl: imageUrl,
      isActive: true
    };

    // Add fields based on tab type
    if (currentTab === 'herballibrary') {
      // For herballibrary: use name, description instead of title, subtitle
      docData.name = title;
      // The prefix "Công dụng: " is already displayed visually in HTML
      // So we just need to clean the input and add prefix once when saving
      let description = subtitle.trim();
      
      // Remove any existing "Công dụng: " prefix from user input to avoid duplication
      // Handle case-insensitive and with/without spaces
      const prefixVariations = [
        'Công dụng:',
        'Công dụng :',
        'Công dụng: ',
        'Công dụng : ',
        'công dụng:',
        'CÔNG DỤNG:',
      ];
      
      let changed = true;
      while (changed) {
        changed = false;
        for (const prefix of prefixVariations) {
          if (description.toLowerCase().startsWith(prefix.toLowerCase())) {
            description = description.substring(prefix.length).trim();
            changed = true;
            break;
          }
        }
      }
      
      // Always add prefix when saving (since it's displayed visually in form)
      // This ensures consistency in Firestore data
      if (description) {
        description = 'Công dụng: ' + description;
      } else {
        // If empty, still add prefix (user might have deleted content)
        description = 'Công dụng: ';
      }
      docData.description = description;
      if (category) docData.category = category;
      // Auto-set date if creating new (not editing)
      if (!editingDocId) {
        docData.date = formatDate(new Date());
      } else if (date) {
        // Keep existing date when editing
        docData.date = date;
      }
      // Temporarily disabled
      // if (relatedArticles.length > 0) docData.relatedArticles = relatedArticles;
      // if (tags.length > 0) docData.tags = tags;
    } else {
      // For diseases/healthy: use title, subtitle, content
      docData.title = title;
      docData.subtitle = subtitle;
      docData.content = content;
    }
    
    if (editingDocId) {
      // Update - don't update createdAt
      await db.collection(collectionName).doc(editingDocId).update(docData);
      status.className = 'status success';
      status.textContent = `✅ Đã cập nhật ${currentTab === 'herballibrary' ? 'bài thuốc' : 'bài viết'} thành công!`;
    } else {
      // Add new
      docData.createdAt = firebase.firestore.FieldValue.serverTimestamp();
      await db.collection(collectionName).add(docData);
      status.className = 'status success';
      status.textContent = `✅ Đã đăng ${currentTab === 'herballibrary' ? 'bài thuốc' : 'bài viết'} thành công!`;
    }

    setTimeout(() => {
      showList();
    }, 1500);

  } catch (error) {
    console.error('Error:', error);
    status.className = 'status error';
    status.textContent = '❌ Lỗi: ' + error.message;
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = '✅ Lưu bài viết';
  }
}

// Toggle active/inactive
async function toggleActive(docId, newStatus) {
  const itemType = currentTab === 'herballibrary' ? 'bài thuốc' : 'bài viết';
  if (!confirm(newStatus ? `Bạn có chắc muốn hiển thị ${itemType} này?` : `Bạn có chắc muốn ẩn ${itemType} này?`)) {
    return;
  }

  try {
    const collectionName = getCollectionName();
    await db.collection(collectionName).doc(docId).update({
      isActive: newStatus
    });
    showDetail(docId);
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}

// Delete document
async function deleteDoc(docId) {
  const itemType = currentTab === 'herballibrary' ? 'bài thuốc' : 'bài viết';
  if (!confirm(`⚠️ Bạn có chắc chắn muốn XÓA ${itemType} này? Hành động này không thể hoàn tác!`)) {
    return;
  }

  try {
    const collectionName = getCollectionName();
    await db.collection(collectionName).doc(docId).delete();
    showList();
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}

// Add all default categories to Firestore
async function addAllDefaultCategories() {
  const defaultCategories = [
    'Hô hấp', 'Tiêu hóa', 'Giấc ngủ', 'Xương khớp', 
    'Da liễu', 'Sốt', 'Tim mạch', 'Tiết niệu', 
    'Phụ nữ', 'Trẻ em', 'Răng miệng', 'Tóc & Da'
  ];
  
  try {
    // Check existing categories
    const existingSnapshot = await db.collection('herb_categories').get();
    const existingNames = new Set();
    existingSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.name) {
        existingNames.add(data.name.toLowerCase());
      }
    });
    
    // Add only categories that don't exist
    const categoriesToAdd = defaultCategories.filter(cat => 
      !existingNames.has(cat.toLowerCase())
    );
    
    if (categoriesToAdd.length === 0) {
      // All categories already exist, just reload
      loadCategories();
      return;
    }
    
    // Add all categories using batch write
    const batch = db.batch();
    categoriesToAdd.forEach(catName => {
      const docRef = db.collection('herb_categories').doc();
      batch.set(docRef, {
        name: catName,
        createdAt: firebase.firestore.FieldValue.serverTimestamp()
      });
    });
    
    await batch.commit();
    
    // Show success message
    const status = document.createElement('div');
    status.className = 'status success';
    status.textContent = `✅ Đã thêm ${categoriesToAdd.length} danh mục vào Firestore thành công!`;
    status.style.marginTop = '20px';
    const formView = document.getElementById('manageCategoriesView');
    if (formView) {
      const existingStatus = formView.querySelector('.status');
      if (existingStatus) existingStatus.remove();
      formView.appendChild(status);
      setTimeout(() => status.remove(), 3000);
    }
    
    // Reload categories to show them with edit buttons
    loadCategories();
  } catch (error) {
    console.error('Error adding default categories:', error);
    alert('❌ Lỗi: ' + error.message);
    // Still try to load categories even if there's an error
    loadCategories();
  }
}

// Load categories from Firestore
function loadCategories() {
  const categoriesList = document.getElementById('categoriesList');
  const categorySelect = document.getElementById('category');
  if (!categoriesList) return;
  
  categoriesList.innerHTML = '<div style="text-align: center; padding: 40px;">⏳ Đang tải...</div>';
  
  // Load from Firestore collection 'herb_categories'
  db.collection('herb_categories')
    .orderBy('name')
    .get()
    .then(async snapshot => {
      categories = [];
      let html = '';
      
      if (snapshot.empty) {
        // If no categories in Firestore, automatically add all default categories
        categoriesList.innerHTML = '<div style="text-align: center; padding: 40px;">⏳ Đang thêm danh mục mặc định vào Firestore...</div>';
        await addAllDefaultCategories();
        return; // addAllDefaultCategories will call loadCategories() again
      } else {
        snapshot.forEach(doc => {
          const data = doc.data();
          const imageUrl = data.imageUrl || '';
          categories.push({ name: data.name, id: doc.id, imageUrl: imageUrl });
          
          // Escape HTML for display
          const escapedName = (data.name || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
          const escapedImageUrl = (imageUrl || '').replace(/"/g, '&quot;');
          
          const imageHtml = imageUrl 
            ? `<img src="${escapedImageUrl}" alt="${escapedName}" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover; margin-right: 15px;">`
            : '<div style="width: 50px; height: 50px; border-radius: 50%; background: #e0e0e0; margin-right: 15px; display: flex; align-items: center; justify-content: center; color: #999; font-size: 20px;">📂</div>';
          
          html += `
            <div class="article-item" style="display: flex; justify-content: space-between; align-items: center;">
              <div style="flex: 1; display: flex; align-items: center;">
                ${imageHtml}
                <div style="flex: 1;">
                  <div class="article-title">${data.name}</div>
                  <div class="article-meta">ID: ${doc.id}</div>
                </div>
              </div>
              <div style="display: flex; gap: 10px;">
                <button class="btn btn-secondary edit-category-btn" 
                        data-category-id="${doc.id}" 
                        data-category-name="${escapedName}" 
                        data-category-image="${escapedImageUrl}" 
                        style="white-space: nowrap;">✏️ Sửa</button>
                <button class="btn btn-danger" onclick="deleteCategory('${doc.id}', '${escapedName}')">🗑️ Xóa</button>
              </div>
            </div>
          `;
        });
      }
      
      categoriesList.innerHTML = html;
      
      // Attach event listeners to edit buttons
      const editButtons = categoriesList.querySelectorAll('.edit-category-btn');
      editButtons.forEach(btn => {
        btn.addEventListener('click', function() {
          const categoryId = this.getAttribute('data-category-id');
          const categoryName = this.getAttribute('data-category-name');
          const categoryImage = this.getAttribute('data-category-image');
          editCategory(categoryId, categoryName, categoryImage);
        });
      });
      
      // Attach event listeners to "Add to Firestore" buttons for default categories
      const addDefaultButtons = categoriesList.querySelectorAll('.add-default-category-btn');
      addDefaultButtons.forEach(btn => {
        btn.addEventListener('click', async function() {
          const categoryName = this.getAttribute('data-category-name');
          // Unescape HTML entities
          const unescapedName = (categoryName || '')
            .replace(/&amp;/g, '&')
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&quot;/g, '"')
            .replace(/&#39;/g, "'");
          
          await addDefaultCategoryToFirestore(unescapedName);
        });
      });
      
      // Update category select dropdown
      if (categorySelect) {
        categorySelect.innerHTML = '<option value="">-- Chọn triệu chứng --</option>';
        categories.forEach(cat => {
          const option = document.createElement('option');
          option.value = cat.name;
          option.textContent = cat.name;
          categorySelect.appendChild(option);
        });
      }
    })
    .catch(error => {
      categoriesList.innerHTML = `<div class="status error">❌ Lỗi: ${error.message}</div>`;
    });
}

// Edit category - load data into form
function editCategory(categoryId, categoryName, categoryImageUrl) {
  if (!categoryId) {
    console.error('Category ID is required');
    return;
  }
  
  editingCategoryId = categoryId;
  
  const nameInput = document.getElementById('newCategoryName');
  const imageInput = document.getElementById('newCategoryImage');
  const categoryImagePreview = document.getElementById('categoryImagePreview');
  const categoryPreviewImg = document.getElementById('categoryPreviewImg');
  const submitBtn = document.getElementById('categorySubmitBtn');
  const cancelBtn = document.getElementById('categoryCancelBtn');
  
  // Unescape HTML entities
  const unescapedName = (categoryName || '')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
  const unescapedImageUrl = (categoryImageUrl || '')
    .replace(/&quot;/g, '"');
  
  if (nameInput) nameInput.value = unescapedName;
  if (imageInput) imageInput.value = unescapedImageUrl || '';
  
  // Show preview if image exists
  if (unescapedImageUrl && categoryPreviewImg && categoryImagePreview) {
    categoryPreviewImg.src = unescapedImageUrl;
    categoryImagePreview.style.display = 'block';
  } else if (categoryImagePreview) {
    categoryImagePreview.style.display = 'none';
  }
  
  // Update button text
  if (submitBtn) submitBtn.textContent = '💾 Lưu thay đổi';
  if (cancelBtn) cancelBtn.style.display = 'inline-block';
  
  // Scroll to form
  if (nameInput) nameInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
  if (nameInput) nameInput.focus();
}

// Cancel editing category
function cancelEditCategory() {
  editingCategoryId = null;
  
  const nameInput = document.getElementById('newCategoryName');
  const imageInput = document.getElementById('newCategoryImage');
  const imageFile = document.getElementById('newCategoryImageFile');
  const categoryImagePreview = document.getElementById('categoryImagePreview');
  const submitBtn = document.getElementById('categorySubmitBtn');
  const cancelBtn = document.getElementById('categoryCancelBtn');
  
  // Reset form
  if (nameInput) nameInput.value = '';
  if (imageInput) imageInput.value = '';
  if (imageFile) imageFile.value = '';
  if (categoryImagePreview) categoryImagePreview.style.display = 'none';
  
  // Update button
  if (submitBtn) submitBtn.textContent = '➕ Thêm danh mục';
  if (cancelBtn) cancelBtn.style.display = 'none';
}

// Save category (add new or update existing)
async function saveCategory() {
  const nameInput = document.getElementById('newCategoryName');
  const imageInput = document.getElementById('newCategoryImage');
  if (!nameInput) return;
  
  const categoryName = nameInput.value.trim();
  if (!categoryName) {
    alert('❌ Vui lòng nhập tên danh mục!');
    return;
  }
  
  // Get image URL
  let imageUrl = '';
  if (imageInput) {
    imageUrl = imageInput.value.trim();
    // Validate URL if provided
    if (imageUrl) {
      try {
        new URL(imageUrl);
      } catch (e) {
        alert('❌ Link ảnh không hợp lệ!');
        return;
      }
    }
  }
  
  try {
    if (editingCategoryId) {
      // Update existing category
      const categoryData = {
        name: categoryName,
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      };
      
      if (imageUrl) {
        categoryData.imageUrl = imageUrl;
      } else {
        // If imageUrl is empty, remove it from Firestore
        categoryData.imageUrl = firebase.firestore.FieldValue.delete();
      }
      
      await db.collection('herb_categories').doc(editingCategoryId).update(categoryData);
      
      // Show success message
      const status = document.createElement('div');
      status.className = 'status success';
      status.textContent = '✅ Đã cập nhật danh mục thành công!';
      status.style.marginTop = '20px';
      const formView = document.getElementById('manageCategoriesView');
      if (formView) {
        const existingStatus = formView.querySelector('.status');
        if (existingStatus) existingStatus.remove();
        formView.appendChild(status);
        setTimeout(() => status.remove(), 3000);
      }
      
      // Reset form
      cancelEditCategory();
    } else {
      // Add new category
      // Check if category already exists
      const exists = categories.some(cat => 
        cat.id !== editingCategoryId && 
        cat.name.toLowerCase() === categoryName.toLowerCase()
      );
      if (exists) {
        alert('❌ Danh mục này đã tồn tại!');
        return;
      }
      
      const categoryData = {
        name: categoryName,
        createdAt: firebase.firestore.FieldValue.serverTimestamp()
      };
      
      if (imageUrl) {
        categoryData.imageUrl = imageUrl;
      }
      
      await db.collection('herb_categories').add(categoryData);
      
      // Show success message
      const status = document.createElement('div');
      status.className = 'status success';
      status.textContent = '✅ Đã thêm danh mục thành công!';
      status.style.marginTop = '20px';
      const formView = document.getElementById('manageCategoriesView');
      if (formView) {
        const existingStatus = formView.querySelector('.status');
        if (existingStatus) existingStatus.remove();
        formView.appendChild(status);
        setTimeout(() => status.remove(), 3000);
      }
      
      // Reset form
      cancelEditCategory();
    }
    
    loadCategories();
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}

// Add new category (kept for backward compatibility, but now calls saveCategory)
async function addCategory() {
  // Reset editing state
  editingCategoryId = null;
  await saveCategory();
}

// Add default category to Firestore
async function addDefaultCategoryToFirestore(categoryName) {
  if (!categoryName) return;
  
  // Check if category already exists
  const snapshot = await db.collection('herb_categories')
    .where('name', '==', categoryName)
    .get();
  
  if (!snapshot.empty) {
    alert('❌ Danh mục này đã tồn tại trong Firestore!');
    loadCategories(); // Reload to show the existing category
    return;
  }
  
  try {
    await db.collection('herb_categories').add({
      name: categoryName,
      createdAt: firebase.firestore.FieldValue.serverTimestamp()
    });
    
    // Show success message
    const status = document.createElement('div');
    status.className = 'status success';
    status.textContent = `✅ Đã thêm "${categoryName}" vào Firestore thành công!`;
    status.style.marginTop = '20px';
    const formView = document.getElementById('manageCategoriesView');
    if (formView) {
      const existingStatus = formView.querySelector('.status');
      if (existingStatus) existingStatus.remove();
      formView.appendChild(status);
      setTimeout(() => status.remove(), 3000);
    }
    
    // Reload categories to show the new one with edit button
    loadCategories();
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}

// Delete category
async function deleteCategory(categoryId, categoryName) {
  if (!confirm(`⚠️ Bạn có chắc muốn xóa danh mục "${categoryName}"?`)) {
    return;
  }
  
  try {
    await db.collection('herb_categories').doc(categoryId).delete();
    loadCategories();
    
    // Show success message
    const status = document.createElement('div');
    status.className = 'status success';
    status.textContent = '✅ Đã xóa danh mục thành công!';
    status.style.marginTop = '20px';
    const formView = document.getElementById('manageCategoriesView');
    if (formView) {
      const existingStatus = formView.querySelector('.status');
      if (existingStatus) existingStatus.remove();
      formView.appendChild(status);
      setTimeout(() => status.remove(), 3000);
    }
  } catch (error) {
    alert('❌ Lỗi: ' + error.message);
  }
}

// Format date to Vietnamese format "10 Tháng 6, 2021"
function formatDate(date) {
  const months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 
                  'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
  const month = months[date.getMonth()];
  const day = date.getDate();
  const year = date.getFullYear();
  return `${day} ${month}, ${year}`;
}

// Update image preview when URL is entered
function updateImagePreview(imageUrl) {
  const imagePreview = document.getElementById('imagePreview');
  const previewImg = document.getElementById('previewImg');
  
  if (imageUrl && imageUrl.trim() !== '') {
    try {
      // Validate URL
      new URL(imageUrl);
      previewImg.src = imageUrl;
      imagePreview.style.display = 'block';
    } catch (e) {
      // Invalid URL, hide preview
      imagePreview.style.display = 'none';
    }
  } else {
    imagePreview.style.display = 'none';
  }
}

// Handle category image upload
async function handleCategoryImageUpload(event) {
  const file = event.target.files[0];
  if (!file) return;
  
  const imageInput = document.getElementById('newCategoryImage');
  const categoryImagePreview = document.getElementById('categoryImagePreview');
  const categoryPreviewImg = document.getElementById('categoryPreviewImg');
  
  // Validate file type
  if (!file.type.startsWith('image/')) {
    alert('❌ Vui lòng chọn file ảnh!');
    return;
  }
  
  // Validate file size (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    alert('❌ File ảnh quá lớn! Vui lòng chọn file nhỏ hơn 5MB.');
    return;
  }
  
  try {
    // Create a unique filename
    const timestamp = Date.now();
    const filename = `herb_categories/${timestamp}_${file.name}`;
    
    // Upload to Firebase Storage
    const storageRef = storage.ref().child(filename);
    const uploadTask = storageRef.put(file);
    
    // Wait for upload to complete
    const snapshot = await uploadTask;
    const downloadURL = await snapshot.ref.getDownloadURL();
    
    // Set the URL in the input field
    if (imageInput) imageInput.value = downloadURL;
    
    // Show preview
    if (categoryPreviewImg) categoryPreviewImg.src = downloadURL;
    if (categoryImagePreview) categoryImagePreview.style.display = 'block';
    
  } catch (error) {
    console.error('Upload error:', error);
    alert('❌ Lỗi khi tải ảnh: ' + error.message);
  }
}

// Update category image preview when URL is entered
function updateCategoryImagePreview(imageUrl) {
  const categoryImagePreview = document.getElementById('categoryImagePreview');
  const categoryPreviewImg = document.getElementById('categoryPreviewImg');
  
  if (imageUrl && imageUrl.trim() !== '') {
    try {
      // Validate URL
      new URL(imageUrl);
      if (categoryPreviewImg) categoryPreviewImg.src = imageUrl;
      if (categoryImagePreview) categoryImagePreview.style.display = 'block';
    } catch (e) {
      // Invalid URL, hide preview
      if (categoryImagePreview) categoryImagePreview.style.display = 'none';
    }
  } else {
    if (categoryImagePreview) categoryImagePreview.style.display = 'none';
  }
}

// Handle image upload
async function handleImageUpload(event) {
  const file = event.target.files[0];
  if (!file) return;
  
  const status = document.getElementById('status');
  const imageUrlField = document.getElementById('imageUrl');
  const imagePreview = document.getElementById('imagePreview');
  const previewImg = document.getElementById('previewImg');
  
  // Validate file type
  if (!file.type.startsWith('image/')) {
    status.className = 'status error';
    status.textContent = '❌ Vui lòng chọn file ảnh!';
    return;
  }
  
  // Validate file size (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    status.className = 'status error';
    status.textContent = '❌ File ảnh quá lớn! Vui lòng chọn file nhỏ hơn 5MB.';
    return;
  }
  
  try {
    status.className = 'status';
    status.textContent = '⏳ Đang tải ảnh lên...';
    
    // Create a unique filename
    const timestamp = Date.now();
    const filename = `herb_images/${timestamp}_${file.name}`;
    
    // Upload to Firebase Storage
    const storageRef = storage.ref().child(filename);
    const uploadTask = storageRef.put(file);
    
    // Wait for upload to complete
    const snapshot = await uploadTask;
    const downloadURL = await snapshot.ref.getDownloadURL();
    
    // Set the URL in the input field
    imageUrlField.value = downloadURL;
    
    // Show preview
    previewImg.src = downloadURL;
    imagePreview.style.display = 'block';
    
    status.className = 'status success';
    status.textContent = '✅ Đã tải ảnh lên thành công!';
    setTimeout(() => {
      status.textContent = '';
      status.className = 'status';
    }, 2000);
    
  } catch (error) {
    console.error('Upload error:', error);
    status.className = 'status error';
    status.textContent = '❌ Lỗi khi tải ảnh: ' + error.message;
  }
}

// Login admin
async function loginAdmin() {
  const email = document.getElementById('adminEmail').value.trim();
  const password = document.getElementById('adminPassword').value;
  const loginStatus = document.getElementById('loginStatus');
  
  if (!email || !password) {
    loginStatus.className = 'status error';
    loginStatus.textContent = '❌ Vui lòng nhập đầy đủ email và mật khẩu!';
    return;
  }
  
  try {
    loginStatus.className = 'status';
    loginStatus.textContent = '⏳ Đang đăng nhập...';
    
    await auth.signInWithEmailAndPassword(email, password);
    
    loginStatus.className = 'status success';
    loginStatus.textContent = '✅ Đăng nhập thành công!';
    
    // Hide login section and show main content
    setTimeout(() => {
      checkAuthState();
    }, 1000);
    
  } catch (error) {
    console.error('Login error:', error);
    loginStatus.className = 'status error';
    loginStatus.textContent = '❌ Lỗi: ' + error.message;
  }
}

// Logout admin
function logoutAdmin() {
  auth.signOut().then(() => {
    alert('✅ Đã đăng xuất!');
    checkAuthState();
  }).catch((error) => {
    alert('❌ Lỗi khi đăng xuất: ' + error.message);
  });
}

// Check authentication state (temporarily disabled - no login required)
function checkAuthState() {
  const loginSection = document.getElementById('loginSection');
  const mainContent = document.getElementById('mainContent');
  const logoutBtn = document.getElementById('logoutBtn');
  
  // Temporarily bypass authentication - always show main content
  loginSection.style.display = 'none';
  mainContent.style.display = 'block';
  if (logoutBtn) logoutBtn.style.display = 'none';
  
  // Original authentication check (commented out for now)
  /*
  auth.onAuthStateChanged((user) => {
    if (user) {
      loginSection.style.display = 'none';
      mainContent.style.display = 'block';
      if (logoutBtn) logoutBtn.style.display = 'block';
      console.log('✅ Đã đăng nhập:', user.email);
    } else {
      loginSection.style.display = 'block';
      mainContent.style.display = 'none';
      if (logoutBtn) logoutBtn.style.display = 'none';
      console.log('❌ Chưa đăng nhập');
    }
  });
  */
}

// Initialize
window.onload = function() {
  checkAuthState();
  // Load content directly (no authentication required for now)
  switchTab('diseases');
  setupEditorShortcuts();
  // Load categories for herballibrary
  loadCategories();
};

