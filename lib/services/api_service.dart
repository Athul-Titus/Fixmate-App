import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ApiService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<String>> getBrands() async {
    final snapshot = await _firestore.collection('brands').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<List<String>> getAppliances(String brand) async {
    final snapshot = await _firestore
        .collection('brands')
        .doc(brand)
        .collection('appliances')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<List<String>> getIssues(String brand, String appliance) async {
    final snapshot = await _firestore
        .collection('brands')
        .doc(brand)
        .collection('appliances')
        .doc(appliance)
        .collection('issues')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<Map<String, dynamic>> getSolution(String brand, String appliance, String issue) async {
    final doc = await _firestore
        .collection('brands')
        .doc(brand)
        .collection('appliances')
        .doc(appliance)
        .collection('issues')
        .doc(issue)
        .get();
        
    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    }
    
    // Fallback if not found
    return {
      'fix': 'No solution found in database for this issue.',
      'quickTips': [],
    };
  }

  // Basic prefix search using collectionGroup
  static Future<Map<String, dynamic>> search(String query, {int page = 1, int limit = 20}) async {
    if (query.isEmpty) return {'results': []};
    
    // Convert to lowercase for basic matching
    final String searchLower = query.toLowerCase();
    
    final snapshot = await _firestore
        .collectionGroup('issues')
        .get();
        
    // In-memory filtering (acceptable only for small datasets)
    final List<Map<String, dynamic>> results = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final title = (data['title'] ?? doc.id).toString().toLowerCase();
      final fix = (data['fix'] ?? '').toString().toLowerCase();
      
      if (title.contains(searchLower) || fix.contains(searchLower)) {
        // We need to reconstruct the path since it's a collection group
        final pathSegments = doc.reference.path.split('/');
        final brand = pathSegments.length >= 2 ? pathSegments[1] : 'Unknown';
        final appliance = pathSegments.length >= 4 ? pathSegments[3] : 'Unknown';
        
        results.add({
          'brand': brand,
          'appliance': appliance,
          'issue': doc.id,
          'title': data['title'] ?? doc.id,
          'snippet': data['fix'] ?? '',
        });
      }
    }
    
    return {
      'results': results.take(limit).toList(),
      'total': results.length,
      'pages': (results.length / limit).ceil(),
      'current_page': page,
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      return {
        'message': 'Login successful',
        'user': {
          'id': user?.uid,
          'name': user?.displayName ?? 'User',
          'email': user?.email,
        }
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(name);
      
      final user = userCredential.user;
      return {
        'message': 'User registered successfully',
        'user': {
          'id': user?.uid,
          'name': name,
          'email': user?.email,
        }
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Signup failed');
    }
  }

  // Debug function to seed initial data so the UI works
  static Future<void> seedDatabase() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/fixmate_data.json');
      final List<dynamic> data = jsonDecode(jsonString);

      final Set<String> createdBrands = {};
      final Set<String> createdAppliances = {};

      var batch = _firestore.batch();
      int count = 0;

      for (var item in data) {
        final brand = item['brand'] as String;
        final appliance = item['appliance'] as String;
        final issueTitle = item['issue_title'] as String;
        final solution = item['solution'] as String;

        // Generate a safe document ID
        final issueId = issueTitle
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '_')
            .replaceAll(RegExp(r'_+'), '_');

        if (!createdBrands.contains(brand)) {
          batch.set(_firestore.collection('brands').doc(brand), <String, dynamic>{});
          createdBrands.add(brand);
          count++;
        }

        final applianceKey = '${brand}_$appliance';
        if (!createdAppliances.contains(applianceKey)) {
          batch.set(
            _firestore.collection('brands').doc(brand).collection('appliances').doc(appliance),
            <String, dynamic>{}
          );
          createdAppliances.add(applianceKey);
          count++;
        }

        // Add issue
        batch.set(
          _firestore.collection('brands').doc(brand).collection('appliances').doc(appliance).collection('issues').doc(issueId),
          {
            'title': issueTitle,
            'fix': solution,
            'quickTips': ['See detailed solution below'],
          }
        );
        count++;

        // Firestore batch limit is 500
        if (count >= 400) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to seed massive database: $e');
    }
  }
}
