import 'package:uuid/uuid.dart';
import '../local/dao/product_dao.dart';
import '../local/dao/inventory_dao.dart';
import '../models/product.dart';
import '../models/inventory_log.dart';

class ProductRepository {
  final ProductDao productDao;
  final InventoryDao inventoryDao;

  ProductRepository(this.productDao, this.inventoryDao);

  Future<List<Product>> getAll() => productDao.getAll();

  Future<void> add({
    required String name,
    String? sku,
    String? category,
    required double price,
    double? cost,
    int stock = 0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final p = Product(
      id: const Uuid().v4(),
      name: name,
      sku: sku,
      category: category,
      price: price,
      cost: cost,
      stock: stock,
      createdAt: now,
      updatedAt: now,
    );
    await productDao.insert(p);

    if (stock != 0) {
      await inventoryDao.insertLog(
        InventoryLog(
          id: const Uuid().v4(),
          productId: p.id,
          type: 'ADJUST',
          qty: stock,
          note: 'Initial Stock',
          createdAt: now,
        ),
      );
    }
  }

  Future<void> update(Product p) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await productDao.update(p.copyWith(updatedAt: now));
  }

  Future<void> delete(String id) => productDao.delete(id);

  Future<void> stockIn({required Product p, required int qty, String? note}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newStock = p.stock + qty;
    await productDao.updateStock(p.id, newStock, now);
    await inventoryDao.insertLog(
      InventoryLog(
        id: const Uuid().v4(),
        productId: p.id,
        type: 'IN',
        qty: qty,
        note: note,
        createdAt: now,
      ),
    );
  }

  Future<void> stockOut({required Product p, required int qty, String? note}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newStock = (p.stock - qty) < 0 ? 0 : (p.stock - qty);
    await productDao.updateStock(p.id, newStock, now);
    await inventoryDao.insertLog(
      InventoryLog(
        id: const Uuid().v4(),
        productId: p.id,
        type: 'OUT',
        qty: qty,
        note: note,
        createdAt: now,
      ),
    );
  }
}
