import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class CloudStorage {
  static void init([FirebaseFirestore? fakeFirestore, FirebaseAuth? fakeFirebaseAuth]) {
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
    // _historyCacheClock = CollectionCacheUpdateClock(_historyKey);
    firebaseAuth.userChanges().listen((User? user) {
      routerConfig.refresh(); //https://stackoverflow.com/a/77448906/3894291
      if (user != null) {
        // CloudStorage.refreshCacheIfItsBeenXHours(12); //todo this is lazy I think
      }
    });

    if (!isUserEmailVerified()) return;
    ExDB.loadExercises(false);
    TrainHistoryDB.loadUserTrainingHistory(useCache: false);
    // refreshCacheIfItsBeenXHours(12);
  }

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static const _historyKey = 'TrainingHistory';
  static const _basicUserInfoKey = 'BasicUserInfo';
  static const _globalExercisesKey = 'GlobalExercises';
  static const _userAddedExercisesKey = 'UserAddedExercises';
  static const _userRemovedExercisesKey = 'UserRemovedExercises';
  //^so they won't see the global exercises they don't care about
  // static final CollectionCacheUpdateClock? _historyCacheClock;

  static bool isUserEmailVerified() {
    return (firebaseAuth.currentUser != null && firebaseAuth.currentUser!.emailVerified);
  }

  //todo update for ex's
  //todo I don't like this..can I not listen??
  /*
  static Future<void> refreshCacheIfItsBeenXHours(int hours) async {
    if (!CloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    if (await CloudStorage._historyCacheClock!.timeSinceCacheWasUpdated() >
        Duration(hours: hours)) {
      await trainHistoryDB.getEntireUserTrainingHistory(useCache: false);
    }
  }
  */

  static Future<BasicUserInfo> getBasicUserInfo() async {
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

  static Future<void> setBasicUserInfo(BasicUserInfo userInfo) async {
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

  static Future<T> _retryWithExponentialBackoff<T>(
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
              //todo if the user signs out, can we handle these async get / set options gracefully?
              //I think we will get permission denied here otherwise
              rethrow;
            } else if (e.code == 'unavailable') {
              //todo idk why this error is so pernicious..
              await firebaseAuth.signOut();
              // rethrow;
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
  static Future<List<TrainingSession>>? trainingHistory;

  static Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    if (!CloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await CloudStorage._retryWithExponentialBackoff(() async {
      await CloudStorage.firestore
          .collection('users')
          .doc(CloudStorage.firebaseAuth.currentUser!.uid)
          .collection(CloudStorage._historyKey)
          .add(session.toJson());
    });
  }

  static Stream<List<TrainingSession>> getUserTrainingHistoryStream({
    required int limit,
    DateTime? startAfterTimestamp,
  }) {
    if (!CloudStorage.isUserEmailVerified()) {
      return Stream.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }

    final String userUid = CloudStorage.firebaseAuth.currentUser!.uid;
    final String collectionPath = 'users/$userUid/$CloudStorage._historyKey';

    Query query = CloudStorage.firestore
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

  static Future<void> loadUserTrainingHistory({
    required bool useCache,
  }) async {
    if (!CloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await CloudStorage._retryWithExponentialBackoff(() async {
      QuerySnapshot<Object?> cloudTrainingHistory = await CloudStorage.firestore
          .collection('users')
          .doc(CloudStorage.firebaseAuth.currentUser!.uid)
          .collection(CloudStorage._historyKey)
          .get(GetOptions(source: useCache ? Source.cache : Source.server));

      // CloudStorage._historyCacheClock!.resetClock(); //todo ?

      List<TrainingSession> sessions = [];
      for (var doc in cloudTrainingHistory.docs) {
        sessions.add(
          TrainingSession.fromJson(doc.data() as Map<String, dynamic>),
        );
      }
      trainingHistory = Future.value(sessions);
    });
  }

  static Future<void> removeTrainingSessionFromHistory(final TrainingSession sesh) async {
    if (!CloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    if (sesh.id == '') {
      throw Exception("No training session ID! does this training session exist?");
    }
    await CloudStorage._retryWithExponentialBackoff(() async {
      await CloudStorage.firestore
          .collection('users')
          .doc(CloudStorage.firebaseAuth.currentUser!.uid)
          .collection(CloudStorage._historyKey)
          .doc(sesh.id)
          .delete();
    });
  }

  static Future<void> deleteEntireTrainingHistory() async {
    if (!CloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await CloudStorage._retryWithExponentialBackoff(() async {
      CollectionReference historyCollection = CloudStorage.firestore
          .collection('users')
          .doc(CloudStorage.firebaseAuth.currentUser!.uid)
          .collection(CloudStorage._historyKey);
      QuerySnapshot snapshot = await historyCollection.get();
      WriteBatch batch = CloudStorage.firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    });
  }
}

class ExDB {
  static Exercises get exercises => _exercises;
  static List<String> get categories => _categories;
  static List<String> get muscles => _muscles;
  static List<String> get names => _names;
  static List<String> get equipment => _equipment;

  static final List<String> _names = [];
  static final List<String> _categories = [];
  static final List<String> _muscles = [];
  static final List<String> _equipment = [];
  static final List<Exercise> _exercises = [];

  static Future<void> loadExercises(bool useCache) async {
    if (!CloudStorage.isUserEmailVerified()) {
      return Future.error(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc...");
    }
    await CloudStorage._retryWithExponentialBackoff(() async {
      QuerySnapshot<Object?> globalExsSnapshot;
      QuerySnapshot<Object?> usrRemovedExsSnapshot;
      QuerySnapshot<Object?> usrAddedExsSnapshot;
      globalExsSnapshot = await CloudStorage.firestore
          .collection(CloudStorage._globalExercisesKey)
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

      // usrAddedExsSnapshot = await CloudStorage.firestore!
      //     .collection('users')
      //     .doc(CloudStorage.firebaseAuth.currentUser!.uid)
      //     .collection(CloudStorage._historyKey)
      // .get(GetOptions(source: useCache ? Source.cache : Source.serverAndCache));
    });
  }

  static Future<void> removeExercises(Exercises exericises) async {
    throw Exception("todo");
  }

  static Future<void> addExercisesToGlobalList(Exercises exericises) async {
    for (var ex in exericises) {
      await CloudStorage.firestore
          .collection(CloudStorage._globalExercisesKey)
          .add(ex.toJson());
    }
  }

  static Future<void> addExercises(Exercises exericises) async {
    throw Exception("todo");
  }
}

//todo I want to rm
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
