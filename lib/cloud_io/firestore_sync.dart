import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
TODO is there a smoke test I can run on web/devices deploy?
just want to see if the damn pages load & waht load times are like..
*/

CloudStorage cloudStorage = CloudStorage();

class CloudStorage {
  CloudStorage() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    // ignore: deprecated_member_use
    // _firestore.enablePersistence(
    //   const PersistenceSettings(synchronizeTabs: true),
    // );

    FirebaseAuth.instance.userChanges().listen((User? user) {
      routerConfig.refresh(); //https://stackoverflow.com/a/77448906/3894291
      if (user != null) {
        cloudStorage.refreshTrainingHistoryCacheIfItsBeenXHours(12);
      }
    });

    if (!isUserEmailVerified()) return;
    refreshTrainingHistoryCacheIfItsBeenXHours(12);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _historyCacheClock = CollectionCacheUpdateClock(_historyKey);

  static const _historyKey = 'TrainingHistory';
  static const _basicUserInfoKey = 'BasicUserInfo';

  // Helper method for retries with exponential backoff
  Future<T> _retryWithExponentialBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 5,
    int delayMilliseconds = 500,
  }) async {
    int retryCount = 0;
    int delay = delayMilliseconds;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (retryCount >= maxRetries) {
          try {
            // Firestore operation
          } on FirebaseException catch (e) {
            if (e.code == 'permission-denied') {
              // Handle permission error
              rethrow;
            } else if (e.code == 'unavailable') {
              var user = FirebaseAuth.instance.currentUser;
              int qq;
              // Handle network unavailable error
            } else {
              // Handle other Firebase exceptions
              rethrow;
            }
          } catch (e) {
            // Handle other exceptions
            rethrow;
          }
        }
        await Future.delayed(Duration(milliseconds: delay));
        delay *= 2; // Exponential backoff
        retryCount++;
      }
    }
  }

  bool isUserEmailVerified() {
    return (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.emailVerified);
  }

  Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await _retryWithExponentialBackoff(() async {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(_historyKey)
          .add(session.toJson());
    });
  }

  Stream<List<TrainingSession>> getUserTrainingHistoryStream({
    required int limit,
    DateTime? startAfterTimestamp,
  }) {
    if (!isUserEmailVerified()) {
      return Stream.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }

    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final String collectionPath = 'users/$userUid/$_historyKey';

    Query query = _firestore
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
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    if (await _historyCacheClock.timeSinceCacheWasUpdated() > Duration(hours: hours)) {
      await getEntireUserTrainingHistory(useCache: false);
    }
  }

  Future<List<TrainingSession>> getEntireUserTrainingHistory({
    required bool useCache,
  }) async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    return await _retryWithExponentialBackoff(() async {
      QuerySnapshot<Object?> cloudTrainingHistory;
      if (useCache) {
        cloudTrainingHistory = await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(_historyKey)
            .get(const GetOptions(source: Source.cache));
      } else {
        cloudTrainingHistory = await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(_historyKey)
            .get(const GetOptions(source: Source.server));
        _historyCacheClock.resetClock();
      }

      List<TrainingSession> sessions = [];
      for (var doc in cloudTrainingHistory.docs) {
        sessions.add(
          TrainingSession.fromJson(doc.data() as Map<String, dynamic>),
        );
      }

      return sessions;
    });
  }

  Future<void> removeTrainingSessionFromHistory(final TrainingSession sesh) async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    if (sesh.id == '') {
      throw Exception("No training session ID! does this training session exist?");
    }
    await _retryWithExponentialBackoff(() async {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(_historyKey)
          .doc(sesh.id)
          .delete();
    });
  }

  Future<void> deleteEntireTrainingHistory() async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await _retryWithExponentialBackoff(() async {
      CollectionReference historyCollection = _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(_historyKey);
      QuerySnapshot snapshot = await historyCollection.get();
      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    });
  }

  Future<BasicUserInfo> getBasicUserInfo() async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    return await _retryWithExponentialBackoff(() async {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(const GetOptions(source: Source.server));
      final data = docSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey(_basicUserInfoKey)) {
        final basicUserInfoJson = data[_basicUserInfoKey] as Map<String, dynamic>;
        return BasicUserInfo.fromJson(basicUserInfoJson);
      } else {
        return BasicUserInfo();
      }
    });
  }

  Future<void> setBasicUserInfo(BasicUserInfo userInfo) async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await _retryWithExponentialBackoff(() async {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({_basicUserInfoKey: userInfo.toJson()});
    });
  }
}

class CollectionCacheUpdateClock {
  final String _sharedPrefsLabel;
  late final Future<SharedPreferences> _prefs;

  CollectionCacheUpdateClock(String collectionName)
      : _sharedPrefsLabel = 'last_set_$collectionName' {
    _prefs = SharedPreferences.getInstance();
  }

  Future<bool> resetClock() async {
    var prefs = await _prefs;
    return prefs.setInt(
      _sharedPrefsLabel,
      DateTime.now().millisecondsSinceEpoch,
    );
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
