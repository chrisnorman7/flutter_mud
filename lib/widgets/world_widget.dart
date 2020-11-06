/// Provides the [WorldWidget] class.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../json/world.dart';

enum ConnectionStates {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error
}

class WorldWidget extends StatefulWidget {
  const WorldWidget(this.world) : super();

  final World world;

  @override
  WorldWidgetState createState() => WorldWidgetState();
}

class WorldWidgetState extends State<WorldWidget> {
  Socket _socket;
  ConnectionStates _state = ConnectionStates.disconnected;
  List<String> _messages;
  String _error;
  StreamSubscription<Uint8List> _socketSubscription;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = <String>[];
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_state == ConnectionStates.disconnected) {
      if (_messages.isEmpty) {
        child = const Text('Not connected.');
      } else {
        final List<String> messages = _messages.reversed.toList();
        child = ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            final String s = messages[index];
            return ListTile(title: Text(s));
          },
        );
        WidgetsBinding.instance.addPostFrameCallback(
            (Duration d) => _scrollController.jumpTo(0.0));
      }
    } else if (_state == ConnectionStates.connecting) {
      child = Text(
          'Connecting to ${widget.world.hostname}:${widget.world.port}...');
    } else if (_state == ConnectionStates.disconnecting) {
      child = const Text('Disconnecting...');
    } else if (_error != null) {
      child = Text(_error);
    } else {
      final List<String> messages = _messages.reversed.toList();
      child = ListView.builder(
        controller: _scrollController,
        reverse: true,
        shrinkWrap: true,
        itemCount: _messages.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            final TextField input = TextField(
              controller: _inputController,
              decoration: const InputDecoration(labelText: 'Input'),
              onSubmitted: (String value) {
                _socket.writeln(value);
                _messages.add('> $value');
                _inputController.clear();
              },
            );
            return input;
          }
          final String message = messages[index - 1];
          return Semantics(
              child: ListTile(title: Text(message)), liveRegion: index == 1);
        },
      );
    }
    String connectTitle;
    void Function() connectFunc;
    if (_state == ConnectionStates.connecting ||
        _state == ConnectionStates.disconnecting) {
      connectFunc = null;
      if (_state == ConnectionStates.connecting) {
        connectTitle = 'Connecting...';
      } else {
        connectTitle = 'Disconnecting...';
      }
    } else if (_state == ConnectionStates.connected) {
      connectFunc = disconnect;
      connectTitle = 'Disconnect';
    } else {
      connectFunc = connect;
      connectTitle = 'Connect';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.world.name),
        actions: <Widget>[
          ElevatedButton(child: Text(connectTitle), onPressed: connectFunc)
        ],
      ),
      body: child,
    );
  }

  Future<void> connect() async {
    setState(() => _state = ConnectionStates.connecting);
    try {
      _socket = await Socket.connect(widget.world.hostname, widget.world.port);
      if (widget.world.connectCommands != null) {
        widget.world.connectCommands.split('\n').forEach(_socket.writeln);
      }
      _socketSubscription =
          _socket.listen(onData, onDone: onDone, onError: onError);
      setState(() {
        _state = ConnectionStates.connected;
        _messages
            .add('Connected to ${widget.world.hostname}:${widget.world.port}');
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _state = ConnectionStates.error;
      });
    }
  }

  Future<void> disconnect() async {
    setState(() => _state = ConnectionStates.disconnecting);
    // No need to do anything except close the socket, since [onDone] will handle the rest.
    await _socket.close();
  }

  void onData(Uint8List data) {
    final List<String> strings = String.fromCharCodes(data).split('\n');
    setState(() {
      for (final String s in strings) {
        if (s.trim().isNotEmpty) {
          _messages.add(s);
        }
      }
      _scrollController.jumpTo(0.0);
    });
  }

  void onError(dynamic e, StackTrace t) {
    _messages.add(e.toString());
    if (t != null) {
      _messages.add(t.toString());
    }
  }

  void onDone() {
    _socket = null;
    _socketSubscription.cancel();
    setState(() => _state = ConnectionStates.disconnected);
  }

  @override
  void dispose() {
    super.dispose();
    if (_socketSubscription != null) {
      _socketSubscription.cancel();
    }
    if (_socket != null) {
      _socket.close();
    }
    if (_inputController != null) {
      _inputController.dispose();
    }
  }
}
