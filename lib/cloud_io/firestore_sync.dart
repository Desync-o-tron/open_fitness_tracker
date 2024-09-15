import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
//todo
//turn on auth persistance! firesbase auth
//enable firestore caching on web lul

const historyKey = 'TrainingHistoryCubit';

//todo I wonder if I can use listen to firebase in combination with relying on cache otherwise.

//todo can I make this lazy?
Future<List<TrainingSession>> getUserTrainingHistory({required bool useCache}) async {
  // useCache = false;
  // todo auth persitance
  if (FirebaseAuth.instance.currentUser == null) return Future.error("please sign in");
  if (!FirebaseAuth.instance.currentUser!.emailVerified) return Future.error("please verify email");

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection('users');
  DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
  var cloudTrainingHistory = await userDoc.collection(historyKey).get(GetOptions(
        source: useCache ? Source.cache : Source.serverAndCache,
      ));
  // List<Map<String, dynamic>> stringifiedCloudHistory = [];
  List<TrainingSession> sessions = [];
  for (var doc in cloudTrainingHistory.docs) {
    // stringifiedCloudHistory.add(doc.data());
    sessions.add(TrainingSession.fromJson(doc.data()));
  }
  // for (var sesh in stringifiedCloudHistory) {
  //   sessions.add(TrainingSession.fromJson(sesh));
  // }

  return sessions;
}

/// will remove the history data corresponding to the id of the training session
// this smells. why do I have two rm calls (look at the caller) also, do I need to rm from the local oldhistory?
Future<void> removeHistoryData(final TrainingSession sesh) async {
  if (FirebaseAuth.instance.currentUser == null) return Future.error("please sign in");
  if (!FirebaseAuth.instance.currentUser!.emailVerified) return Future.error("please verify email");

  if (sesh.id == '') return Future.error("no session id!");

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection('users');
  DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
  return userDoc.collection(historyKey).doc(sesh.id).delete();
}


////
////
////
////

