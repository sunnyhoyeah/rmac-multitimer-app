# Google Play Store 草稿版本問題解決方案

## 問題描述
當您嘗試上傳新版本到 Google Play Store 時，遇到「測試群組已有草稿版本」的錯誤。

## 原因
Google Play Store 的內部測試軌道中已經有一個待處理的草稿版本，需要先處理該草稿才能上傳新版本。

## 解決方案

### 方案一：刪除現有草稿版本
1. 進入 **Google Play Console**
2. 選擇您的應用程式
3. 前往 **發布 > 測試 > 內部測試**
4. 找到草稿版本並點擊 **刪除草稿**
5. 然後上傳新的 AAB 檔案

### 方案二：使用更高的版本代碼（推薦）
我們已經將版本代碼從 55/56 增加到 **57**：

- **新版本**: 1.0.55 (Build 57)
- **AAB 檔案**: `build/app/outputs/bundle/release/app-release.aab`
- **大小**: 43.8MB
- **狀態**: ✅ 已修復崩潰問題，包含代碼混淆停用

## 上傳步驟

1. **進入 Google Play Console**
   - 前往您的應用程式頁面

2. **選擇內部測試軌道**
   - 發布 > 測試 > 內部測試

3. **上傳新 AAB**
   - 點擊「建立新版本」
   - 上傳 `build/app/outputs/bundle/release/app-release.aab`
   - 版本代碼 57 應該會被接受

4. **完成發布**
   - 填寫版本備註（可選）
   - 點擊「檢查」然後「開始推出到內部測試」

## 建置指令
如果需要重新建置：

```bash
# 使用 Makefile
make build-release

# 或手動建置
flutter clean
flutter pub get
flutter build appbundle --release
```

## 重要提醒
- ✅ 版本代碼必須遞增（不能重複使用）
- ✅ 應用程式已修復啟動崩潰問題
- ✅ 使用正確的發布簽名
- ✅ 符合 Google Play Store 要求

## 疑難排解
如果仍然遇到問題：
1. 確認 Google Play Console 中沒有其他待處理的草稿
2. 檢查版本代碼是否確實是 57
3. 確認上傳的是 AAB 檔案而不是 APK
