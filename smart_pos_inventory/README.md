# smart_pos_inventory

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


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
