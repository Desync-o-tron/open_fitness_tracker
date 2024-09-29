import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

late CloudStorage cloudStorage;

class CloudStorage {
  CloudStorage([FirebaseFirestore? fakeFirestore, FirebaseAuth? fakeFirebaseAuth]) {
    if (fakeFirebaseAuth != null) {
      firebaseAuth = fakeFirebaseAuth;
    } else {
      firebaseAuth = FirebaseAuth.instance;
    }
    if (fakeFirestore != null) {
      firestore = fakeFirestore;
    } else {
      firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      //todo test this stuff on web:
      // ignore: deprecated_member_use
      // firestore.enablePersistence(
      //   const PersistenceSettings(synchronizeTabs: true),
      // );
    }
    _historyCacheClock = CollectionCacheUpdateClock(_historyKey);
    firebaseAuth.userChanges().listen((User? user) {
      routerConfig.refresh(); //https://stackoverflow.com/a/77448906/3894291
      if (user != null) {
        cloudStorage.refreshCacheIfItsBeenXHours(12); //todo this is weird, bad bad
      }
    });

    if (!isUserEmailVerified()) return;
    refreshCacheIfItsBeenXHours(12);
  }

  late final FirebaseFirestore firestore;
  late final FirebaseAuth firebaseAuth;
  final _historyKey = 'TrainingHistory';
  final _basicUserInfoKey = 'BasicUserInfo';
  final _globalExercisesKey = 'GlobalExercises';
  final _userAddedExercisesKey = 'UserAddedExercises';
  final _userRemovedExercisesKey = 'UserRemovedExercises';
  //^so they won't see the global exercises they don't care about
  late final CollectionCacheUpdateClock _historyCacheClock;
  final trainHistoryDB = TrainHistoryDB();
  final exDB = ExDB();

  bool isUserEmailVerified() {
    return (firebaseAuth.currentUser != null && firebaseAuth.currentUser!.emailVerified);
  }

  //TODO update for ex's
  Future<void> refreshCacheIfItsBeenXHours(int hours) async {
    if (!cloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    if (await cloudStorage._historyCacheClock.timeSinceCacheWasUpdated() >
        Duration(hours: hours)) {
      await trainHistoryDB.getEntireUserTrainingHistory(useCache: false);
    }
  }

  Future<BasicUserInfo> getBasicUserInfo() async {
    if (!isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    return await _retryWithExponentialBackoff(() async {
      final docSnapshot = await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .get(const GetOptions(source: Source.server));
      final data = docSnapshot.data(); // as Map<String, dynamic>?;

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
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({_basicUserInfoKey: userInfo.toJson()});
    });
  }

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
            return await operation();
          } on FirebaseException catch (e) {
            if (e.code == 'permission-denied') {
              // Handle permission error
              rethrow;
            } else if (e.code == 'unavailable') {
              // ignore: unused_local_variable
              var user = firebaseAuth.currentUser;
              // ignore: unused_local_variable
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
        delay *= 2;
        retryCount++;
      }
    }
  }
}

class TrainHistoryDB {
  Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    if (!cloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await cloudStorage._retryWithExponentialBackoff(() async {
      await cloudStorage.firestore
          .collection('users')
          .doc(cloudStorage.firebaseAuth.currentUser!.uid)
          .collection(cloudStorage._historyKey)
          .add(session.toJson());
    });
  }

