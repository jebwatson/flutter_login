import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import '../lib/authentication_repository.dart';

void main() {
  MockFirebaseAuth mockFirebaseAuth;
  MockGoogleSignIn mockGoogleSignIn;
  MockGoogleSignInAccount mockGoogleSignInAccount;
  MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  MockAuthProvider mockAuthProvider;
  MockAuthCredential mockAuthCredential;

  AuthenticationRepository createUnitUnderTest() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockAuthProvider = MockAuthProvider();
    mockAuthCredential = MockAuthCredential();
    return AuthenticationRepository(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
        authProvider: mockAuthProvider);
  }

  test('sign up throws SignUpFailure on exception', () {
    var uut = createUnitUnderTest();

    when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'), password: anyNamed('password')))
        .thenThrow(Exception());

    expect(() => uut.signUp(email: "test", password: "test"),
        throwsA(predicate((e) => e is SignUpFailure)));
  });

  test('log in with google throws LogInWithGoogleFailure on exception', () {
    var uut = createUnitUnderTest();

    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuthentication);
    when(mockAuthProvider.getCredential(any, any))
        .thenReturn(mockAuthCredential);
    when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(Exception());

    expect(() => uut.logInWithGoogle(),
        throwsA((e) => e is LogInWithGoogleFailure));
  });

  test(
      'log in with email and password throws LogInWithEmailAndPasswordFailure on exception',
      () {
    var uut = createUnitUnderTest();

    when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'), password: anyNamed('password')))
        .thenThrow(Exception());

    expect(
        () =>
            uut.logInWithEmailAndPassword(email: 'email', password: 'password'),
        throwsA((e) => e is LogInWithEmailAndPasswordFailure));
  });

  test('log out throws LogOutFailure on exception', () {
    var uut = createUnitUnderTest();

    when(mockFirebaseAuth.signOut()).thenThrow(Exception());
    when(mockGoogleSignIn.signOut()).thenThrow(Exception());

    expect(() => uut.logOut(), throwsA((e) => e is LogOutFailure));
  });
}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}
