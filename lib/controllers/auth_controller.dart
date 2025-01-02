import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthService _authService = AuthService();
  final Logger logger = Logger();

  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// Handle Google Sign-In and Sign-Up
  Future<void> loginWithGoogle() async {
    logger.i("Starting Google Sign-In process...");
    isLoading.value = true;

    try {
      // Step 1: Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the Google Sign-In process
        logger.w("Google Sign-In canceled by user.");
        throw Exception("Google Sign-In canceled by user.");
      }

      logger.i(
          "Google User Info: ${googleUser.email}, ${googleUser.displayName}");

      // Step 2: Obtain Google Sign-In Authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      logger.i(
          "Google Auth obtained. AccessToken: ${googleAuth.accessToken}, IdToken: ${googleAuth.idToken}");

      // Step 3: Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        logger.e("Firebase user is null after Google Sign-In.");
        throw Exception("Google Sign-In failed. Firebase user is null.");
      }

      logger.i("Firebase User Info: ${user.email}, ${user.displayName}");

      // Step 5: Check if the user is already registered in Firestore
      final existingUser = await _authService.getUser(user.uid);
      if (existingUser == null) {
        logger.i("New user detected. Saving user info to Firestore...");
        await _authService.saveUser(UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? "No Name",
        ));
      } else {
        logger.i("Existing user found in Firestore.");
      }

      // Step 6: Navigate to Dashboard
      logger.i("Google Sign-In successful. Redirecting to Dashboard...");
      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      // Firebase-specific errors
      logger.e("FirebaseAuthException: ${e.code} - ${e.message}");
      if (e.code == 'account-exists-with-different-credential') {
        Get.snackbar(
            'Error', 'This email is already linked with another account.');
      } else if (e.code == 'invalid-credential') {
        Get.snackbar('Error', 'Invalid credentials provided.');
      } else {
        Get.snackbar('Error', e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      // General errors
      logger.e("General Exception: $e");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      logger.i("Google Sign-In process completed.");
    }
  }

  /// Logout from Firebase and Google
  Future<void> logout() async {
    logger.i("Logging out...");
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      logger.i("Logout successful. Redirecting to Login...");
      Get.offAllNamed('/login');
    } catch (e) {
      logger.e("Logout Failed: $e");
      Get.snackbar('Logout Failed', e.toString());
    }
  }
}
