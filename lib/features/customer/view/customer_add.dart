import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/constant/form_validation.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/core/widget/custom_textfield.dart';
import '../controller/customer_controller.dart';
import '../model/customer_model.dart';

class AddCustomerScreen extends StatelessWidget {
  final CustomerController controller = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Add Cusomer'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                onTap: () {
                  final newCustomer = CustomerModel(
                    id: '',
                    name: nameController.text,
                    address: addressController.text,
                    mobileNumber: mobileController.text,
                  );
                  controller.addCustomer(newCustomer);
               //   Get.back();
                },
                btnColor: AppColor.buttonPrimary,
                btnText: 'Add Customer'),
          ],
        ),
      ),
    );
  }
}
