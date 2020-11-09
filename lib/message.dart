/// Provides the [Message] class.

enum MessageDirections {
  incoming,
  outgoing,
}

class Message {
  Message(this.string, this.direction);

  final String string;
  final MessageDirections direction;
}
