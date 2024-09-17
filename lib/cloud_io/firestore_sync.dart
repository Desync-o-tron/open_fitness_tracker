import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';

//todo
//turn on auth persistance! firesbase auth
//enable firestore caching on web lul
MyStorage myStorage = MyStorage();

class MyStorage {
  static const historyKey = 'TrainingHistory';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addTrainingSessionToHistory(TrainingSession session) async {
    try {
      CollectionReference users = firestore.collection('users');
      DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
      await userDoc.collection(historyKey).add(session.toJson());
    } catch (e) {
      print("Error adding session to history: $e");
    }
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
    final String collectionPath = 'users/$userUid/$historyKey';

    Query query =
        FirebaseFirestore.instance.collection(collectionPath).orderBy('date', descending: true).limit(limit);

    if (startAfterTimestamp != null) {
      query = query.startAfter([startAfterTimestamp]);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrainingSession.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id;
      }).toList();
    });
  }

  /*
  Stream<List<TrainingSession>> getUserTrainingHistoryStream() {
    if (FirebaseAuth.instance.currentUser == null) {
      return Stream.error("Please sign in");
    }
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      return Stream.error("Please verify email");
    }

    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final String collectionPath = 'users/$userUid/$historyKey';

    final repository = FirestoreCollectionRepository(collectionPath);

    return repository.stream.map((List<DocumentSnapshot> docs) {
      return docs.map((doc) {
        return TrainingSession.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  */

  //todo can I make this lazy?
  //rmme
  // Future<List<TrainingSession>> getUserTrainingHistory() async {
  //   if (FirebaseAuth.instance.currentUser == null) return Future.error("please sign in");
  //   if (!FirebaseAuth.instance.currentUser!.emailVerified) return Future.error("please verify email");

  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   CollectionReference users = firestore.collection('users');
  //   DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

  //   var cloudTrainingHistory = await userDoc.collection(historyKey).getSavy();
  //   List<TrainingSession> sessions = [];
  //   for (var doc in cloudTrainingHistory.docs) {
  //     sessions.add(TrainingSession.fromJson(doc.data() as Map<String, dynamic>));
  //   }

  //   return sessions;
  // }

  // this smells. why do I have two rm calls (look at the caller) also, do I need to rm from the local oldhistory?

  /// will remove the history data corresponding to the id of the training session
  Future<void> removeHistoryData(final TrainingSession sesh) async {
    if (FirebaseAuth.instance.currentUser == null) return Future.error("please sign in");
    if (!FirebaseAuth.instance.currentUser!.emailVerified) return Future.error("please verify email");

    if (sesh.id == '') return Future.error("no session id!");

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
    return userDoc.collection(historyKey).doc(sesh.id).delete();
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

class FirestoreCollectionRepository {
  final CollectionReference _collectionRef;
  final List<DocumentSnapshot> _documents = [];
  final StreamController<List<DocumentSnapshot>> _controller = StreamController.broadcast();
  late StreamSubscription _subscription;

  final bool keepInMemory;

  // Getter for the stream of documents
  Stream<List<DocumentSnapshot>> get stream => _controller.stream;

  // Constructor
  FirestoreCollectionRepository(String collectionPath, {this.keepInMemory = true})
      : _collectionRef = FirebaseFirestore.instance.collection(collectionPath) {
    if (FirebaseAuth.instance.currentUser == null) throw Exception("please sign in");
    if (!FirebaseAuth.instance.currentUser!.emailVerified) throw Exception("please verify email");
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