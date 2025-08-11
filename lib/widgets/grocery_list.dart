import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

/// GroceryList is a stateful widget that displays a list of grocery items.
/// It fetches the items from a Firebase Realtime Database, allows adding new items,
/// and supports swipe-to-delete functionality with optimistic UI updates.
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  // Holds the list of grocery items currently displayed.
  List<GroceryItem> _groceryItems = [];
  // Indicates if the app is currently loading data from the backend.
  var _isLoading = true;
  // Stores any error message to display to the user.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch the initial list of grocery items when the widget is first created.
    _loadInitialItems();
  }

  /// Fetches the grocery items from the Firebase backend.
  /// Handles loading state, error state, and parses the response into GroceryItem objects.
  void _loadInitialItems() async {
    final url = Uri.https(
      'shopping-list-df3d2-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        // If the response status code is an error, set an error message.
        if (response.statusCode >= 400) {
          _errorMessage = 'Failed to load items';
        }
      });
      // If the response body is 'null', there are no items to load.
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // Parse the JSON response into a map.
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      // Convert each entry in the map to a GroceryItem object.
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((entry) => entry.value.name == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      // Update the state with the loaded items and stop the loading indicator.
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      // If an error occurs, display a generic error message.
      setState(() {
        _errorMessage = 'Something went wrong!';
      });
    }
  }

  /// Navigates to the NewItem screen and adds the returned item to the list.
  void _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );
    // If the user cancels, do nothing.
    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  /// Removes an item from the list both locally and from the backend.
  /// If the backend deletion fails, the item is re-inserted into the list.
  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    // Optimistically remove the item from the list.
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
      'shopping-list-df3d2-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // If the deletion fails, re-add the item to the list.
      setState(() {
        _groceryItems.insert(index, item);
        // _errorMessage = 'Failed to delete item';
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default content shown when there are no items.
    Widget content = const Center(
      child: Text(
        'No items added yet',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    // Show a loading spinner while fetching data.
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    // If there are items, display them in a scrollable list with swipe-to-delete.
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id),
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              final removedItem = _groceryItems[index];
              _removeItem(removedItem);
              // Show a snackbar notification when an item is removed.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      '${removedItem.name} removed!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24.0,
                height: 24.0,
                color: _groceryItems[index].category.color,
              ),
              subtitle: Text(_groceryItems[index].category.name),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          );
        },
      );
    }

    // If an error occurred, display the error message.
    if (_errorMessage != null) {
      content = Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }
    // Main scaffold with app bar and dynamic body content.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
