import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parent_provider.dart';
import '../../models/child.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({Key? key}) : super(key: key);

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentProvider>().fetchChildren();
    });
  }

  Future<void> _refreshChildren() async {
    await context.read<ParentProvider>().fetchChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çocuklarım'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Çocuk ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Children grid
          Expanded(
            child: Consumer<ParentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.children.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.children.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Veriler yüklenemedi',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error ?? 'Bilinmeyen hata',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshChildren,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredChildren = provider.children
                    .where((child) =>
                        child.fullName.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredChildren.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Henüz çocuk kaydı yok'
                              : 'Eşleşen çocuk bulunamadı',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshChildren,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredChildren.length,
                    itemBuilder: (context, index) {
                      return _buildChildCard(filteredChildren[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddChildDialog,
        icon: const Icon(Icons.add),
        label: const Text('Çocuk Ekle'),
      ),
    );
  }

  Widget _buildChildCard(Child child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/parent/child-detail',
            arguments: child.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'child-avatar-${child.id}',
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: child.profilePicUrl != null
                      ? NetworkImage(child.profilePicUrl!)
                      : null,
                  backgroundColor: child.gender == 1
                      ? Colors.blue[100]
                      : Colors.pink[100],
                  child: child.profilePicUrl == null
                      ? Text(
                          child.initials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: child.gender == 1
                                ? Colors.blue[700]
                                : Colors.pink[700],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                child.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (child.age != null)
                Text(
                  '${child.age} yaş',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              if (child.school != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    child.school!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.assignment, size: 16, color: Colors.grey[600]),
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çocuk Ekle'),
        content: const Text(
          'Yeni çocuk eklemek için lütfen yönetici ile iletişime geçin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }
}
