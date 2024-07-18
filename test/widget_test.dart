import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/auth_screens/login_screen.dart';
import '../lib/screens/auth_screens/registration_screen.dart';


void main() {
  testWidgets('Login Screen Widget Testing', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Test the visibility of UI elements
    expect(find.text('WELCOME'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Test entering text in email and password fields
    final Finder emailTextFieldFinder = find.widgetWithText(TextField, 'E-mail');
    await tester.enterText(emailTextFieldFinder, 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);

    final Finder passwordTextFieldFinder = find.widgetWithText(TextField, 'Password');
    await tester.enterText(passwordTextFieldFinder, 'password123');
    expect(find.text('password123'), findsOneWidget);

    // Test tapping the login button
    final Finder loginButtonFinder = find.byType(ElevatedButton);
    await tester.tap(loginButtonFinder);
    await tester.pump(); // Rebuild the widget after the button tap

    // You can add more tests based on your specific requirements, such as checking for error messages or navigating to the registration screen.

    // Example: Test if the CircularProgressIndicator is visible when login is in progress
    // expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Example: Test if the error message is displayed for invalid credentials
    // Note: You should modify the loginUser function in your LoginScreen to handle different scenarios and provide appropriate error messages.
    // For this example, let's assume you have an error message widget with the key 'error_message'
    // await tester.pump(); // Rebuild the widget after handling the login error
    // expect(find.byKey(const Key('error_message')), findsOneWidget);

  });
  testWidgets('RegistrationScreen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: RegistrationScreen(),
    ));

    // Ensure that 'CREATE ACCOUNT' text is present
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);

    // Ensure that form fields are present
    expect(find.byKey(const Key('fullNameField')), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('confirmPasswordField')), findsOneWidget);

    // Ensure that the 'Create Account' button is present
    expect(find.text('Create Account'), findsOneWidget);

    // Tap the 'Create Account' button and trigger validation
    await tester.tap(find.text('Create Account'));
    await tester.pump();

    // Ensure that validation errors are shown for empty fields
    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter email.'), findsOneWidget);
    expect(find.text('Enter password.'), findsOneWidget);
    expect(find.text('Enter confirm password.'), findsOneWidget);

    // Enter valid data in form fields
    await tester.enterText(find.byKey(const Key('fullNameField')), 'John Doe');
    await tester.enterText(find.byKey(const Key('emailField')), 'john.doe@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
    await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'password123');

    // Tap the 'Create Account' button again
    await tester.tap(find.text('Create Account'));
    await tester.pump();

    // Ensure that validation errors are not shown
    expect(find.text('Enter your full name.'), findsNothing);
    expect(find.text('Enter email.'), findsNothing);
    expect(find.text('Enter password.'), findsNothing);
    expect(find.text('Enter confirm password.'), findsNothing);

  });
}
