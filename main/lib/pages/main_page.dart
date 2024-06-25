import 'package:flutter/material.dart';
import 'package:main/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:main/database/database_service.dart';
import 'package:main/theme/theme_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Map<String, dynamic>>> _concentrationsFuture;
  TextEditingController _searchController = TextEditingController();
  SearchCriteria _selectedCriteria = SearchCriteria.substanceName;
  SortType _selectedSortType = SortType.substanceNameAscending;

  @override
  void initState() {
    super.initState();
    _updateConcentrations('');
  }

  Future<void> _updateConcentrations(String query) async {
    setState(() {
      _concentrationsFuture = DatabaseService().searchAndSortConcentrations(query, _selectedCriteria, _selectedSortType);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedCriteria = SearchCriteria.substanceName;
      _updateConcentrations('');
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('ГДК Довідник'),
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Відкрити бокове меню',
            );
          },
        ),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          backgroundColor: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              Theme(data: Theme.of(context).copyWith(
                dividerTheme: const DividerThemeData(color: Colors.transparent),
              ),
              child: Container( 
                height: 140,
                child: DrawerHeader(
                child: Text(
                  'Налаштування фільтрації та сортування',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                  ),
                ),
              ),
              ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    //Випадаючий список для вибору критерія пошуку
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<SearchCriteria>(
                        value: _selectedCriteria,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCriteria = newValue!;
                            _updateConcentrations(_searchController.text);
                          });
                        },
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          labelText: 'Критерії пошуку',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        items: SearchCriteria.values.map((criteria) {
                          return DropdownMenuItem<SearchCriteria>(
                            value: criteria,
                            child: Text(
                              _getDisplayText(criteria),
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    //Випадаючий список для вибору критерія сортування
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<SortType>(
                        value: _selectedSortType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSortType = newValue!;
                            _updateConcentrations(_searchController.text);
                          });
                        },
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          labelText: 'Тип сортування',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        items: SortType.values.map((sortType) {
                          return DropdownMenuItem<SortType>(
                            value: sortType,
                            child: Text(
                              _getDisplayTextForSortType(sortType),
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              //Кнопка для зміни колірного режиму додатку
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                    icon: Icon(themeProvider.themeData == darkMode ? Icons.wb_sunny : Icons.nightlight_round),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                    tooltip: 'Змінити тему',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                //Поле пошуку
                Container(
                  width: MediaQuery.of(context).size.width - 30.0,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      labelText: 'Пошук за критерієм',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    onChanged: (value) {
                      _updateConcentrations(value);
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
                ),
              ],
            ),
          ),
          //Вивід списку ГДК
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _concentrationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<Map<String, dynamic>> concentrations = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: concentrations.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> concentration = concentrations[index];
                      return ListTile(
                        title: Text(concentration['substance_name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CAS N: ${concentration['cas_number'] ?? ''}'),
                            Text('Макс. разова доза: ${concentration['max_single_dose_limit'] ?? ''}'),
                            Text('Середня добова доза: ${concentration['avg_daily_limit'] ?? ''}'),
                          ],
                        ),
                        trailing: Text('Клас небезпеки: ${concentration['hazard_class'] ?? ''}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.substanceName:
        return 'Назва речовини';
      case SearchCriteria.maxSingleDose:
        return 'Макс. разова доза';
      case SearchCriteria.avgDailyDose:
        return 'Середня добова доза';
      case SearchCriteria.casNumber:
        return 'CAS номер';
      case SearchCriteria.hazardClass:
        return 'Клас небезпеки';
      default:
        return '';
    }
  }

  String _getDisplayTextForSortType(SortType sortType) {
    switch (sortType) {
      case SortType.substanceNameAscending:
        return 'Назва речовини (за зростанням)';
      case SortType.substanceNameDescending:
        return 'Назва речовини (за спаданням)';
      case SortType.hazardClassAscending:
        return 'Клас небезпеки (за зростанням)';
      case SortType.hazardClassDescending:
        return 'Клас небезпеки (за спаданням)';
      default:
        return '';
    }
  }
}