/*
late FirestoreHydratedStorageSync cloudStorage;

class FirestoreHydratedStorageSync {
  /*
  goal here: have a function to check the history and ex's,
   compare them with the last time they were updated, and update firestore with the new data.
  */
  FirestoreHydratedStorageSync(this.storage);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final HydratedStorage storage;
  Function _onHistoryUpdate = () {};
  final historyKey = 'TrainingHistoryCubit';
  static const tokenForLastSync = '^lastSync';
  // static const exercises = ''; //todo

  Future<void> sync() async {
    _listenForHistoryRemoval();
    while (true) {
      if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) {
        await _sendHistoryData();
        // await _receiveHistoryData();
      } else {
        //listen for auth changes, so if the user logs in,
        // they don't have to wait for the update interval to sync the data.
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null && user.emailVerified) {
            _sendHistoryData();
            fetchHistoryData();
          }
        });
      }
      await Future.delayed(const Duration(seconds: 60 * 5));
    }
  }

  void setOnHistoryUpdate(Function f) {
    _onHistoryUpdate = f;
  }

  /// will remove the history data corresponding to the id of the training session
  // this smells. why do I have two rm calls (look at the caller) also, do I need to rm from the local oldhistory?
  Future<bool> removeHistoryData(final TrainingSession sesh) async {
    if (FirebaseAuth.instance.currentUser == null || !FirebaseAuth.instance.currentUser!.emailVerified) {
      return false;
    }
    if (sesh.id == '') return false;

    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
    await userDoc.collection(historyKey).doc(sesh.id).delete();
    return true;
  }

  bool _pendingWritesToCloud() {
    var history = storage.read(historyKey);
    if (history == null) return false;
    var oldHistory = storage.read(historyKey + tokenForLastSync);
    if (oldHistory == null) return true;

    List<Map<String, dynamic>> stringifiedHistory = [];
    for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
      stringifiedHistory.add(sesh.cast<String, dynamic>());
    }

    // DeepCollectionEquality();

    return false;
  }

  Future<void> _sendHistoryData() async {
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

    var history = storage.read(historyKey);
    if (history == null) return;
    // var oldHistory = storage.read(historyKey + tokenForLastSync);

    List<Map<String, dynamic>> stringifiedHistory = [];

    for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
      stringifiedHistory.add(sesh.cast<String, dynamic>());
    }
    // if (mapEquals(history, oldHistory) || oldHistory == null) {
    // if (!mapEquals(history, oldHistory)) {
    if (_pendingWritesToCloud()) {
      //todo mapEquals is not as good as DeepCollectionEquality, I should really be comparing the ids and last edited timestamps themselves.
      for (var sesh in stringifiedHistory) {
        var docSnapshot = await userDoc.collection(historyKey).doc(sesh['id']).get();
        if (!docSnapshot.exists) {
          userDoc.collection(historyKey).doc(sesh['id']).set(sesh);
        } else {
          var cloudSesh = docSnapshot.data() as Map<String, dynamic>;
          DateTime cloudTime = DateTime.parse(cloudSesh['dateOfLastEdit']);
          DateTime localTime = DateTime.parse(sesh['dateOfLastEdit']);
          if (localTime.isAfter(cloudTime)) {
            userDoc.collection(historyKey).doc(sesh['id']).set(sesh);
          }
          //do something cool
        }
      }
      storage.write(historyKey + tokenForLastSync, history);
    }
    // }
  }

  //todo why don't we use firebase offline for this..
  //though I want to use a custom offline for exercises, right? theres a ton.
  //todo maybe full sync on sign in and use Firestore's onSnapshot method!
  Future<void> fetchHistoryData() async {
    /*
      make sure we've pushed writes to the server before we pull.
      ..then just take the whole online storage as the truth and overwrite what we have.
    */

    //todo I should give the user an error if they try and call this w/o signing in.
    if (FirebaseAuth.instance.currentUser == null) return;
    if (FirebaseAuth.instance.currentUser!.emailVerified) return;

    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

    List<Map<String, dynamic>> stringifiedCloudHistory = [];
    var cloudTrainingHistory = await userDoc
        .collection(historyKey)
        .get(); //this has got to be expensive, right? I'm pulling the whole collection down, no? check docs.
    for (var doc in cloudTrainingHistory.docs) {
      stringifiedCloudHistory.add(doc.data());
    }

    final history = storage.read(historyKey);
    List<Map<String, dynamic>> stringifiedHistory = [];
    if (history != null) {
      for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
        //todo
        stringifiedHistory.add(sesh.cast<String, dynamic>());
      }
    }

    // List<Map<String, dynamic>> sessionsChangedToRemove = [];
    // List<Map<String, dynamic>> sessionsToAdd = [];
    List<Map<String, dynamic>> updatedHistory = stringifiedHistory.toList();
    bool changed = false;
    for (var cloudSesh in stringifiedCloudHistory) {
      bool found = false;
      for (var sesh in stringifiedHistory) {
        if (sesh['id'] == cloudSesh['id']) {
          DateTime cloudUpdatedTime = DateTime.parse(cloudSesh['dateOfLastEdit']);
          DateTime localUpdatedTime = DateTime.parse(sesh['dateOfLastEdit']);
          if (localUpdatedTime.isBefore(cloudUpdatedTime)) {
            updatedHistory.remove(sesh);
            updatedHistory.add(cloudSesh);
            changed = true;
          }
          found = true;
          break;
        }
      }
      if (!found) {
        changed = true;
        updatedHistory.add(cloudSesh);
      }
    }

    storage.write(historyKey, {'trainingHistory': updatedHistory});
    // storage.write(historyKey + tokenForLastSync, {'trainingHistory': updatedHistory}); //hm
    changed ? _onHistoryUpdate() : null;
  }

  _listenForHistoryRemoval() async {
    while (true) {
      if (FirebaseAuth.instance.currentUser == null || !FirebaseAuth.instance.currentUser!.emailVerified) {
        await Future.delayed(const Duration(seconds: 5));
      } else {
        CollectionReference users = firestore.collection('users');
        DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
        userDoc.collection(historyKey).snapshots().listen(
          (event) {
            for (var change in event.docChanges) {
              if (change.type == DocumentChangeType.removed) {
                var history = storage.read(historyKey);
                List<Map<String, dynamic>> stringifiedHistory = [];
                if (history != null) {
                  for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
                    stringifiedHistory.add(sesh.cast<String, dynamic>());
                  }
                }
                stringifiedHistory.removeWhere((element) => element['id'] == change.doc.id);
                storage.write(historyKey, {'trainingHistory': stringifiedHistory});
                _onHistoryUpdate();
              }
            }
          },
        );
        break;
      }
    }
  }
}
*/