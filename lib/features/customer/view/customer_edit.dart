import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/constant/form_validation.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/core/widget/custom_textfield.dart';
import '../controller/customer_controller.dart';
import '../model/customer_model.dart';

class EditCustomerScreen extends StatelessWidget {
  final CustomerModel customer;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final controller = Get.find<CustomerController>();

  EditCustomerScreen({super.key, required this.customer}) {
    nameController.text = customer.name;
    addressController.text = customer.address;
    mobileController.text = customer.mobileNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Edit Customer'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //name
              CustomTextfield(
                prefixIcon: Icons.person,
                controller: nameController,
                name: 'Name',
                inputType: TextInputType.text,
                validator: FormValidator.validateName,
              ),
              const SizedBox(height: 16),

              //  address
              CustomTextfield(
                prefixIcon: Icons.group,
                controller: addressController,
                name: 'Address',
                maxLines: 2,
                inputType: TextInputType.text,
                validator: FormValidator.validateName,
              ),
              const SizedBox(height: 16),

              //number
              CustomTextfield(
                prefixIcon: Icons.phone,
                controller: mobileController,
                name: 'Mobile Numer',
                inputType: TextInputType.number,
                validator: FormValidator.validateQuantity,
              ),

              const SizedBox(height: 20),
              CustomButton(
                onTap: (){
                   if (_formKey.currentState!.validate()) {
                    final updatedCustomer = CustomerModel(
                      id: customer.id,
                      name: nameController.text,
                      address: addressController.text,
                      mobileNumber: mobileController.text,
                    );
                    controller.editCustomer(updatedCustomer);
                  }
                },
                btnColor: AppColor.buttonPrimary,
                btnText: 'Save Changes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
