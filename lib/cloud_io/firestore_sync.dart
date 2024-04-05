import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';

late FirestoreHydratedStorageSync cloudStorage;

class FirestoreHydratedStorageSync {
  /*
  goal here: have a function to check the history and ex's, compare them with the last time they were updated, and update firestore with the new data.
  */
  FirestoreHydratedStorageSync(this.storage);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final HydratedStorage storage;
  Function _onHistoryUpdate = () {};
  static const historyKey = 'TrainingHistoryCubit';
  static const tokenForLastSync = '^lastSync';
  // static const exercises = ''; //todo

  Future<void> sync() async {
    _listenForHistoryRemoval();
    while (true) {
      if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) {
        await _sendHistoryData();
        await _receiveHistoryData();
      } else {
        //listen for auth changes, so we don't have to wait 5 minutes after the user logs in to sync the data.
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null && user.emailVerified) {
            _sendHistoryData();
            _receiveHistoryData();
          }
        });
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void setOnHistoryUpdate(Function f) {
    _onHistoryUpdate = f;
  }

  /// will remove the history data corresponding to the id of the training session
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

  Future<void> _sendHistoryData() async {
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

    var history = storage.read(historyKey);
    if (history == null) return;
    var oldHistory = storage.read(historyKey + tokenForLastSync);

    List<Map<String, dynamic>> stringifiedHistory = [];
    for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
      stringifiedHistory.add(sesh.cast<String, dynamic>());
    }
    if (mapEquals(history, oldHistory) || oldHistory == null) {
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
        }
      }
      storage.write(historyKey + tokenForLastSync, history);
    }
  }

  Future<void> _receiveHistoryData() async {
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

    List<Map<String, dynamic>> stringifiedCloudHistory = [];
    var cloudTrainingHistory = await userDoc.collection(historyKey).get();
    for (var doc in cloudTrainingHistory.docs) {
      stringifiedCloudHistory.add(doc.data());
    }

    final history = storage.read(historyKey);
    List<Map<String, dynamic>> stringifiedHistory = [];
    if (history != null) {
      for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
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

/*
class FirestoreHydratedStorage extends HydratedStorage {
  FirestoreHydratedStorage(super.box);
  static List<String> dirtyKeys = [];

  // static Future<HydratedStorage> build({
  //   required Directory storageDirectory,
  //   HydratedCipher? encryptionCipher,
  // }) {
  //   return HydratedStorage.build(storageDirectory: storageDirectory, encryptionCipher: encryptionCipher);
  // }

  @override
  Future<void> write(String key, dynamic value) async {
    dirtyKeys.add(key);
    return super.write(key, value);
  }

  @override
  Future<void> delete(String key) {
    dirtyKeys.add(key);
    return super.delete(key);
  }

  void sync() {
    if (!FirebaseAuth.instance.currentUser!.emailVerified) return;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //right now all our keys will be for a collection in the user's document
    dirtyKeys.forEach((key) async {
      // DocumentSnapshot snapshot = await firestore.collection(collectionPath).doc(key).get();

      CollectionReference users = firestore.collection('users');
      DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
      DocumentSnapshot userSnapshot = await userDoc.get();
      CollectionReference userAttributeCollection = userSnapshot.reference.collection(key);
      userAttributeCollection.add(read(key));
      int i = 0;
      // userAttributeCollection.doc()
      // userAttributeCollection.
      // .set({key: read(key)});

      /*
      await FirebaseFirestore.instance
      .collection(collection)
      .doc("doc_Id")
      .set(data);
    */
    });
  }
}
*/

// ok we need to use firestore to store data, so we can have a timer that runs in the background and updates firestore with the current data.
// teh local data is always the source of truth, but we can use firestore to store the data and sync it between devices.
// in conjunction with a timer, we can inherit HydratedStorage with a flag that tells us if we have pending changes
// for reads... we can have a listener for firestore that updates the local data when it changes.
// you would think that
/*
class FirestoreHydratedStorage implements Storage {
  final FirebaseFirestore firestore;
  // late final String collectionPath;

  // FirestoreHydratedStorage({FirebaseFirestore? firestore, required this.collectionPath})
  // : firestore = firestore ?? FirebaseFirestore.instance;
  FirestoreHydratedStorage({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  dynamic read(String key) async {
    try {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {}
      // DocumentSnapshot snapshot = await firestore.collection(collectionPath).doc(key).get();

      // CollectionReference users = firestore.collection('users');
      // QuerySnapshot usersSnapshot = await users.get();

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference users = firestore.collection('users');
      DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);
      DocumentSnapshot userSnapshot = await userDoc.get();
      CollectionReference userAttributeCollection = userSnapshot.reference.collection(key);
      return userAttributeCollection.get();
      // userSnapshot.data()

      // user

      // firebase.us
      // CollectionReference collection = firestore.collection(key);
      // QuerySnapshot snapshot = await collection.get();

      // snapshot.docs.forEach((doc) {
      //   print("doc.data():");
      //   print(doc.data());
      // });
      // return snapshot.docs;

      //todo json stuff!
      // return snapshot.
      // return snapshot.exists ? snapshot.data() : null;
    } catch (e) {
      print("Error reading from Firestore: $e");
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    try {
      // await firestore.collection(collectionPath).doc(key).set(value);
    } catch (e) {
      print("Error writing to Firestore: $e");
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      // await firestore.collection(collectionPath).doc(key).delete();
    } catch (e) {
      print("Error deleting from Firestore: $e");
    }
  }

  @override
  Future<void> clear() async {
    try {
      // Firestore does not support clearing a collection via a single operation in client-side code.
      // You would need to delete documents individually or use a server-side solution like Cloud Functions.
      print(
          "FirestoreStorage.clear() is not supported directly. Consider implementing a server-side solution.");
    } catch (e) {
      print("Error clearing Firestore collection: $e");
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }
}
*/
