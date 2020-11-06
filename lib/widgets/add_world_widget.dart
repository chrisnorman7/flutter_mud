/// Provides the [AddWorldWidget] class.
import 'package:flutter/material.dart';

import '../json/settings.dart';
import '../json/world.dart';

class AddWorldWidget extends StatefulWidget {
  const AddWorldWidget(this.settings, this.callback) : super();

  final Settings settings;
  final void Function() callback;

  @override
  AddWorldWidgetState createState() => AddWorldWidgetState();
}

class AddWorldWidgetState extends State<AddWorldWidget> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostnameController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Form form = Form(
      key: _key,
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'World Name'),
            validator: (String value) =>
                value.isEmpty ? 'You must provide a name' : null,
          ),
          TextFormField(
            controller: _hostnameController,
            decoration: const InputDecoration(labelText: 'Hostname'),
            validator: (String value) =>
                value.isEmpty ? 'Hostname cannot be blank' : null,
          ),
          TextFormField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: 'Port',
            ),
            keyboardType: TextInputType.number,
            validator: (String value) {
              final int port = int.tryParse(value);
              if (port == null || port < 20) {
                return 'Invalid port number';
              }
              return null;
            },
          )
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('New World'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_key.currentState.validate()) {
                final World world = World(
                    name: _nameController.text,
                    hostname: _hostnameController.text,
                    port: int.tryParse(_portController.text));
                widget.settings
                  ..worlds.add(world)
                  ..sortWorlds();
                Navigator.of(context).pop();
                widget.settings.save();
                widget.callback();
              }
            },
          )
        ],
      ),
      body: form,
    );
  }
}
