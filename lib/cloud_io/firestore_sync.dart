import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';

//todo
//turn on auth persistance! firesbase auth

MyStorage myStorage = MyStorage();

class MyStorage {
  MyStorage() {
    firestore.settings = const Settings(
        persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    if (kIsWeb) {
      //haven't tested w/o this. doc is not up to date. idc.
      firestore
          // ignore: deprecated_member_use
          .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
    }
  }

  static const _historyKey = 'TrainingHistory';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _historyCacheClock = CollectionCacheUpdateClock(_historyKey);

  Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
    userDoc.collection(_historyKey).add(session.toJson());
  }

  Stream<List<TrainingSession>> getUserTrainingHistoryStream({
    required int limit,
    DateTime? startAfterTimestamp,
  }) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Stream.error("Please sign in");
    }
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      return Stream.error("Please verify email");
    }

    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final String collectionPath = 'users/$userUid/$_historyKey';

    Query query = FirebaseFirestore.instance
        .collection(collectionPath)
        .orderBy('date', descending: true)
        .limit(limit);

    if (startAfterTimestamp != null) {
      query = query.startAfter([startAfterTimestamp]);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrainingSession.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id;
      }).toList();
    });
  }

  Future<void> refreshTrainingHistoryCacheIfItsBeenXHours(int hours) async {
    if (await _historyCacheClock.timeSinceCacheWasUpdated() > Duration(hours: hours)) {
      getEntireUserTrainingHistory(useCache: false);
    }
  }

  Future<List<TrainingSession>> getEntireUserTrainingHistory(
      {required bool useCache}) async {
    if (FirebaseAuth.instance.currentUser == null) return [];
    if (!FirebaseAuth.instance.currentUser!.emailVerified) return [];

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

    QuerySnapshot<Object?> cloudTrainingHistory;
    if (useCache) {
      cloudTrainingHistory = await userDoc
          .collection(_historyKey)
          .get(const GetOptions(source: Source.cache));
      print('cache had ${cloudTrainingHistory.docs.length} items');
    } else {
      cloudTrainingHistory = await userDoc
          .collection(_historyKey)
          .get(const GetOptions(source: Source.server));
      // cloudTrainingHistory = await userDoc.collection(_historyKey).get();
      print('server had ${cloudTrainingHistory.docs.length} items');
      _historyCacheClock.resetClock();
    }

    List<TrainingSession> sessions = [];
    for (var doc in cloudTrainingHistory.docs) {
      sessions.add(TrainingSession.fromJson(doc.data() as Map<String, dynamic>));
    }

    return sessions;
  }

  // this smells. why do I have two rm calls (look at the caller) also, do I need to rm from the local oldhistory?

  /// will remove the history data corresponding to the id of the training session
  Future<void> removeHistoryData(final TrainingSession sesh) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return Future.error("please sign in");
    }
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      return Future.error("please verify email");
    }

    if (sesh.id == '') {
      return Future.error("no session id!");
    }

    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
    return userDoc.collection(_historyKey).doc(sesh.id).delete();
  }

  Future<void> deleteTrainingHistory() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return Future.error("Please sign in");
    }
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      return Future.error("Please verify your email");
    }
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
    CollectionReference historyCollection = userDoc.collection(_historyKey);
    QuerySnapshot snapshot = await historyCollection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    // Add delete operations for each document to the batch
    for (DocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

//todo I should be selective about how I call this...gets esp. to server can fail!
class CollectionCacheUpdateClock {
  final String _sharedPrefsLabel;
  late final Future<SharedPreferences> _prefs;
  CollectionCacheUpdateClock(String collectionName)
      : _sharedPrefsLabel = 'last_set_$collectionName' {
    _prefs = SharedPreferences.getInstance();
  }

  Future<bool> resetClock() async {
    var prefs = await _prefs;
    return prefs.setInt(_sharedPrefsLabel, DateTime.now().millisecondsSinceEpoch);
    //todo err handling
  }

  Future<Duration> timeSinceCacheWasUpdated() async {
    var prefs = await _prefs;
    final lastTimeMillis = prefs.getInt(_sharedPrefsLabel);
    final now = DateTime.now();
    var then = DateTime.fromMillisecondsSinceEpoch(0);
    if (lastTimeMillis != null) {
      then = DateTime.fromMillisecondsSinceEpoch(lastTimeMillis);
    }
    return now.difference(then);
  }
}

// https://github.com/furkansarihan/firestore_collection/blob/master/lib/firestore_document.dart
extension FirestoreDocumentExtension on DocumentReference {
  Future<DocumentSnapshot> getSavy() async {
    try {
      DocumentSnapshot ds = await get(const GetOptions(source: Source.cache));
      if (!ds.exists) return get(const GetOptions(source: Source.server));
      return ds;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}

// https://github.com/furkansarihan/firestore_collection/blob/master/lib/firestore_query.dart
extension FirestoreQueryExtension on Query {
  Future<QuerySnapshot> getSavy() async {
    try {
      QuerySnapshot qs = await get(const GetOptions(source: Source.cache));
      if (qs.docs.isEmpty) return get(const GetOptions(source: Source.server));
      return qs;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}
/*
class FirestoreCollectionRepository {
  final CollectionReference _collectionRef;
  final List<DocumentSnapshot> _documents = [];
  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController.broadcast();
  late StreamSubscription _subscription;

  final bool keepInMemory;

  // Getter for the stream of documents
  Stream<List<DocumentSnapshot>> get stream => _controller.stream;

  // Constructor
  FirestoreCollectionRepository(String collectionPath, {this.keepInMemory = true})
      : _collectionRef = FirebaseFirestore.instance.collection(collectionPath) {
    if (FirebaseAuth.instance.currentUser == null) throw Exception("please sign in");
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      throw Exception("please verify email");
    }
    _initialize();
  }

  void _initialize() async {
    try {
      // Initial data load
      QuerySnapshot snapshot = await _collectionRef.getSavy();

      if (keepInMemory) {
        _documents.addAll(snapshot.docs);
        // Emit the initial list
        _controller.add(List<DocumentSnapshot>.from(_documents));
      } else {
        // Emit the initial list directly without storing
        _controller.add(List<DocumentSnapshot>.from(snapshot.docs));
      }

      // Set up the real-time listener
      _subscription = _collectionRef.snapshots().listen(_onData);
    } catch (error) {
      _controller.addError(error);
    }
  }

  void _onData(QuerySnapshot snapshot) {
    if (keepInMemory) {
      // Handle real-time updates and update the local list
      for (var change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            _documents.add(change.doc);
            break;
          case DocumentChangeType.modified:
            int index = _documents.indexWhere((doc) => doc.id == change.doc.id);
            if (index != -1) {
              _documents[index] = change.doc;
            }
            break;
          case DocumentChangeType.removed:
            _documents.removeWhere((doc) => doc.id == change.doc.id);
            break;
        }
      }
      // Emit the updated list
      _controller.add(List<DocumentSnapshot>.from(_documents));
    } else {
      // Emit the current snapshot's documents directly
      _controller.add(List<DocumentSnapshot>.from(snapshot.docs));
    }
  }

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
*/