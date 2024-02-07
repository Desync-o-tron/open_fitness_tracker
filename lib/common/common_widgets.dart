import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white, // Adjust the background color as needed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        side: const BorderSide(color: Colors.grey, width: 1), // Border color and width
        padding: const EdgeInsets.symmetric(vertical: 14.0), // Adjust padding as needed
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black, // Adjust the text color as needed
        ),
      ),
    );
  }
}

class MultiSelectModal extends StatelessWidget {
  const MultiSelectModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<List<String>> showMultiSelectModal(
    BuildContext context, List<String> allItems, List<String> selectedItems) async {
  final List<String> tempSelectedItems = List<String>.from(selectedItems);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Items'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = allItems[index];
              return CheckboxListTile(
                value: tempSelectedItems.contains(item),
                title: Text(item),
                onChanged: (bool? value) {
                  // setState(() {
                  if (value == true) {
                    tempSelectedItems.add(item);
                  } else {
                    tempSelectedItems.remove(item);
                  }
                  // });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              selectedItems.clear();
              selectedItems.addAll(tempSelectedItems);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
  return selectedItems;
}
