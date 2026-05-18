import 'package:flutter/material.dart';


Future<void> showFeedbackDialog(
  BuildContext context,
  Function(double rating, String comment) onSubmit,
) async {
  final commentController = TextEditingController();
  double selectedRating = 5.0;

  await showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            title: const Text("Job Completed!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("How was the service?", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setState(() => selectedRating = index + 1.0),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Leave a comment (e.g. He broke my AC wire!)",
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSubmit(selectedRating, commentController.text);
                },
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                child: const Text("Submit Review", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}
