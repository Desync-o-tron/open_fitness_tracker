import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_fitness_tracker/main.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final firestore = FakeFirebaseFirestore();
  final firebaseAuth = MockFirebaseAuth();
  late Storage storage;

  setUpAll(() async {
    setFirebaseUiIsTestMode(true);

    // Mock the HydratedBloc storage
    storage = MockStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});

    // Set the mocked storage for HydratedBloc
    HydratedBloc.storage = storage;
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build your app and trigger a frame.
    Key testKey = const Key("testKey");
    await tester.pumpWidget(MyApp(
      key: testKey,
      fakeFirestore: firestore,
      fakeFirebaseAuth: firebaseAuth,
    ));

    // expect(find.text('Register'), findsOneWidget);
    // expect(find.byType(SignInScreenWrapper), findsOneWidget);
    // expect(find.byType(Scaffold), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(testKey), findsAny);
    expect(find.text('1'), findsNothing);
    await tester.pumpAndSettle();
  });
}
