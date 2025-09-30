// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daftar_g_app/main.dart';

void main() {
  testWidgets('App starts with home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DaftarGApp());

    // Verify that the app title is displayed.
    expect(find.text('دفترچي'), findsOneWidget);

    // Verify that the empty state message is displayed when no customers exist.
    expect(find.text('لا يوجد زبائن حتى الآن'), findsOneWidget);
  });
}
