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
    final Map<String, dynamic> sampleData = {
      'Samsung': {
        'Refrigerator': {
          'not_cooling': {
            'title': 'Fridge Not Cooling',
            'description': 'The refrigerator is running but not cooling properly.',
            'fix': 'Check and clean the condenser coils. Ensure the door seals are tight and not leaking air.',
            'quickTips': ['Clean coils every 6 months', 'Check for blocked air vents inside'],
          }
        },
        'Washing Machine': {
          'not_spinning': {
            'title': 'Washer Not Spinning',
            'description': 'The drum does not spin during the spin cycle.',
            'fix': 'Inspect the drive belt to see if it has snapped or is loose. Check the door latch switch for continuity.',
            'quickTips': ['Don\'t overload the machine', 'Ensure it is level on the floor'],
          }
        }
      },
      'LG': {
        'Air Conditioner': {
          'not_cooling': {
            'title': 'AC Not Blowing Cold Air',
            'description': 'The AC is running but blowing room temperature air.',
            'fix': 'Clean the air filter. If the filter is clean, the compressor might be malfunctioning or freon levels let low.',
            'quickTips': ['Clean filters monthly', 'Check the outdoor unit for debris buildup'],
          }
        }
      }
    };

    try {
      for (var brandEntry in sampleData.entries) {
        final brandName = brandEntry.key;
        await _firestore.collection('brands').doc(brandName).set({});

        final appliances = brandEntry.value as Map<String, dynamic>;
        for (var applianceEntry in appliances.entries) {
          final applianceName = applianceEntry.key;
          await _firestore
              .collection('brands')
              .doc(brandName)
              .collection('appliances')
              .doc(applianceName)
              .set({});

          final issues = applianceEntry.value as Map<String, dynamic>;
          for (var issueEntry in issues.entries) {
            final issueId = issueEntry.key;
            final issueData = issueEntry.value as Map<String, dynamic>;
            await _firestore
                .collection('brands')
                .doc(brandName)
                .collection('appliances')
                .doc(applianceName)
                .collection('issues')
                .doc(issueId)
                .set(issueData);
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to seed database: $e');
    }
  }
}
