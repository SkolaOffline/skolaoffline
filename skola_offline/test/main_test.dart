import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skola_offline/main.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.text('Škola Offline'), findsOneWidget);
    });

    testWidgets('navigates to timetable screen', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();
      expect(find.text('Timetable'), findsOneWidget);
    });

    testWidgets('navigates to marks screen', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byIcon(Icons.format_list_numbered));
      await tester.pumpAndSettle();
      expect(find.text('Marks'), findsOneWidget);
    });

    //TODO: Add more tests for other screens and features
  });
}
