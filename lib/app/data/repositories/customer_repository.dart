import 'package:postgetx/app/data/models/customer_model.dart';

abstract class CustomerRepository {
  /// Mengambil seluruh customer.
  ///
  /// Secara default hanya mengembalikan customer aktif.
  /// Gunakan [includeDeleted] untuk menyertakan customer yang berada di Trash.
  Future<List<CustomerModel>> getCustomers({
    bool includeDeleted = false,
  });

  /// Mengambil satu customer berdasarkan ID.
  ///
  /// Mengembalikan `null` apabila customer tidak ditemukan.
  Future<CustomerModel?> getCustomerById(
    String id, {
    bool includeDeleted = false,
  });

  /// Mencari customer berdasarkan nomor telepon atau WhatsApp.
  ///
  /// Nomor harus dibandingkan menggunakan nilai yang telah dinormalisasi.
  Future<CustomerModel?> findCustomerByPhone(
    String phone, {
    bool includeDeleted = false,
  });

  /// Mencari customer berdasarkan kata kunci.
  ///
  /// Implementasi repository sebaiknya mencakup pencarian berdasarkan:
  /// - nama;
  /// - membership ID;
  /// - WhatsApp;
  /// - nomor telepon;
  /// - email.
  Future<List<CustomerModel>> searchCustomers(
    String query, {
    bool includeDeleted = false,
  });

  /// Membuat customer baru.
  ///
  /// Repository bertanggung jawab untuk:
  /// - melakukan trim terhadap input;
  /// - menormalisasi WhatsApp dan nomor telepon;
  /// - membuat ID customer apabila belum tersedia;
  /// - membuat membership ID apabila masih kosong;
  /// - memvalidasi nomor duplikat;
  /// - menyimpan waktu pembuatan dan pembaruan.
  Future<CustomerModel> createCustomer(
    CustomerModel customer,
  );

  /// Memperbarui customer yang sudah ada.
  ///
  /// Repository harus mempertahankan:
  /// - ID customer;
  /// - waktu pembuatan;
  /// - status soft delete;
  /// - metadata delete dan restore.
  Future<CustomerModel> updateCustomer(
    CustomerModel customer,
  );

  /// Memindahkan customer ke Trash menggunakan soft delete.
  ///
  /// Customer tidak boleh dihapus permanen dari penyimpanan.
  Future<CustomerMutationResult> deleteCustomer(
    String customerId,
  );

  /// Mengembalikan customer dari Trash.
  Future<CustomerMutationResult> restoreCustomer(
    String customerId,
  );
}

class CustomerMutationResult {
  final bool isSuccess;

  final String message;

  final CustomerModel? value;

  const CustomerMutationResult({
    required this.isSuccess,
    required this.message,
    this.value,
  });

  const CustomerMutationResult.success({
    required String message,
    CustomerModel? value,
  }) : this(
          isSuccess: true,
          message: message,
          value: value,
        );

  const CustomerMutationResult.failure({
    required String message,
    CustomerModel? value,
  }) : this(
          isSuccess: false,
          message: message,
          value: value,
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CustomerMutationResult &&
        other.isSuccess == isSuccess &&
        other.message == message &&
        other.value == value;
  }

  @override
  int get hashCode {
    return Object.hash(
      isSuccess,
      message,
      value,
    );
  }

  @override
  String toString() {
    return 'CustomerMutationResult('
        'isSuccess: $isSuccess, '
        'message: $message, '
        'value: $value'
        ')';
  }
}
