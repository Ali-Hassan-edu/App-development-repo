# 🧾 Smart POS & Inventory Management App
**Flutter • Offline-First • Firebase-Ready**

## 📦 Download APK

[📥 Download Latest APK (Google Drive)](https://drive.google.com/file/d/1GurSJ8FJPWk6sKJKzFjnRQQoWGRi1KFS/view?usp=drivesdk)



A modern, scalable **Point of Sale (POS) & Inventory Management** application built with **Flutter**, designed for **small shops, cafés, and retail businesses**.

The app follows a **clean architecture**, works fully **offline**, and supports **cloud sync using Firebase (Spark – Free plan)**.

---

## ✨ Key Highlights

- 🛒 Fast POS & billing system  
- 📦 Inventory & stock management  
- 👥 Customer & ledger (credit/debit) tracking  
- 📊 Sales reports & analytics  
- 🧾 Professional receipt & PDF invoices  
- 💾 Offline-first (no internet required)  
- ☁️ Firebase Firestore online database  
- 🔐 Firebase Authentication  
- ☁️ Google Drive backup support  

---

## 🛒 Point of Sale (POS)

- Product listing with instant add-to-cart  
- Increment / decrement / remove cart items  
- Real-time:
  - Subtotal
  - Discount
  - Tax
  - Grand total  
- Multiple payment methods:
  - Cash
  - UPI
  - Card  
- Optimized checkout flow for daily shop usage  

---

## 🧾 Receipt & Invoice System

- Clean in-app receipt preview  
- Professional **PDF invoice generation**  
- Printable & shareable invoices  
- Unique invoice IDs  
- Customer name & phone support  

---

## 👥 Customer & Ledger Management

- Add, edit, delete customers  
- Search customers by name or phone  
- Attach customer to a sale  
- Walk-in customer support  
- Ledger system:
  - Debit
  - Credit
  - Payment  
- Automatic outstanding balance calculation  

---

## 📊 Reports & Analytics

### Sales Reports
- Today’s sales
- Monthly sales total
- Total transactions
- Average ticket size
- Recent sales history
- Item-wise sales aggregation
- Lightweight charts (no heavy chart libraries)

### Inventory & Purchase Reports
- Stock overview
- Purchase history
- Monthly purchase totals
- Designed for automatic stock updates

---

## 💾 Offline-First Storage

- Fully usable **without internet**
- Local persistence using:
  - SQLite (DAO layer)
  - SharedPreferences (lightweight data)
- Fast startup and low memory usage

---

## ☁️ Online Database (Firebase)

- Firebase Authentication:
  - Email / Password
  - Google Sign-In
  - Phone OTP  
- Cloud Firestore:
  - Products
  - Customers
  - Sales
  - Ledger entries  
- Secure Firestore rules  
- Uses **Firebase Spark (Free) plan**

---

## ☁️ Backup System

- Manual local backups
- Automatic backups on app background
- Google Drive backup:
  - Visible folder
  - User-owned backups
- Restore from local or Drive backup

---

## 🧱 Tech Stack

| Layer | Technology |
|-----|------------|
| UI | Flutter (Material 3) |
| State Management | Provider |
| Local Storage | SQLite, SharedPreferences |
| Backend | Firebase (Auth + Firestore) |
| PDF Generation | pdf package |
| Backup | Google Drive API |
| Unique IDs | uuid |
| Architecture | Feature-based + Repository pattern |

---




## 📁 Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_strings.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── validators.dart
│       └── formatters.dart
│
├── data/
│   ├── local/
│   │   └── db/
│   │       └── app_database.dart
│   │   └── dao/
│   │       ├── product_dao.dart
│   │       ├── category_dao.dart
│   │       ├── customer_dao.dart
│   │       ├── sale_dao.dart
│   │       ├── inventory_dao.dart
│   │       └── tax_discount_dao.dart
│   │
│   ├── remote/
│   │   ├── auth_remote.dart
│   │   ├── api_client.dart
│   │   ├── product_remote.dart
│   │   ├── customer_remote.dart
│   │   └── sale_remote.dart
│   │
│   ├── models/
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── customer.dart
│   │   ├── sale.dart
│   │   ├── sale_item.dart
│   │   ├── inventory_log.dart
│   │   ├── tax.dart
│   │   └── discount.dart
│   │
│   └── repositories/
│       ├── auth_repository.dart
│       ├── product_repository.dart
│       ├── customer_repository.dart
│       ├── sale_repository.dart
│       ├── inventory_repository.dart
│       ├── report_repository.dart
│       └── backup_repository.dart
│
├── services/
│   ├── auth_service.dart
│   ├── sync_service.dart
│   ├── backup_service.dart
│   └── connectivity_service.dart
│
├── state/
│   ├── auth/
│   │   └── auth_provider.dart
│   ├── navigation/
│   │   └── nav_provider.dart
│   ├── products/
│   │   └── product_provider.dart
│   ├── pos/
│   │   └── cart_provider.dart
│   ├── customers/
│   │   └── customer_provider.dart
│   ├── inventory/
│   │   └── inventory_provider.dart
│   └── reports/
│       └── report_provider.dart
│
├── ui/
│   ├── widgets/
│   │   ├── app_drawer.dart
│   │   ├── app_scaffold.dart
│   │   ├── primary_button.dart
│   │   └── app_text_field.dart
│   │
│   └── screens/
│       ├── splash/
│       │   └── splash_screen.dart
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── signup_screen.dart
│       ├── dashboard/
│       │   └── dashboard_screen.dart
│       ├── items/
│       │   ├── categories_screen.dart
│       │   └── products_screen.dart
│       ├── pos/
│       │   ├── bill_screen.dart
│       │   ├── cart_screen.dart
│       │   └── checkout_screen.dart
│       ├── customers/
│       │   ├── customers_screen.dart
│       │   └── customer_detail_screen.dart
│       ├── inventory/
│       │   ├── inventory_list_screen.dart
│       │   └── inventory_logs_screen.dart
│       ├── reports/
│       │   ├── sales_report_screen.dart
│       │   ├── purchase_report_screen.dart
│       │   └── item_sales_report_screen.dart
│       ├── tax_discount/
│       │   ├── tax_screen.dart
│       │   └── discount_screen.dart
│       └── settings/
│           └── settings_screen.dart

```

---

## 🔄 Application Flow

1. Select products  
2. Add items to cart  
3. Adjust quantities  
4. Checkout  
5. Select customer or walk-in  
6. Apply discount & tax  
7. Choose payment method  
8. Sale saved (offline / online)  
9. Receipt generated  
10. Reports updated  

---

## 🧪 Demo Data

Built-in demo generators:
- Demo sales data
- Demo purchase data

Useful for:
- UI testing
- Presentations
- Development without real data

---

## 🚀 Getting Started

### 1️⃣ Clone Repository
```bash
git clone https://github.com/your-username/smart_pos_inventory.git
cd smart_pos_inventory
2️⃣ Install Dependencies
flutter pub get

3️⃣ Firebase Setup (Free Plan)

Create Firebase project

Enable:

Authentication

Cloud Firestore

Add google-services.json

Use Spark (Free) plan

4️⃣ Run App
flutter run

📱 Supported Platforms

✅ Android

✅ iOS

⚠️ Web (PDF printing may need tweaks)

⚠️ Desktop (UI supported, printing OS-dependent)

🛠️ Planned Enhancements

* Barcode scanner integration

* Thermal printer support

* GST / VAT breakdown

* CSV / Excel export

* Automatic inventory stock sync

* Multi-store support

👨‍💻 Author

Ali Hassan
Flutter Developer & Software Engineer

📄 License

This project is developed for educational, learning, and portfolio purposes.

---

 


