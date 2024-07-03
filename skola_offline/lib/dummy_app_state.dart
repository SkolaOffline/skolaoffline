class DummyAppState {
  static final DummyAppState _instance = DummyAppState._internal();

  factory DummyAppState() {
    return _instance;
  }

  DummyAppState._internal();

  bool _useDummyData = false;

  bool get useDummyData => _useDummyData;

  set useDummyData(bool value) {
    _useDummyData = value;
  }
}
