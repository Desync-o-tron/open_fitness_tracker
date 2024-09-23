import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

//todo
//turn on auth persistance! firesbase auth?a

MyStorage myStorage = MyStorage();

class MyStorage {
  MyStorage() {
    _firestore.settings = const Settings(
        persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    if (kIsWeb) {
      //haven't tested w/o this. doc is not up to date. idc.
      _firestore
          // ignore: deprecated_member_use
          .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
    }
    _userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    // getBasicUserInfo();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _historyCacheClock = CollectionCacheUpdateClock(_historyKey);
  late final DocumentReference _userDoc;
  static const _historyKey = 'TrainingHistory';
  static const _basicUserInfoKey = 'BasicUserInfo';

  Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    _userDoc.collection(_historyKey).add(session.toJson());
  }

  Stream<List<TrainingSession>> getUserTrainingHistoryStream({
    required int limit,
    DateTime? startAfterTimestamp,
  }) {
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
    QuerySnapshot<Object?> cloudTrainingHistory;
    if (useCache) {
      cloudTrainingHistory = await _userDoc
          .collection(_historyKey)
          .get(const GetOptions(source: Source.cache));
    } else {
      cloudTrainingHistory = await _userDoc
          .collection(_historyKey)
          .get(const GetOptions(source: Source.server));

      _historyCacheClock.resetClock();
    }

    List<TrainingSession> sessions = [];
    for (var doc in cloudTrainingHistory.docs) {
      sessions.add(TrainingSession.fromJson(doc.data() as Map<String, dynamic>));
    }

    return sessions;
  }

  /// will remove the history data corresponding to the id of the training session
  Future<void> removeTrainingSessionFromHistory(final TrainingSession sesh) async {
    if (sesh.id == '') {
      return Future.error("no session id!");
    }
    return _userDoc.collection(_historyKey).doc(sesh.id).delete();
  }

  //should we back this up?..maybe!
  Future<void> deleteEntireTrainingHistory() async {
    CollectionReference historyCollection = _userDoc.collection(_historyKey);
    QuerySnapshot snapshot = await historyCollection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    // Add delete operations for each document to the batch
    for (DocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<BasicUserInfo> getBasicUserInfo() async {
    try {
      final docSnapshot = await _userDoc.get(const GetOptions(source: Source.server));
      final data = docSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey(_basicUserInfoKey)) {
        final basicUserInfoJson = data[_basicUserInfoKey] as Map<String, dynamic>;
        return BasicUserInfo.fromJson(basicUserInfoJson);
      } else {
        //DNE
        return BasicUserInfo();
      }
    } catch (e) {
      throw Exception('Failed to get basic user info: $e');
    }
  }

  Future<void> setBasicUserInfo(BasicUserInfo userInfo) async {
    _userDoc.update({_basicUserInfoKey: userInfo.toJson()});
  }

  // void addFieldToDocument(String docId, String collectionName) async {
  //   // Get a reference to the Firestore document
  //   DocumentReference documentReference =
  //       FirebaseFirestore.instance.collection(collectionName).doc(docId);

  //   // Add a new field to the document (or update it if it already exists)
  //   try {
  //     await documentReference.update({
  //       'newFieldName': 'newValue', // Field name and value you want to add
  //     });
  //     print('Field added successfully');
  //   } catch (e) {
  //     print('Error updating document: $e');
  //   }
  // }
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
