import 'package:flutter/material.dart';
import 'package:frontend/screens/memories/mediascreen.dart';
// import 'package:frontend/themes/theme_controller.dart'; // Removed
import 'package:frontend/apis/api_service.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class Binders extends StatefulWidget {
  const Binders({super.key});

  @override
  State<Binders> createState() => _BindersState();
}

class _BindersState extends State<Binders> {
  List<dynamic> binders = [];
  bool isLoading = true;
  late final TextEditingController _newBinderNameController;

  @override
  void initState() {
    super.initState();
    _newBinderNameController = TextEditingController();
    loadBinders();
  }

  @override
  void dispose() {
    _newBinderNameController.dispose();
    super.dispose();
  }

  // 🔥 UI-level function (calls API)
  Future<void> loadBinders() async {
    try {
      final data = await ApiService.getBinders();

      setState(() {
        binders = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString()); // Refactored
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addBinder() async {
    final newBinderName = _newBinderNameController.text.trim();
    if (newBinderName.isEmpty) {
      // Optionally show a snackbar or alert if the name is empty
      return;
    }

    try {
      debugPrint(newBinderName);
      await ApiService.addBinder(newBinderName);
      // _newBinderNameController.clear();
      Navigator.of(context).pop(); // Close the dialog
      loadBinders(); // Reload the binders list
    } catch (e) {
      // Show error to user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add binder: $e')));
    }
  }

  void _showAddBinderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add New Binder',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: TextField(
            controller: _newBinderNameController,
            decoration: InputDecoration(
              labelText: 'Binder Name',
              hintText: 'Enter new binder name',
              border: const OutlineInputBorder(),
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              filled: true,
            ),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newBinderNameController.clear();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: _addBinder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Add'),
            ),
          ],
          backgroundColor: Theme.of(context).cardColor, // Dialog background
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memories from a long time ago..."),
        centerTitle: true,
        backgroundColor: Theme.of(
          context,
        ).appBarTheme.backgroundColor, // Refactored
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: binders.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final binder = binders[index];
                  final String? thumbnailUrl = binder['thumbnail'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MediaScreen(binderName: binder['name'] , binderPath:binder['path']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // Refactored
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          thumbnailUrl != null && thumbnailUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    thumbnailUrl.startsWith('http')
                                        ? thumbnailUrl
                                        : "${ApiService.baseUrl}$thumbnailUrl",
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.folder,
                                      size: 50,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.folder,
                                  size: 50,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color, // Refactored
                                ),
                          const SizedBox(height: 10),
                          Text(
                            binder['name'] ?? "Folder",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color, // Refactored
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBinderDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
