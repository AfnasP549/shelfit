// lib/features/inventory_item/view/search_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/inventory_item/widget/item_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final InventoryController controller = Get.find<InventoryController>();
  final TextEditingController searchController = TextEditingController();
  final RxList<InventoryModel> searchResults = <InventoryModel>[].obs;
  final RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    // Initialize search results with all items
    searchResults.assignAll(controller.items);
    
    // Add listener to search field
    searchController.addListener(() {
      performSearch(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void performSearch(String query) {
    isSearching.value = true;
    
    if (query.isEmpty) {
      // If query is empty, show all items
      searchResults.assignAll(controller.items);
    } else {
      // Search by name and description
      final results = controller.items.where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      searchResults.assignAll(results);
    }
    
    isSearching.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Search Inventory',
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(
                color: AppColor.textprimaryColor
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or description',
                hintStyle: TextStyle(
                  color: AppColor.texttertiaryColor
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    performSearch('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Results List
          Expanded(
            child: Obx(() {
              if (isSearching.value) {
                return Center(child: Lottie.asset('asset/loading.json'));
              }
              
              if (searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'asset/empty.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No matching items found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchResults[index];
                  return _buildInventoryItem(context, item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, InventoryModel item) {
    return Card(
    //  color: AppColor.bottomtertiary,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.description,style: TextStyle(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    'STOCK: ${item.quantity}',
                    style: TextStyle(
                      color: AppColor.textsecondryColor,
                    ),
                  ),
                  backgroundColor: AppColor.tertiaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(item.price),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            )
          ],
        ),
        onTap: () => showItemDetails(context, item, controller),
      ),
    );
  }
}