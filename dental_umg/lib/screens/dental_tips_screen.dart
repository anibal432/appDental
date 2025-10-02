//dental_tips_screen.dart
import 'package:flutter/material.dart';
import '../models/dental_tip.dart';
import '../services/dental_tips_service.dart';
import 'tip_detail_screen.dart';

class DentalTipsScreen extends StatefulWidget {
  const DentalTipsScreen({super.key});

  @override
  State<DentalTipsScreen> createState() => _DentalTipsScreenState();
}

class _DentalTipsScreenState extends State<DentalTipsScreen> {
  final DentalTipsService _service = DentalTipsService();
  String? _selectedCategory;
  List<String> _categories = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<String> categories = await _service.getCategories();
    setState(() {
      _categories = ['Todos', ...categories];
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'niños':
        return Colors.blue;
      case 'adultos':
        return Colors.green;
      case 'higiene':
        return Colors.purple;
      case 'prevención':
        return Colors.orange;
      case 'emergencias':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'niños':
        return Icons.child_care;
      case 'adultos':
        return Icons.person;
      case 'higiene':
        return Icons.cleaning_services;
      case 'prevención':
        return Icons.health_and_safety;
      case 'emergencias':
        return Icons.medical_services;
      default:
        return Icons.tips_and_updates;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Consejos Dentales'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String category = _categories[index];
                bool isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'Todos');

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory =
                            category == 'Todos' ? null : category;
                      });
                    },
                    selectedColor: Colors.teal.withAlpha(76),
                    checkmarkColor: Colors.teal,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DentalTip>>(
              stream: _selectedCategory == null
                  ? _service.getAllTips()
                  : _service.getTipsByCategory(_selectedCategory!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar consejos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                List<DentalTip> tips = snapshot.data ?? [];

                if (tips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay consejos disponibles',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    DentalTip tip = tips[index];
                    Color categoryColor = _getCategoryColor(tip.category);
                    IconData categoryIcon = _getCategoryIcon(tip.category);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TipDetailScreen(tip: tip),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      categoryIcon,
                                      color: categoryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tip.category,
                                          style: TextStyle(
                                            color: categoryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tip.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tip.description,
                                style: TextStyle(
                                    color: Colors.grey[700], height: 1.4),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
