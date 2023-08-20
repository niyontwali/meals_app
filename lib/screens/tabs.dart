import 'package:flutter/material.dart';
import 'package:meals_app/data/dummy_data.dart';
import 'package:meals_app/data/meals.dart';
import 'package:meals_app/screens/categories.dart';
import 'package:meals_app/screens/filter.dart';
import 'package:meals_app/screens/meals.dart';
import 'package:meals_app/widgets/main_drawer.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedTabIndex = 0;
  final List<Meal> _favouriteMeal = [];
  Map<Filter, bool> _selectedFilters = kInitialFilters;

  void _selectPage(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _toggleMealFavouriteStatus(Meal meal) {
    var isExisting = _favouriteMeal.contains(meal);
    if (isExisting) {
      setState(() {
        _favouriteMeal.remove(meal);
      });
      _showInfoMessage('Meal removed from favourite');
    } else {
      setState(() {
        _favouriteMeal.add(meal);
      });
      _showInfoMessage('Meal added to favourite');
    }
  }

  void _selectScreen(String indentifier) async {
    if (indentifier == 'filters') {
      Navigator.pop(context);
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => FilterScreen(
            currentFilter: _selectedFilters,
          ),
        ),
      );
      setState(() {
        _selectedFilters = result ?? kInitialFilters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = dummyMeals.where((meal) {
      if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();

    Widget activeScreen = CategoriesScreen(
      availableMeals: availableMeals,
      onToggleMealFavourite: _toggleMealFavouriteStatus,
    );
    var activeScreenTitle = "Categories";
    if (_selectedTabIndex == 1) {
      activeScreen = MealsScreen(
        meals: _favouriteMeal,
        onToggleMealFavourite: _toggleMealFavouriteStatus,
      );
      activeScreenTitle = "Your Favorites";
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(activeScreenTitle),
      ),
      drawer: MainDrawer(onSelectScreen: _selectScreen),
      body: activeScreen,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedTabIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
