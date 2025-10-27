import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7 дней';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();
    
    if (authProvider.user != null) {
      await petProvider.loadUserPets(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final userPets = petProvider.userPets;

    // Статистика
    final totalPets = userPets.length;
    final lostPets = userPets.where((p) => p.status == PetStatus.lost).length;
    final foundPets = userPets.where((p) => p.status == PetStatus.found).length;
    final activePets = userPets.where((p) => p.isActive).length;
    
    // Статистика по типам
    final dogCount = userPets.where((p) => p.type == PetType.dog).length;
    final catCount = userPets.where((p) => p.type == PetType.cat).length;
    final birdCount = userPets.where((p) => p.type == PetType.bird).length;
    final otherCount = userPets.where((p) => p.type == PetType.other).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Аналитика',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFEE8A9A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Общая статистика
              _buildStatsGrid(
                totalPets: totalPets,
                lostPets: lostPets,
                foundPets: foundPets,
                activePets: activePets,
              ),

              const SizedBox(height: 24),

              // Заголовок графика
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Активность объявлений',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildPeriodSelector(),
                ],
              ),

              const SizedBox(height: 16),

              // График активности
              _buildActivityChart(userPets),

              const SizedBox(height: 24),

              // Последние объявления
              const Text(
                'Последние объявления',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _buildRecentPets(userPets),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid({
    required int totalPets,
    required int lostPets,
    required int foundPets,
    required int activePets,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Всего объявлений',
          totalPets.toString(),
          Icons.pets,
          const Color(0xFFEE8A9A),
        ),
        _buildStatCard(
          'Пропали',
          lostPets.toString(),
          Icons.search,
          Colors.orange,
        ),
        _buildStatCard(
          'Найдены',
          foundPets.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Активные',
          activePets.toString(),
          Icons.visibility,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        underline: const SizedBox(),
        items: ['7 дней', '30 дней', 'Всё время']
            .map((period) => DropdownMenuItem(
                  value: period,
                  child: Text(period, style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPeriod = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildActivityChart(List<PetModel> pets) {
    // Группируем объявления по дням
    final now = DateTime.now();
    final days = _selectedPeriod == '7 дней' ? 7 : _selectedPeriod == '30 дней' ? 30 : 90;
    
    Map<int, int> dailyCount = {};
    for (int i = 0; i < days; i++) {
      dailyCount[i] = 0;
    }

    for (var pet in pets) {
      final diff = now.difference(pet.createdAt).inDays;
      if (diff < days) {
        dailyCount[diff] = (dailyCount[diff] ?? 0) + 1;
      }
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailyCount.values.isEmpty ? 0 : dailyCount.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % (days ~/ 7) == 0) {
                    return Text(
                      '${days - value.toInt()}д',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: dailyCount.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: const Color(0xFFEE8A9A),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPetTypesChart({
    required int dogCount,
    required int catCount,
    required int birdCount,
    required int otherCount,
  }) {
    final total = dogCount + catCount + birdCount + otherCount;
    
    if (total == 0) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Нет данных',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTypeItem('🐕 Собаки', dogCount, const Color(0xFFEE8A9A)),
                const SizedBox(height: 12),
                _buildTypeItem('🐱 Кошки', catCount, const Color(0xFFD6C9FF)),
                const SizedBox(height: 12),
                _buildTypeItem('🦜 Птицы', birdCount, Colors.blue.shade200),
                const SizedBox(height: 12),
                _buildTypeItem('🐾 Другие', otherCount, Colors.green.shade200),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  if (dogCount > 0)
                    PieChartSectionData(
                      value: dogCount.toDouble(),
                      color: const Color(0xFFEE8A9A),
                      radius: 40,
                      showTitle: false,
                    ),
                  if (catCount > 0)
                    PieChartSectionData(
                      value: catCount.toDouble(),
                      color: const Color(0xFFD6C9FF),
                      radius: 40,
                      showTitle: false,
                    ),
                  if (birdCount > 0)
                    PieChartSectionData(
                      value: birdCount.toDouble(),
                      color: Colors.blue.shade200,
                      radius: 40,
                      showTitle: false,
                    ),
                  if (otherCount > 0)
                    PieChartSectionData(
                      value: otherCount.toDouble(),
                      color: Colors.green.shade200,
                      radius: 40,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPets(List<PetModel> pets) {
    final recentPets = pets.take(3).toList();

    if (recentPets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Нет объявлений',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: recentPets.map((pet) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: pet.status == PetStatus.lost
                      ? const Color(0xFFEE8A9A)
                      : const Color(0xFFD6C9FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    pet.type == PetType.dog ? '🐕' : 
                    pet.type == PetType.cat ? '🐱' : 
                    pet.type == PetType.bird ? '🦜' : '🐾',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.petName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.status == PetStatus.lost ? 'Пропал' : 'Найден',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: pet.isActive
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pet.isActive ? 'Активно' : 'Неактивно',
                      style: TextStyle(
                        fontSize: 10,
                        color: pet.isActive
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(pet.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Сегодня';
    } else if (diff.inDays == 1) {
      return 'Вчера';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}