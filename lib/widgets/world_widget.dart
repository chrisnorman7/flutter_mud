/// Provides the [WorldWidget] class.
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../json/trigger.dart';
import '../json/world.dart';
import '../message.dart';

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
  List<Message> _messages;
  int _highestIndex = -1;
  String _error;
  StreamSubscription<Uint8List> _socketSubscription;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = <Message>[];
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_state == ConnectionStates.disconnected) {
      if (_messages.isEmpty) {
        child = const Text('Not connected.');
      } else {
        child = ListView.builder(
          controller: _scrollController,
          itemCount: _messages.length,
          itemBuilder: (BuildContext context, int index) =>
              Text(_messages[index].string),
        );
        WidgetsBinding.instance.addPostFrameCallback((Duration d) =>
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent));
      }
    } else if (_state == ConnectionStates.connecting) {
      child = Text(
          'Connecting to ${widget.world.hostname}:${widget.world.port}...');
    } else if (_state == ConnectionStates.disconnecting) {
      child = const Text('Disconnecting...');
    } else if (_error != null) {
      child = Text(_error);
    } else {
      final TextField input = TextField(
        controller: _inputController,
        decoration: const InputDecoration(labelText: 'Input'),
        onSubmitted: (String value) {
          for (final Trigger alias in widget.world.aliases) {
            if (alias.active && alias.matches(value)) {
              value = alias.transformInput(value);
            }
          }
          _socket.writeln(value);
          addOutgoingMessage('> $value');
          _inputController.clear();
        },
      );
      child = ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == _messages.length) {
            return input;
          }
          final Message message = _messages[index];
          final Semantics s = Semantics(
            child: Text(message.string),
            liveRegion: index > _highestIndex &&
                message.direction == MessageDirections.incoming,
          );
          _highestIndex = max(_highestIndex, index);
          return s;
        },
      );
      WidgetsBinding.instance.addPostFrameCallback((Duration d) =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
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
        addIncomingMessage(
            'Connected to ${widget.world.hostname}:${widget.world.port}');
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
          addIncomingMessage(s);
        }
      }
    });
  }

  void onError(dynamic e, StackTrace t) {
    addIncomingMessage(e.toString());
    if (t != null) {
      addIncomingMessage(t.toString());
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

  void addIncomingMessage(String text) {
    for (final Trigger trigger in widget.world.triggers) {
      if (trigger.active && trigger.matches(text)) {
        text = trigger.transformInput(text);
      }
    }
    addMessage(text, MessageDirections.incoming);
  }

  void addOutgoingMessage(String text) {
    addMessage(text, MessageDirections.outgoing);
  }

  void addMessage(String text, MessageDirections direction) {
    _messages.add(Message(text, direction));
  }
}
