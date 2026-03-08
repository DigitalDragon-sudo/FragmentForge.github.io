import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fragment.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fragment Timeline')),
      body: ValueListenableBuilder<Box<Fragment>>(
        valueListenable: Hive.box<Fragment>('fragments').listenable(),
        builder: (context, box, _) {
          final fragments = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (fragments.isEmpty) {
            return const Center(child: Text('No fragments yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fragments.length,
            itemBuilder: (context, index) {
              final f = fragments[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: Text(
                    f.moodTag.isNotEmpty ? f.moodTag[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(f.moodTag),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.timestamp.toString().substring(0, 16)),
                    if (f.text.isNotEmpty)
                      Text(
                        f.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
