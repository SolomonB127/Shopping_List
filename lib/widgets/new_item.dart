import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

/// NewItem is a stateful widget that provides a form for adding a new grocery item.
/// It validates user input, sends the new item to the Firebase backend,
/// and returns the created item to the previous screen.
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  // Key to identify and validate the form.
  final _formKey = GlobalKey<FormState>();
  // Stores the entered name for the new item.
  var _enteredName = '';
  // Stores the entered quantity for the new item.
  var _enteredQuantity = 0;
  // Stores the selected category for the new item.
  var _selectedCategory = categories[Categories.vegetables]!;
  // Indicates if a network request is in progress.
  var _isSending = false;

  /// Validates the form, sends a POST request to Firebase,
  /// and pops the screen with the new GroceryItem if successful.
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
        'shopping-list-df3d2-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.name,
        }),
      );
      final Map<String, dynamic> resData = json.decode(response.body);
      if (!mounted) return;
      // Return the new item to the previous screen.
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Main scaffold for the add item form.
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Text field for the item name.
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: ' Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Please enter a valid name (1-50 characters)';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              const SizedBox(height: 12.0),

              // Row for quantity input and category dropdown.
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quantity input field.
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Please enter a valid quantity (greater than 0)';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Category dropdown selector.
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 10.0),
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Row for Reset and Add Item buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reset button to clear the form.
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(height: 12.0),
                  // Add Item button, shows loading indicator if sending.
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16.0,
                            width: 16.0,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
