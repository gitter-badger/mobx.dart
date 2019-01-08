import 'package:mobx/mobx.dart';
import 'package:mobx/src/api/observable_list.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableList', () {
    test('basics work', () {
      final list = ObservableList<int>();
      var count = -1;

      final d = autorun((_) {
        count = list.length;
      });

      expect(count, equals(0));

      list.add(Observable(20));
      expect(count, equals(1));
      d();
    });

    group('fires reportObserved() for read-methods', () {
      <String, void Function(ObservableList<int>)>{
        'map': (_) => _.map((x) => x),
        'isEmpty': (_) => _.isEmpty,
        'isNotEmpty': (_) => _.isNotEmpty,
        'iterator': (_) => _.iterator,
        'reversed': (_) => _.reversed,
        'single': (_) => _ignoreException(() => _.single),
        'first': (_) => _ignoreException(() => _.first),
        'last': (_) => _ignoreException(() => _.last),
        'toSet': (_) => _.toSet(),
        'toList': (_) => _.toList(),
        'cast': (_) => _.cast(),
        'join': (_) => _.join(),
        'asMap': (_) => _.asMap(),
        'fold': (_) => _.fold(0, (sum, item) => sum),
        'take': (_) => _.take(1),
        'sublist': (_) => _.sublist(0),
        'elementAt': (_) => _ignoreException(() => _.elementAt(0)),
        'reduce': (_) =>
            _ignoreException(() => _.reduce((_, _a) => Observable(0))),
        'followedBy': (_) => _.followedBy([Observable(10)]),
        'skip': (_) => _.skip(1),
        'whereType': (_) => _.whereType<num>(),
        'singleWhere': (_) => _ignoreException(() =>
            _.singleWhere((_) => _.value == 20, orElse: () => Observable(0))),
        'lastIndexOf': (_) => _.lastIndexOf(Observable(20)),
        'indexOf': (_) => _.indexOf(Observable(20)),
        'getRange': (_) => _.getRange(0, 0),
        'forEach': (_) => _.forEach((_a) {}),
        'contains': (_) => _.contains(null),
        'where': (_) => _.where((_) => true),
        'takeWhile': (_) => _.takeWhile((_) => true),
        'skipWhile': (_) => _.skipWhile((_) => true),
        'indexWhere': (_) => _.indexWhere((_) => true),
        'lastWhere': (_) =>
            _.lastWhere((_) => true, orElse: () => Observable(0)),
        'lastIndexWhere': (_) => _.lastIndexWhere((_) => true),
        'firstWhere': (_) =>
            _.firstWhere((_) => true, orElse: () => Observable(0)),
        'every': (_) => _.every((_) => true),
        'any': (_) => _.any((_) => true),
        'expand': (_) => _.expand((_) => [Observable(100)]),
        '[]': (_) => _[0],
        '+': (_) => _ + [Observable(100)],
      }.forEach(_templateReadTest);
    });
  });

  group('fires reportChanged() for write-methods', () {
    <String, void Function(ObservableList<int>)>{
      'length=': (_) => _.length = 0,
      'last=': (_) => _.last = Observable(100),
      'first=': (_) => _.first = Observable(100),
      'insertAll': (_) => _.insertAll(0, [Observable(100)]),
      'insert': (_) => _.insert(0, Observable(100)),
      'sort': (_) => _.sort(),
      'setRange': (_) => _.setRange(0, 0, [Observable(100)]),
      'fillRange': (_) => _.fillRange(0, 0, Observable(100)),
      'replaceRange': (_) => _.replaceRange(0, 0, [Observable(100)]),
      'setAll': (_) => _.setAll(0, [Observable(100)]),
      '[]=': (_) => _[0] = Observable(100),
      'add': (_) => _.add(Observable(100)),
      'addAll': (_) => _.addAll([Observable(100)]),
      'clear': (_) => _.clear(),
      'removeLast': (_) => _.removeLast(),
      'remove': (_) => _.remove(null),
      'removeRange': (_) => _.removeRange(0, 0),
      'removeAt': (_) => _.removeAt(0),
      'removeWhere': (_) => _.removeWhere((_) => true),
      'shuffle': (_) => _.shuffle(),
      'retainWhere': (_) => _.retainWhere((_) => true),
    }.forEach(_templateWriteTest);
  });
}

dynamic _ignoreException(Function fn) {
  try {
    return fn();
  } on Object catch (_) {
    // Catching on Object since it takes care of both Error and Exception
    // Ignore
  }
}

void _templateReadTest(
    String description, void Function(ObservableList<int>) fn) {
  test(description, () {
    final list = ObservableList<int>();
    list.add(Observable(20));

    var count = -1;

    final d = autorun((_) {
      fn(list); // fire the read-method, causing reportObserved() to be invoked
      count++;
    });

    list.add(Observable(20));
    expect(count, equals(1));
    d();
  });
}

void _templateWriteTest(
    String description, void Function(ObservableList<int>) fn) {
  test(description, () {
    final list = ObservableList<int>();
    list.add(Observable(20));

    var count = -1;

    final d = autorun((_) {
      list.length;
      count++;
    });

    // fire the write method, causing reportChanged() to be invoked.
    // This should be picked up in the autorun()
    fn(list);

    expect(count, equals(1));
    d();
  });
}
