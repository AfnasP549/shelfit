  import 'package:get/get.dart';
  import 'package:shelfit/features/customer/model/customer_model.dart';
  import 'package:shelfit/features/customer/repository/customer_repository.dart';

  class CustomerController extends GetxController {
    final CustomerRepository _repository = CustomerRepository();
    final RxList<CustomerModel> customers = <CustomerModel>[].obs;
    final RxBool isLoading = false.obs;

    @override
    void onInit(){
      fetchCustomers();
      super.onInit();
    }

    //!fetch
    Future<void> fetchCustomers()async{
      isLoading.value = true;
      try{
        customers.value = await _repository.fetchCustomers();
      }catch(e){
        Get.snackbar('Error', e.toString());
      }finally{
        isLoading.value = false;
      }
    }

    //!Add 
    Future<void> addCustomer(CustomerModel customer)async{
        try{
          await _repository.addCustomer(customer);
          fetchCustomers();
          Get.back();
          Get.snackbar('Success', '✅ Customer Added Successfully');
        }catch(e){
          Get.snackbar('Error', e.toString());
        }
    }


    //! Edit
    Future<void> editCustomer(CustomerModel customer) async {
      try {
        await _repository.editCustomer(customer);
        fetchCustomers();
        Get.back();
        Get.snackbar('Success', 'Customer updated successfully');
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }

    //! Delete
    Future<void> deleteCustomer(String customerId) async {
      try {
        await _repository.deleteCustomer(customerId);
        fetchCustomers();
        Get.snackbar('Success', 'Customer deleted successfully');
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
  }