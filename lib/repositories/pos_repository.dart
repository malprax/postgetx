import '../models/category_model.dart';
import 'package:postgetx/app/data/models/customer_model.dart';
import '../models/expense_model.dart';
import '../models/menu_item_model.dart';
import '../models/menu_variant.dart';
import '../models/order_model.dart';
import 'notification_repository.dart';
import 'pos_operation_result.dart';

abstract class PosRepository implements NotificationRepository {
  // CATEGORY

  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> addCategory(
    String name, {
    String iconName = 'other',
  });

  Future<void> updateCategory(
    String id,
    String name, {
    String iconName = 'other',
  });

  Future<void> deleteCategory(String id);

  // PRODUCT

  Future<List<MenuItemModel>> getProducts();

  Future<MenuItemModel> addProduct({
    required String name,
    required String categoryId,
    required String categoryName,
    required List<MenuVariant> variants,
    String sku = '',
    int stock = 0,
    int lowStockThreshold = 5,
    String imageBase64 = '',
    String imageMimeType = '',
    String imageName = '',
  });

  Future<void> updateProduct(MenuItemModel product);

  Future<void> adjustStock(
    String productId,
    int quantityDelta,
  );

  Future<void> deleteProduct(String id);

  // TRANSACTION

  Future<List<OrderModel>> getTransactions({
    bool includeDeleted = false,
  });

  Future<PosOperationResult<OrderModel>> completeSale(
    OrderModel order,
  );

  Future<PosOperationResult<OrderModel>> saveOpenOrder(
    OrderModel order,
  );

  Future<PosOperationResult<OrderModel>> cancelOpenOrder(
    String id,
    String reason,
  );

  Future<PosOperationResult<void>> deleteOpenOrder(
    String id,
  );

  Future<PosOperationResult<OrderModel>> softDeleteOrder(
    String id,
    String reason,
  );

  Future<PosOperationResult<OrderModel>> restoreOrder(
    String id,
  );

  Future<PosOperationResult<OrderModel>> refundSale(
    String id,
    String reason, {
    bool restoreStock = true,
  });

  Future<PosOperationResult<OrderModel>> updateReceiptStatus(
    String id,
    String receiptStatus,
  );

  Future<void> saveTransaction(OrderModel order);

  // CUSTOMER

  Future<List<CustomerModel>> getCustomers({
    bool includeDeleted = false,
  });

  Future<CustomerModel?> getCustomerById(String id);

  Future<CustomerModel> createCustomer(
    CustomerModel customer,
  );

  Future<CustomerModel> updateCustomer(
    CustomerModel customer,
  );

  Future<PosOperationResult<CustomerModel>> deleteCustomer(
    String id, {
    String deletedBy = '',
  });

  Future<PosOperationResult<CustomerModel>> restoreCustomer(
    String id, {
    String restoredBy = '',
  });

  Future<List<CustomerModel>> searchCustomers(
    String query, {
    bool includeDeleted = false,
  });

  Future<CustomerModel?> findCustomerByPhone(
    String phone,
  );

  Future<CustomerModel?> findCustomerByMembershipId(
    String membershipId,
  );

  // EXPENSE

  Future<List<ExpenseModel>> getExpenses();

  Future<void> saveExpense(
    ExpenseModel expense,
  );

  Future<void> deleteExpense(String id);

  // DEMO DATA

  Future<void> resetDemoData();
}
