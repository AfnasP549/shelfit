// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/features/customer/controller/customer_controller.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/sales/controller/sales_controller.dart';
import 'package:shelfit/features/sales/view/sales_screen.dart';
import 'package:shelfit/features/sales/widget/customer_dropdown_widget.dart';
import 'package:shelfit/features/sales/widget/date_picker_widget.dart';
import 'package:shelfit/features/sales/widget/product_dropdown.dart';
import 'package:shelfit/features/sales/widget/quantity_selector.dart';

class SalesAddScreen extends StatefulWidget {
  const SalesAddScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerController customerController = Get.find<CustomerController>();
  final InventoryController inventoryController =
      Get.find<InventoryController>();
  final SalesController salesController = Get.find<SalesController>();

  String? _selectedCustomerId;
  String? _selectedProductId;
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    customerController.fetchCustomers();
    inventoryController.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: ('Record Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              // padding: EdgeInsets.all(16),
              child: Card(
                color: AppColor.tertiaryColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.shopping_cart,
                            size: 48,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            "New Sale Entry",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                        const Divider(height: 40),

                        //! Date Picker
                        DatePickerWidget(
                            initialDate: _selectedDate,
                            onDateSelected: (pickedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }),

                        SizedBox(height: 20),

                        //! Customer Dropdown
                        CustomerDropdownWidget(
                            selectedCustomerId: _selectedCustomerId,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCustomerId = newValue;
                              });
                            }),

                        SizedBox(height: 20),

                        //! Product Dropdown
                        ProductDropdown(
                          selectedProductId: _selectedProductId,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedProductId = newValue;
                            });
                          },
                        ),

                        SizedBox(height: 20),

                        //! Quantity Selector
                        QuantitySelector(
                          quantity: _quantity,
                          onAdd: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                          onRemove: () {
                            if (_quantity > 1) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                        ),

                        SizedBox(height: 20),

                        //! Total Price Display
                        Obx(() {
                          final selectedProduct =
                              inventoryController.items.firstWhereOrNull(
                            (item) => item.id == _selectedProductId,
                          );
                          if (selectedProduct != null) {
                            double totalPrice =
                                _quantity * selectedProduct.price;
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(22.0),
                                  child: Text(
                                    "Total Price: ₹${totalPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        color: AppColor.textprimaryColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          }
                          return SizedBox();
                        }),

                        SizedBox(height: 30),

                        //! Submit Button
                        CustomButton(
                          btnColor: AppColor.buttonPrimary,
                          onTap: () async {
                            if (_selectedCustomerId == null ||
                                _selectedProductId == null) {
                              Get.snackbar("Error",
                                  "Please select a customer and product");
                              return;
                            }

                            //product
                            final selectedProduct =
                                inventoryController.items.firstWhereOrNull(
                              (item) => item.id == _selectedProductId,
                            );

                            if (selectedProduct == null) {
                              Get.snackbar(
                                  "Error", "Invalid product selection");
                              return;
                            }

                            //customer
                            final selectedCustomer =
                                customerController.customers.firstWhereOrNull(
                              (customer) => customer.id == _selectedCustomerId,
                            );

                            if (selectedCustomer == null) {
                              Get.snackbar(
                                  "Error", "Invalid customer selection");
                              return;
                            }

                            if (_quantity > selectedProduct.quantity) {
                              Get.snackbar(
                                  "Error", "Not enough stock available");
                              return;
                            }

                            await salesController.recordSale(
                              customerId: _selectedCustomerId!,
                              productId: _selectedProductId!,
                              productName: selectedProduct.name,
                              customerName: selectedCustomer.name,
                              quantity: _quantity,
                              pricePerUnit: selectedProduct.price,
                              paymentMethod: "Cash", // Can be modified
                              saleDate: _selectedDate,
                            );

                            Get.off(SalesHistoryScreen());
                            Lottie.asset('asset/loading.json');
                          },
                          btnText: 'Submit',
                          btnTextColor: AppColor.textsecondryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
