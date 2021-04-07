library md5.list;

/// a always sorted linked list
class MList<E extends MEntry> extends Iterable<E> implements _MListLink {
  int _length = 0;
  _MListLink _next;
  _MListLink _previous;

  MList() {
    _next = _previous = this;
  }

  void add(E entry) {
    if (entry.list == this) {
      return;
    }
    if (entry.sortId == double.infinity || _next == this) {
      _insertAfter(_previous, entry);
      return;
    }
    num sortId = entry.sortId;
    if ((_previous as MEntry).sortId <= sortId) {
      _insertAfter(_previous, entry);
      return;
    }
    MEntry current = _next as MEntry;
    while (!identical(current, this)) {
      if (current.sortId > sortId) {
        _insertAfter(current._previous, entry);
        return;
      }
      current = current._next as MEntry;
    }
    _insertAfter(_previous, entry);
  }

  bool remove(E entry) {
    if (entry._list != this) return false;
    _unlink(entry); // Unlink will decrement length.
    return true;
  }

  Iterator<E> get iterator => new _MListIterator<E>(this);

  int get length => _length;

  void clear() {
    _MListLink next = _next;
    while (!identical(next, this)) {
      E entry = next as E;
      next = entry._next;
      entry._next = entry._previous = entry._list = null;
    }
    _next = _previous = this;
    _length = 0;
  }

  E get first {
    if (identical(_next, this)) {
      throw new StateError('No such element');
    }
    return _next as E;
  }

  E get last {
    if (identical(_previous, this)) {
      throw new StateError('No such element');
    }
    return _previous as E;
  }

  E get single {
    if (identical(_previous, this)) {
      throw new StateError('No such element');
    }
    if (!identical(_previous, _next)) {
      throw new StateError('Too many elements');
    }
    return _next as E;
  }

  void forEach(void action(E entry)) {
    _MListLink current = _next;
    while (!identical(current, this)) {
      action(current as E);
      current = current._next;
    }
  }

  bool get isEmpty => _length == 0;

  void _insertAfter(_MListLink entry, E newEntry) {
    if (newEntry.list != null) {
      throw new StateError('MEntry is already in a MList');
    }
    newEntry._list = this;
    var predecessor = entry;
    var successor = entry._next;
    successor._previous = newEntry;
    newEntry._previous = predecessor;
    newEntry._next = successor;
    predecessor._next = newEntry;
    _length++;
  }

  void _unlink(E entry) {
    entry._next._previous = entry._previous;
    entry._previous._next = entry._next;
    _length--;
    entry._list = null; // entry._next = entry._previous = null;
  }
}

class _MListIterator<E extends MEntry> implements Iterator<E> {
  final MList<E> _list;
  E _current;
  _MListLink _next;

  _MListIterator(MList<E> list)
      : _list = list,
        _next = list._next;

  E get current => _current;

  bool moveNext() {
    if (identical(_next, _list)) {
      _current = null;
      return false;
    }
    _current = _next as E;
    _next = _next._next;
    if (_current._list == null) {
      // already removed
      return moveNext();
    }
    return true;
  }
}

class _MListLink {
  _MListLink _next;
  _MListLink _previous;
}

abstract class MEntry<E> implements _MListLink {
  double get sortId => 10000.0;

  MList<MEntry> _list;
  _MListLink _next;
  _MListLink _previous;

  MList<MEntry> get list => _list;

  void unlink() {
    if (_list != null) {
      _list._unlink(this);
    }
  }

  MEntry<E> get next {
    if (identical(_next, _list)) return null;
    MEntry<E> result = _next as MEntry<E>;
    return result;
  }

  MEntry<E> get previous {
    if (identical(_previous, _list)) return null;
    return _previous as MEntry<E>;
  }

  void insertAfter(MEntry entry) {
    _list._insertAfter(this, entry);
  }

  void insertBefore(MEntry entry) {
    _list._insertAfter(_previous, entry);
  }
}
