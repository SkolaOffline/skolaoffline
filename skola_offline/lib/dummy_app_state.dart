class DummyAppState {
  static final DummyAppState _instance = DummyAppState._internal();

  factory DummyAppState() {
    return _instance;
  }

  DummyAppState._internal();

  bool useDummyData = false;
}
