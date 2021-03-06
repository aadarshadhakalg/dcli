import 'dart:collection';

///
/// A classic Stack of items with a push and pop method.
///
class StackList<T> {
  final _stack = Queue<T>();

  ///
  StackList();

  ///
  /// Creates a stack from [initialStack]
  /// by pushing each element of the list
  /// onto the stack from first to last.
  StackList.fromList(List<T> initialStack) {
    for (final item in initialStack) {
      push(item);
    }
  }

  ///
  bool get isEmpty => _stack.isEmpty;

  /// push an [item] onto th stack.
  void push(T item) {
    _stack.addFirst(item);
  }

  /// return and remove an item from the stack.
  T pop() {
    return _stack.removeFirst();
  }

  /// returns the item onf the top of the stack
  /// but does not remove the item.
  T peek() {
    return _stack.first;
  }
}
