import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xabarlar'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            title: Text('Xabar ${index + 1}'),
            subtitle: const Text('Oxirgi xabar matni...'),
            trailing: const Text('12:30'),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.message),
      ),
    );
  }
}