  Stream<List<TrainingSession>> getUserTrainingHistoryStream({
    required int limit,
    DateTime? startAfterTimestamp,
  }) {
    if (!cloudStorage.isUserEmailVerified()) {
      return Stream.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }

    final String userUid = cloudStorage.firebaseAuth.currentUser!.uid;
    final String collectionPath = 'users/$userUid/$cloudStorage._historyKey';

    Query query = cloudStorage.firestore
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

  Future<List<TrainingSession>> getEntireUserTrainingHistory({
    required bool useCache,
  }) async {
    if (!cloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    return await cloudStorage._retryWithExponentialBackoff(() async {
      QuerySnapshot<Object?> cloudTrainingHistory;
      if (useCache) {
        cloudTrainingHistory = await cloudStorage.firestore
            .collection('users')
            .doc(cloudStorage.firebaseAuth.currentUser!.uid)
            .collection(cloudStorage._historyKey)
            .get(const GetOptions(source: Source.cache));
      } else {
        cloudTrainingHistory = await cloudStorage.firestore
            .collection('users')
            .doc(cloudStorage.firebaseAuth.currentUser!.uid)
            .collection(cloudStorage._historyKey)
            .get(const GetOptions(source: Source.server));
        cloudStorage._historyCacheClock.resetClock();
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
    if (!cloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    if (sesh.id == '') {
      throw Exception("No training session ID! does this training session exist?");
    }
    await cloudStorage._retryWithExponentialBackoff(() async {
      await cloudStorage.firestore
          .collection('users')
          .doc(cloudStorage.firebaseAuth.currentUser!.uid)
          .collection(cloudStorage._historyKey)
          .doc(sesh.id)
          .delete();
    });
  }

  Future<void> deleteEntireTrainingHistory() async {
    if (!cloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await cloudStorage._retryWithExponentialBackoff(() async {
      CollectionReference historyCollection = cloudStorage.firestore
          .collection('users')
          .doc(cloudStorage.firebaseAuth.currentUser!.uid)
          .collection(cloudStorage._historyKey);
      QuerySnapshot snapshot = await historyCollection.get();
      WriteBatch batch = cloudStorage.firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    });
  }
}

class ExDB {
  Exercises get exercises => _exercises;
  List<String> get categories => _categories;
  List<String> get muscles => _muscles;
  List<String> get names => _names;
  List<String> get equipment => _equipment;

  final List<String> _names = [];
  final List<String> _categories = [];
  final List<String> _muscles = [];
  final List<String> _equipment = [];
  final List<Exercise> _exercises = [];

  Future<void> loadExercises(bool useCache) async {
    if (!cloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await cloudStorage._retryWithExponentialBackoff(() async {
      QuerySnapshot<Object?> globalExsSnapshot;
      QuerySnapshot<Object?> usrRemovedExsSnapshot;
      QuerySnapshot<Object?> usrAddedExsSnapshot;
      globalExsSnapshot = await cloudStorage.firestore
          .collection(cloudStorage._globalExercisesKey)
          .get(GetOptions(source: useCache ? Source.cache : Source.server));
      Exercises globalExs = [];
      Exercises usrRemovedExs = [];
      Exercises usrAddedExs = [];
      for (var doc in globalExsSnapshot.docs) {
        globalExs.add(Exercise.fromJson(doc.data() as Map<String, dynamic>));
      }
      final finalExercises = globalExs;
      for (var exercise in finalExercises) {
        _exercises.addIfDNE(exercise);
        _names.addIfDNE(exercise.name);
        _categories.addIfDNE(exercise.category);
        _equipment.addIfDNE(exercise.equipment);
        _muscles.addAllIfDNE(exercise.primaryMuscles);
        if (exercise.secondaryMuscles != null) {
          _muscles.addAllIfDNE(exercise.secondaryMuscles!);
        }
      }

      //todo the rest..!

      // usrAddedExsSnapshot = await cloudStorage.firestore
      //     .collection('users')
      //     .doc(cloudStorage.firebaseAuth.currentUser!.uid)
      //     .collection(cloudStorage._historyKey)
      // .get(GetOptions(source: useCache ? Source.cache : Source.serverAndCache));
    });
  }

  Future<void> removeExercises(Exercises exericises) async {
    throw Exception("todo");
  }

  Future<void> addExercisesToGlobalList(Exercises exericises) async {
    for (var ex in exericises) {
      await cloudStorage.firestore
          .collection(cloudStorage._globalExercisesKey)
          .add(ex.toJson());
    }
  }

  Future<void> addExercises(Exercises exericises) async {
    throw Exception("todo");
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
