
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import '../repository/sales_repository.dart';

class SalesController extends GetxController {
  final SalesRepository salesRepository = SalesRepository();

  var customers = <Map<String, dynamic>>[].obs;
  var selectedCustomer = RxnString();

  var products = <Map<String, dynamic>>[].obs;
  var selectedProduct = RxnString();

  var quantity = 1.obs;
  var sales = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  
  // Customer ledger properties
  var filteredSales = <Map<String, dynamic>>[].obs;
  var selectedLedgerCustomer = RxnString();
  var isLedgerFiltered = false.obs;
  
  // Add a flag to track initialization status
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }
  
  Future<void> initializeData() async {
    isLoading.value = true;
    try {
      await loadCustomers();
      await loadProducts();
      await loadSales();
      isInitialized.value = true;
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize data");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Customers
  Future<void> loadCustomers() async {
    try {
      final result = await salesRepository.fetchCustomers();
      // Add debug output to check the data being returned
      if (result.isNotEmpty) {
      }
      
      customers.assignAll(result);
      update();
    } catch (e) {
      throw Exception("Error loading customers: $e");
    }
  }

  // Fetch Products
  Future<void> loadProducts() async {
    try {
      final result = await salesRepository.fetchProducts();
      products.assignAll(result);
      update();
    } catch (e) {
      throw Exception("Error loading products: $e");
    }
  }

  // Fetch Sales
  Future<void> loadSales() async {
    isLoading.value = true;
    try {
      // Check if user is logged in first
      if (salesRepository.uid == null) {
        await Future.delayed(Duration(seconds: 1)); // Wait briefly
        if (salesRepository.uid == null) {
          Get.snackbar("Error", "Please log in to view sales");
          isLoading.value = false;
          return;
        }
      }
      
      var result = await salesRepository.fetchSales();
      sales.assignAll(result);
      
      // Update filtered sales too
      if (isLedgerFiltered.value && selectedLedgerCustomer.value != null) {
        filterSalesByCustomer(selectedLedgerCustomer.value!);
      } else {
        filteredSales.assignAll(result);
      }
      
      update();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch sales");
    } finally {
      isLoading.value = false;
    }
  }

  // Select Customer
  void selectCustomer(String id) {
    selectedCustomer.value = id;
    update();
  }

  // Select Product
  void selectProduct(String id) {
    selectedProduct.value = id;
    update();
  }

  // Increment Quantity
  void incrementQuantity() {
    quantity.value++;
    update();
  }

  // Decrement Quantity
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
    update();
  }

  // Record Sale & Update Stock
  Future<void> recordSale({
    required String customerId,
    required String productId,
    required String productName,
    required String customerName,
    required int quantity,
    required double pricePerUnit,
    required String paymentMethod,
    required DateTime saleDate,
  }) async {
    try {
      double totalPrice = quantity * pricePerUnit;

      await salesRepository.addSale(
        customerId: customerId,
        productId: productId,
        productName: productName,
        customerName: customerName,
        quantity: quantity,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        saleDate: saleDate,
      );

      await loadProducts(); // Refresh product list after sale
      await loadSales(); // Refresh sales list

      Get.snackbar(
        backgroundColor: AppColor.snackBarPrimary,
        animationDuration: Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        colorText: AppColor.textsecondryColor,
        "✅ Success", "Sale recorded successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to record sale: ${e.toString()}");
    }
  }
  
  // Customer Ledger Methods
  
  // Filter sales by customer ID
 void filterSalesByCustomer(String customerId) {
  // Validate that the customer ID exists
  final customerExists = customers.any((c) => c['uid']?.toString() == customerId);
  
  if (!customerExists) {
    clearLedgerFilter();
    return;
  }
  
  selectedLedgerCustomer.value = customerId;
  isLedgerFiltered.value = true;
  
  // Filter sales for the selected customer
  filteredSales.assignAll(
    sales.where((sale) => sale['customerId'] == customerId).toList()
  );
  update();
}
  
  // Clear customer filter
  void clearLedgerFilter() {
    selectedLedgerCustomer.value = null;
    isLedgerFiltered.value = false;
    filteredSales.assignAll(sales);
    update();
  }

double getCustomerTotal(String customerId) {
  // Filter sales where the customerId field matches the given ID
  final customerSales = sales.where((sale) {
    bool matches = sale['customerId'] == customerId;
    if (matches) {
    }
    return matches;
  }).toList();
  
  // Calculate total
  double total = 0.0;
  for (var sale in customerSales) {
    // Use proper null-safety and type conversion
    if (sale['totalPrice'] != null) {
      // Handle different possible types
      if (sale['totalPrice'] is double) {
        total += sale['totalPrice'] as double;
      } else if (sale['totalPrice'] is int) {
        total += (sale['totalPrice'] as int).toDouble();
      } else if (sale['totalPrice'] is String) {
        total += double.tryParse(sale['totalPrice']) ?? 0.0;
      }
    }
  }
  
  return total;
} 
  
  // Get total number of items purchased by a customer
  int getCustomerTotalItems(String uid) {
    int total = 0;
    for (var sale in sales) {
      if (sale['uid'] == uid) {
        // Properly handle the dynamic type from Map
        if (sale['quantity'] is int) {
          total += sale['quantity'] as int;
        } else if (sale['quantity'] is num) {
          total += (sale['quantity'] as num).toInt();
        }
      }
    }
    return total;
  }
  
  // Get most recent purchase date for a customer
  DateTime? getCustomerLastPurchase(String customerId) {
    DateTime? lastDate;
    for (var sale in sales) {
      if (sale['customerId'] == customerId) {
        try {
          DateTime saleDate = DateTime.parse(sale['saleDate']);
          if (lastDate == null || saleDate.isAfter(lastDate)) {
            lastDate = saleDate;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    }
    return lastDate;
  }
  
}