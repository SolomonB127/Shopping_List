# Shopping List Flutter App

A simple, modern Flutter app for managing your grocery shopping list.  
This app demonstrates clean architecture, Firebase Realtime Database integration, and a responsive UI with category-based color coding.

---

## Features

- **Add new grocery items** with name, quantity, and category.
- **View all items** in a scrollable, color-coded list.
- **Swipe to delete** items with optimistic UI updates.
- **Persistent storage** using Firebase Realtime Database.
- **Form validation** for robust user input.
- **Category selection** with custom colors for each type.

---

## Screenshots

> _Add your screenshots here!_

| Home Screen | Add Item | Swipe to Delete |
|-------------|----------|----------------|
| ![Home](/assets/screenshots/home.png) | ![Add](/assets/screenshots/add.png) | ![Delete](/assets/screenshots/delete.png) |

---

## Demo

Try the app live on [Appetize.io](https://appetize.io/)  
<!-- > _Replace this link with your actual Appetize demo URL._ -->

---

## Project Structure

```
lib/
├── data/
│   └── categories.dart        # Defines all available grocery categories
├── models/
│   └── category.dart          # Category model and enum
├── widgets/
│   ├── grocery_list.dart      # Main grocery list screen
│   └── new_item.dart          # Add new item form
```

---

## Key Files Overview

### `lib/data/categories.dart`

Defines all available grocery categories as a constant map, mapping each `Categories` enum value to a `Category` object (with display name and color).

```dart
/// A constant map that defines all available grocery categories in the app.
/// Each entry maps a [Categories] enum value to a [Category] object,
/// which contains a display name and a color for UI representation.
const categories = {
  Categories.vegetables: Category('Vegetables', Color.fromARGB(255, 0, 255, 128)),
  // ... other categories ...
};
```

---

### `lib/models/category.dart`

Defines the `Categories` enum and the `Category` class, which holds the name and color for each category.

```dart
enum Categories { vegetables, fruit, meat, dairy, carbs, sweets, spices, convenience, hygiene, other }

class Category {
  final String name;
  final Color color;
  const Category(this.name, this.color);
}
```

---

### `lib/widgets/grocery_list.dart`

The main screen of the app.  
- Fetches grocery items from Firebase on startup.
- Displays a loading spinner, error message, or the list of items.
- Each item can be swiped to delete (with backend sync and optimistic UI).
- Floating action button to add a new item.

```dart
class GroceryList extends StatefulWidget { ... }

class _GroceryListState extends State<GroceryList> {
  // Holds the list of grocery items currently displayed.
  List<GroceryItem> _groceryItems = [];
  // Indicates if the app is currently loading data from the backend.
  var _isLoading = true;
  // Stores any error message to display to the user.
  String? _errorMessage;

  // Fetches items from Firebase and updates state.
  void _loadInitialItems() async { ... }

  // Navigates to the NewItem screen and adds the returned item to the list.
  void _addItem() async { ... }

  // Removes an item from the list both locally and from the backend.
  void _removeItem(GroceryItem item) async { ... }

  @override
  Widget build(BuildContext context) { ... }
}
```

---

### `lib/widgets/new_item.dart`

A form for adding a new grocery item.
- Validates user input for name, quantity, and category.
- Sends a POST request to Firebase.
- Returns the new item to the previous screen.

```dart
class NewItem extends StatefulWidget { ... }

class _NewItemState extends State<NewItem> {
  // Form key, input variables, and loading state.
  // ...
  void _saveItem() async { ... }
  @override
  Widget build(BuildContext context) { ... }
}
```

---

## Getting Started

1. **Clone the repository**
   ```sh
   git clone https://github.com/SolomonB127/Shopping_List.git
   cd shopping_list_flutter
   ```

2. **Install dependencies**
   ```sh
   flutter pub get
   ```

3. **Run the app**
   ```sh
   flutter run
   ```

4. **(Optional) Configure your own Firebase Realtime Database**
   - Update the database URL in the code if needed.

---

## Customization

- **Add or edit categories** in `lib/data/categories.dart`.
- **Change Firebase endpoint** in `grocery_list.dart` and `new_item.dart`.
- **Style the UI** using Flutter's theming and widget customization.

---

## License

MIT License

---

## Credits

- Built with [Flutter](https://flutter.dev/)
- Uses [Firebase Realtime Database](https://firebase.google.com/products/realtime-database)

---

> _For questions or feedback, open an issue or contact the author._
