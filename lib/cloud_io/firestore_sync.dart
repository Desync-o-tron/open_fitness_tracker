import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appRouter.refresh(); //https://stackoverflow.com/a/77448906/3894291
      if (user != null) {
        // CloudStorage.refreshCacheIfItsBeenXHours(12); //todo this is lazy I think
      }
    });

    if (!isUserEmailVerified()) return;
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
      try {
        final docSnapshot = await firestore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .get(const GetOptions(source: Source.server));
        final data = docSnapshot.data();

        if (data != null && data.containsKey(_basicUserInfoKey)) {
          final basicUserInfoJson = data[_basicUserInfoKey] as Map<String, dynamic>;
          return BasicUserInfo.fromJson(basicUserInfoJson);
        } else {
          return BasicUserInfo();
        }
      } catch (e) {
        print(e.toString()); //todo rm
        rethrow;
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
    int maxRetries = (kDebugMode) ? 0 : 3,
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
              //todo just sign out & log???
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

abstract class TrainingHistoryState {}

class TrainingHistoryInitial extends TrainingHistoryState {}

class TrainingHistoryLoading extends TrainingHistoryState {}

class TrainingHistoryLoaded extends TrainingHistoryState {
  final List<TrainingSession> sessions;

  TrainingHistoryLoaded(this.sessions);
}

class TrainingHistoryError extends TrainingHistoryState {
  final String message;

  TrainingHistoryError(this.message);
}

class TrainingHistoryCubit extends Cubit<TrainingHistoryState> {
  TrainingHistoryCubit() : super(TrainingHistoryInitial());

  Future<void> loadUserTrainingHistory({bool useCache = true}) async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(TrainingHistoryError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    emit(TrainingHistoryLoading());
    //todo re enable me
    // try {
    await CloudStorage._retryWithExponentialBackoff(() async {
      try {
        QuerySnapshot<Object?> cloudTrainingHistory = await CloudStorage.firestore
            .collection('users')
            .doc(CloudStorage.firebaseAuth.currentUser!.uid)
            .collection(CloudStorage._historyKey)
            .get(GetOptions(source: useCache ? Source.cache : Source.server));

        List<TrainingSession> sessions = [];
        for (var doc in cloudTrainingHistory.docs) {
          sessions.add(
            TrainingSession.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id,
          );
        }
        sessions.sort((a, b) => b.date.compareTo(a.date));
        emit(TrainingHistoryLoaded(sessions));
      } catch (e) {
        print(e.toString());
        rethrow; //todo rm me
      }

      //todo whats up with trying to load history on startup for the first time?
    });
    // } catch (e) {
    //   emit(TrainingHistoryError(e.toString()));
    // }
  }

  Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(TrainingHistoryError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    try {
      await CloudStorage._retryWithExponentialBackoff(() async {
        await CloudStorage.firestore
            .collection('users')
            .doc(CloudStorage.firebaseAuth.currentUser!.uid)
            .collection(CloudStorage._historyKey)
            .add(session.toJson());
      });
      // Reload the training history to update the state
      await loadUserTrainingHistory(useCache: true);
    } catch (e) {
      emit(TrainingHistoryError(e.toString()));
    }
  }

  Future<void> removeTrainingSessionFromHistory(TrainingSession session) async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(TrainingHistoryError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    if (session.id == '') {
      emit(TrainingHistoryError(
          "No training session ID! Does this training session exist?"));
      return;
    }
    try {
      await CloudStorage._retryWithExponentialBackoff(() async {
        await CloudStorage.firestore
            .collection('users')
            .doc(CloudStorage.firebaseAuth.currentUser!.uid)
            .collection(CloudStorage._historyKey)
            .doc(session.id)
            .delete();
      });
      // Reload the training history to update the state
      await loadUserTrainingHistory(useCache: true);
    } catch (e) {
      emit(TrainingHistoryError(e.toString()));
    }
  }

  Future<void> deleteEntireTrainingHistory() async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(TrainingHistoryError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    //todo
    //idk too powerful atm..0 need to have this.
    emit(TrainingHistoryError("sorry john, I can't let you do that."));
    try {
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
      // Emit an empty list to reflect the deletion
      emit(TrainingHistoryLoaded([]));
    } catch (e) {
      emit(TrainingHistoryError(e.toString()));
    }
  }
}

abstract class ExercisesState {}

class ExercisesInitial extends ExercisesState {}

class ExercisesLoading extends ExercisesState {}

class ExercisesLoaded extends ExercisesState {
  final List<Exercise> exercises;
  final List<String> categories;
  final List<String> muscles;
  final List<String> names;
  final List<String> equipment;

  ExercisesLoaded({
    required this.exercises,
    required this.categories,
    required this.muscles,
    required this.names,
    required this.equipment,
  });
}

class ExercisesError extends ExercisesState {
  final String message;

  ExercisesError(this.message);
}

class ExercisesCubit extends Cubit<ExercisesState> {
  ExercisesCubit() : super(ExercisesInitial());

  Future<void> loadExercises({bool useCache = true}) async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(ExercisesError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    emit(ExercisesLoading());
    try {
      await CloudStorage._retryWithExponentialBackoff(() async {
        List<Exercise> exercises = [];
        List<String> names = [];
        List<String> categories = [];
        List<String> muscles = [];
        List<String> equipment = [];

        QuerySnapshot<Object?> globalExsSnapshot = await CloudStorage.firestore
            .collection(CloudStorage._globalExercisesKey)
            .get(GetOptions(source: useCache ? Source.cache : Source.server));
        QuerySnapshot<Object?> usrAddedExsSnapshot = await CloudStorage.firestore
            .collection('users')
            .doc(CloudStorage.firebaseAuth.currentUser!.uid)
            .collection(CloudStorage._userAddedExercisesKey)
            .get(GetOptions(source: useCache ? Source.cache : Source.serverAndCache));
        QuerySnapshot<Object?> usrRemovedExsSnapshot = await CloudStorage.firestore
            .collection('users')
            .doc(CloudStorage.firebaseAuth.currentUser!.uid)
            .collection(CloudStorage._userRemovedExercisesKey)
            .get(GetOptions(source: useCache ? Source.cache : Source.serverAndCache));

        for (var doc in globalExsSnapshot.docs) {
          exercises.add(Exercise.fromJson(doc.data() as Map<String, dynamic>));
        }
        for (var doc in usrAddedExsSnapshot.docs) {
          exercises.add(Exercise.fromJson(doc.data() as Map<String, dynamic>));
        }
        for (var doc in usrRemovedExsSnapshot.docs) {
          final ex2remove = Exercise.fromJson(doc.data() as Map<String, dynamic>);
          exercises.removeWhere((Exercise ex) => (ex.name == ex2remove.name));
        }

        for (final exercise in exercises) {
          names.addIfDNE(exercise.name);
          categories.addIfDNE(exercise.category);
          equipment.addIfDNE(exercise.equipment);
          muscles.addAllIfDNE(exercise.primaryMuscles);
          if (exercise.secondaryMuscles != null) {
            muscles.addAllIfDNE(exercise.secondaryMuscles!);
          }
        }

        // After processing, emit the loaded state
        emit(ExercisesLoaded(
          exercises: exercises,
          categories: categories,
          muscles: muscles,
          names: names,
          equipment: equipment,
        ));
      });
    } catch (e) {
      emit(ExercisesError(e.toString()));
    }
  }

  Future<void> removeExercises(List<Exercise> exercisesToRemove) async {
    //todo Implement the method
    // For now, let's emit an error
    emit(ExercisesError("removeExercises method not implemented"));
  }

  Future<void> addExercisesToGlobalList(List<Exercise> exercisesToAdd) async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(ExercisesError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    try {
      await CloudStorage._retryWithExponentialBackoff(() async {
        for (var ex in exercisesToAdd) {
          await CloudStorage.firestore
              .collection(CloudStorage._globalExercisesKey)
              .add(ex.toJson());
        }
      });
      // Optionally, reload the exercises
      await loadExercises(useCache: true);
    } catch (e) {
      emit(ExercisesError(e.toString()));
    }
  }

  Future<void> addExercises(List<Exercise> exercisesToAdd) async {
    if (!CloudStorage.isUserEmailVerified()) {
      emit(ExercisesError(
          "Sign in. Make sure to verify your email if not signing in with Google Sign In, etc..."));
      return;
    }
    try {
      await CloudStorage._retryWithExponentialBackoff(() async {
        for (var ex in exercisesToAdd) {
          await CloudStorage.firestore
              .collection('users')
              .doc(CloudStorage.firebaseAuth.currentUser!.uid)
              .collection(CloudStorage._userAddedExercisesKey)
              .add(ex.toJson());
        }
      });

      await loadExercises(useCache: true);
    } catch (e) {
      emit(ExercisesError(e.toString()));
    }
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
