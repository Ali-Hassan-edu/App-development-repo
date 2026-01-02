🧾 Smart POS & Inventory Management App (Flutter)

A fully offline-first, modern Point of Sale (POS) system built with Flutter, designed for small shops, cafés, and retail stores.
The app supports billing, cart management, customers, receipts (PDF), sales reports, and inventory tracking — all without requiring a backend.

✨ Features
🛒 Point of Sale (POS)

Product listing with instant add-to-cart

Increment / decrement / remove cart items

Real-time subtotal, tax, discount, and grand total

Multiple payment methods (Cash / UPI / Card)

Fast checkout flow

🧾 Receipt System

Beautiful in-app receipt screen

Professional PDF receipt generation

Printable / shareable invoice

Customer name & phone support

Unique invoice IDs

👥 Customer Management

Add, edit, delete customers

Search by name or phone

Attach customer to a sale

Walk-in customer support

📊 Sales Reports & Analytics

Sales Today / Monthly Sales

Monthly transactions count

Average ticket size

Last N days sales chart (no external chart packages)

Recent sales history

Item-wise sales aggregation

Demo data generator for testing

📦 Purchase & Inventory Reports

Purchase history with suppliers

Monthly purchase totals

Purchase demo generator

Designed to integrate with inventory stock updates

💾 Offline-First Storage

Uses SharedPreferences

No backend or internet required

Persistent local data

Fast startup and low overhead

🧱 Tech Stack
Layer	Technology
UI	Flutter (Material 3)
State Management	Provider
Storage	SharedPreferences
PDF Generation	pdf package
UUID	uuid
Architecture	Feature-based (UI / State / Data)


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
🔄 Application Flow

Select Products → Add to cart

Cart Screen → Adjust quantities

Checkout Screen

Select customer

Apply discount & tax

Choose payment method

Payment

Sale saved locally

Cart cleared

Receipt

View receipt

Generate PDF

Reports

Sales analytics

Purchase history

Item performance

🧪 Demo Data

The app includes demo data generators:

Generate demo sales (Reports → Menu)

Generate demo purchases (Purchase Report → Menu)

This helps during:

UI testing

Presentation

Development without real data

🚀 Getting Started
1️⃣ Clone Repository
git clone <your-repo-url>
cd smart_pos_inventory

2️⃣ Install Dependencies
flutter pub get

3️⃣ Run App
flutter run

📱 Supported Platforms

✅ Android

✅ iOS

⚠️ Web (PDF printing may need adjustments)

⚠️ Desktop (UI supported, printing depends on OS)

🛠️ Future Enhancements (Planned)

Inventory stock auto-update on purchases

Barcode scanner integration

Thermal printer support

GST / VAT breakdown

CSV / Excel export

Cloud sync (Firebase / Supabase)

Multi-store support

Role-based access (Admin / Cashier)

👨‍💻 Author

Ali Hassan
Flutter Developer & Software Engineer

📄 License

This project is for educational and portfolio purposes.
You may reuse and modify it with attribution.