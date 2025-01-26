import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Singleton pattern for easy access
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  /// Check if user is logged in and determine their role based on the collection they belong to
  Future<Map<String, dynamic>> checkUserRole() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return {
          'isLoggedIn': false,
          'role': null,
        };
      }

      // Check if user exists in the patients collection
      final patientDoc =
          await _firestore.collection('bookers').doc(user.uid).get();

      if (patientDoc.exists) {
        return {
          'isLoggedIn': true,
          'role': "Venue Booker",
        };
      }

      // Check if user exists in the therapists collection
      final therapistDoc =
          await _firestore.collection('owners').doc(user.uid).get();

      if (therapistDoc.exists) {
        return {
          'isLoggedIn': true,
          'role': "Venue Owner",
        };
      }

      // User does not exist in either collection
      return {
        'isLoggedIn': true,
        'role': 'unknown',
      };
    } catch (e) {
      log('Error checking user role: $e');
      return {
        'isLoggedIn': false,
        'role': null,
      };
    }
  }

  /// Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      log('Sign-up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      log('Sign-in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Sign-out error: $e');
      rethrow;
    }
  }

  /// Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Firestore Methods

  /// Add data to a Firestore collection
  Future<void> addData(String collectionPath, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      log('Add data error: $e');
      rethrow;
    }
  }

  /// Add data with a specific document ID
  Future<void> addDataWithId(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(data);
    } catch (e) {
      log('Add data with ID error: $e');
      rethrow;
    }
  }

  /// Get data from a Firestore collection
  Future<List<Map<String, dynamic>>> getData(String collectionPath) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionPath).get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      log('Get data error: $e');
      rethrow;
    }
  }

  /// Update a Firestore document
  Future<void> updateData(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      log('Update data error: $e');
      rethrow;
    }
  }

  /// Delete a Firestore document
  Future<void> deleteData(String collectionPath, String docId) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      log('Delete data error: $e');
      rethrow;
    }
  }

  // Firebase Storage Methods

  /// Upload file to Firebase Storage
  Future<String> uploadFile(
      String path, String fileName, List<int> fileBytes) async {
    try {
      Reference ref = _storage.ref('$path/$fileName');
      UploadTask uploadTask = ref.putData(Uint8List.fromList(fileBytes));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      log('Upload file error: $e');
      rethrow;
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      Reference ref = _storage.ref(filePath);
      await ref.delete();
    } catch (e) {
      log('Delete file error: $e');
      rethrow;
    }
  }

  /// Get specific data of the current user by key and collection name
  Future<dynamic> getCurrentUserData(
      {required String key, String collection = 'patients'}) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception("User not logged in");
      }

      // Fetch the user document from the specified collection
      DocumentSnapshot userDoc =
          await _firestore.collection(collection).doc(uid).get();

      if (userDoc.exists) {
        if (userDoc.data() != null &&
            (userDoc.data() as Map<String, dynamic>).containsKey(key)) {
          return userDoc.get(key); // Return the value for the specified key
        } else {
          throw Exception("Key '$key' not found in user document");
        }
      } else {
        throw Exception("User document not found in collection '$collection'");
      }
    } catch (e) {
      log("Error fetching user data for key '$key': $e");
      return null; // Return null or handle the error appropriately
    }
  }
  Future<void> uploadCvFileToFirestore(String filePath, String uid) async {
    try {
      final File file = File(filePath);

      if (!await file.exists()) {
        throw Exception("File does not exist at path: $filePath");
      }

      // Convert file to Base64
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      // Store the Base64 string in Firestore
      await _firestore.collection('therapists').doc(uid).update({
        'cv_base64': base64String,
      });
      log("CV successfully uploaded to Firestore as Base64.");
    } catch (e) {
      log("Error uploading CV file to Firestore: $e");
      rethrow;
    }
  }
}
