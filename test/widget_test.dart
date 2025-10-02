// This is a basic Flutter widget test for the Teacher App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:teacher_mobile/main.dart';

void main() {
  testWidgets('Teacher App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TeacherApp());

    // Verify that the login screen is displayed
    expect(find.text('Teacher Portal'), findsOneWidget);
    
    // Verify that login elements are present
    expect(find.text('Login'), findsWidgets);
    
    // Verify that text fields are present (email and password)
    expect(find.byType(TextFormField), findsWidgets);
  });
}
