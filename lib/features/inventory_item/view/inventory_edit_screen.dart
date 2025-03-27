import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/constant/form_validation.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/core/widget/custom_textfield.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';

class EditItemScreen extends StatefulWidget {
  final String itemId;

  const EditItemScreen({super.key, required this.itemId});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final InventoryController _controller = Get.find<InventoryController>();

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  Future<void> _loadItemData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final item = await _controller.getItem(widget.itemId);
      if (item != null) {
        // Populate the form fields with item data
        _nameController.text = item.name;
        _descriptionController.text = item.description;
        _quantityController.text = item.quantity.toString();
        _priceController.text = item.price.toString();
      } else {
        error = 'Item not found';
      }
    } catch (e) {
      error = 'Failed to load item: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Edit Item'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: Lottie.asset('asset/loading.json'))
            : error != null
                ? Center(
                    child: Text(error!, style: TextStyle(color: Colors.red)))
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          //!name
                          CustomTextfield(
                            controller: _nameController,
                            name: 'Item Name',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.inventory,
                            validator: FormValidator.validateName,
                          ),
                          const SizedBox(height: 16),

                          //!Description
                          CustomTextfield(
                            controller: _descriptionController,
                            name: 'Description',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.description,
                            validator: FormValidator.validateDescription,
                          ),
                          const SizedBox(height: 16),

                          //!Quantity
                          CustomTextfield(
                            controller: _quantityController,
                            name: 'Quantity',
                            inputType: TextInputType.number,
                            prefixIcon: Icons.numbers,
                            validator: FormValidator.validateQuantity,
                          ),
                          const SizedBox(height: 16),

                          //!price
                          CustomTextfield(
                            controller: _priceController,
                            name: 'Price',
                            inputType: TextInputType.number,
                            prefixIcon: Icons.attach_money,
                            validator: FormValidator.validatePrice,
                          ),
                          const SizedBox(height: 24),

                          //!button
                          Obx(() => _controller.isLoading.value
                              ? Center(
                                  child: Lottie.asset('asset/loading.json'))
                              : CustomButton(
                                  onTap: _submitForm,
                                  btnText: 'Update Item',
                                  btnColor: AppColor.bottomIconPrimary,
                                )),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final quantity = int.parse(_quantityController.text.trim());
      final price = double.parse(_priceController.text.trim());

      final success = await _controller.updateItem(
        id: widget.itemId,
        name: name,
        description: description,
        quantity: quantity,
        price: price,
      );

      if (success) {
        Get.back(result: true);
        Get.snackbar(
          '✅ Success',
          'Item updated successfully',
          snackPosition: SnackPosition.BOTTOM,
           backgroundColor: AppColor.snackBarPrimary,
           colorText: AppColor.textsecondryColor,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}
