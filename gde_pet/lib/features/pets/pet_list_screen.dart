import 'package:flutter/material.dart';
import 'package:gde_pet/features/home/home_screen.dart'; // For PetCard
import 'package:gde_pet/features/home/pet_detail_screen.dart';
import 'package:gde_pet/features/pets/pet_list_item.dart'; // Импортируем новый виджет
import 'package:gde_pet/models/pet_model.dart';
import 'package:gde_pet/providers/pet_provider.dart';
import 'package:provider/provider.dart';

// Перечисления для управления состоянием UI
enum _ViewMode { grid, list }
enum _SortBy { newest, oldest }

class PetListScreen extends StatefulWidget {
  final PetStatus status;

  const PetListScreen({super.key, required this.status});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  _ViewMode _viewMode = _ViewMode.grid;
  _SortBy _sortBy = _SortBy.newest;
  PetType? _petTypeFilter; // null значит "Все"
  List<PetModel> _allPets = [];
  List<PetModel> _filteredPets = [];

  @override
  void initState() {
    super.initState();
    // Используем addPostFrameCallback для безопасного доступа к provider
    // при первой загрузке
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndFilterPets();
    });
  }

  // Этот метод будет вызываться при изменении зависимостей (например, при обновлении PetProvider)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAndFilterPets();
  }

  // Загружает базовый список из провайдера
  void _loadAndFilterPets() {
    final petProvider = context.read<PetProvider>();
    final newPetList = petProvider.pets
        .where((p) => p.status == widget.status && p.isActive)
        .toList();
    
    // Проверяем, изменился ли список, чтобы избежать лишних перестроений
    if (newPetList.length != _allPets.length || !_listsAreEqual(newPetList, _allPets)) {
      setState(() {
        _allPets = newPetList;
        _applyFiltersAndSort(); // Применяем текущие фильтры
      });
    }
  }
  
  // Хелпер для проверки, изменился ли список
  bool _listsAreEqual(List<PetModel> a, List<PetModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }


  // Применяет фильтры и сортировку к _allPets и сохраняет в _filteredPets
  void _applyFiltersAndSort() {
    List<PetModel> tempPets = List.from(_allPets);

    // 1. Фильтр по типу
    if (_petTypeFilter != null) {
      tempPets = tempPets.where((p) => p.type == _petTypeFilter).toList();
    }

    // 2. Сортировка
    if (_sortBy == _SortBy.newest) {
      tempPets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      tempPets.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    setState(() {
      _filteredPets = tempPets;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.status == PetStatus.lost ? 'Пропали' : 'Найдены';
    final petProvider = context.watch<PetProvider>();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          // Кнопка переключения вида (Сетка/Список)
          IconButton(
            icon: Icon(
              _viewMode == _ViewMode.grid ? Icons.list : Icons.grid_view,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == _ViewMode.grid
                    ? _ViewMode.list
                    : _ViewMode.grid;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Панель фильтров и сортировки
          _buildFilterBar(),
          // Отображение контента
          if (petProvider.isLoading && _filteredPets.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFEE8A9A)),
              ),
            )
          else if (_filteredPets.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'По вашим фильтрам ничего не найдено.\nПопробуйте изменить параметры.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: _viewMode == _ViewMode.grid
                  ? _buildGridView()
                  : _buildListView(),
            ),
        ],
      ),
    );
  }

  // Виджет для панели фильтров
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Сортировка
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Сортировать:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                DropdownButton<_SortBy>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: _SortBy.newest,
                      child: Text('Сначала новые'),
                    ),
                    DropdownMenuItem(
                      value: _SortBy.oldest,
                      child: Text('Сначала старые'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                        _applyFiltersAndSort();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Фильтры по типу (чипы)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(null, 'Все'), // "Все"
                ...PetType.values.map((type) {
                  return _buildFilterChip(type, type.displayName);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для одного чипа фильтра
  Widget _buildFilterChip(PetType? type, String label) {
    final isSelected = _petTypeFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _petTypeFilter = selected ? type : null;
            _applyFiltersAndSort();
          });
        },
        selectedColor: const Color(0xFFEE8A9A),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFFEE8A9A) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  // Виджет для отображения сеткой
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Соотношение сторон из user_pets_screen
      ),
      itemCount: _filteredPets.length,
      itemBuilder: (context, index) {
        final pet = _filteredPets[index];
        return PetCard(
          petModel: pet,
          color: pet.status == PetStatus.lost
              ? const Color(0xFFEE8A9A)
              : const Color(0xFFD6C9FF),
          title: pet.petName,
          location: pet.address ?? 'На карте',
        );
      },
    );
  }

  // Виджет для отображения списком
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredPets.length,
      itemBuilder: (context, index) {
        final pet = _filteredPets[index];
        return PetListItem(pet: pet); // Используем новый виджет
      },
    );
  }
}

