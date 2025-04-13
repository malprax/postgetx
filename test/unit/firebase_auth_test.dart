import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'firebase_auth_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
  });

  test('Sign in with valid credentials should succeed', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: "test@example.com",
      password: "password123",
    )).thenAnswer((_) async => mockUserCredential);

    final result = await mockAuth.signInWithEmailAndPassword(
      email: "test@example.com",
      password: "password123",
    );

    expect(result, isA<UserCredential>());
  });

  test('Sign in with invalid credentials should fail', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: "wrong@example.com",
      password: "wrongpassword",
    )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

    expect(
      () async => await mockAuth.signInWithEmailAndPassword(
        email: "wrong@example.com",
        password: "wrongpassword",
      ),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}
