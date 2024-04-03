import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

// class A {
//   static int foo() {
//     return 1;
//   }
// }

// class B extends A {
//   @override
//   int foo() {
//     return 2;
//   }
// }

class FirestoreHydratedStorageSync {
  /*
  goal here: have a function to check the history and ex's, compare them with the last time they were updated, and update firestore with the new data.
  */

  final HydratedStorage storage;
  FirestoreHydratedStorageSync(this.storage);
  static const historyKey = 'TrainingHistoryCubit';
  static const tokenForLastSync = '^lastSync';
  // static const exercises = ''; //todo
  void sync() {
    if (!FirebaseAuth.instance.currentUser!.emailVerified) return;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(FirebaseAuth.instance.currentUser!.uid);

    var history = storage.read(historyKey);
    var oldHistory = storage.read(historyKey + tokenForLastSync);

    List<Map<String, dynamic>> stringifiedHistory = [];
    if (history != null) {
      for (Map<dynamic, dynamic> sesh in history['trainingHistory']) {
        stringifiedHistory.add(sesh.cast<String, dynamic>());
        // stringifiedHistory[sesh.]
      }
    }

    if (history != oldHistory) {
      for (var sesh in stringifiedHistory) {
        userDoc.collection(historyKey).add(sesh);
      }
      // userDoc.collection('trainingHistory').add(history);
      storage.write(historyKey + tokenForLastSync, history);
    }

    // DocumentSnapshot userSnapshot = await userDoc.get();
    // CollectionReference userAttributeCollection = userSnapshot.reference.collection(key);
    // userAttributeCollection.add(read(key));
    int i = 0;
    // userAttributeCollection.doc()
    // userAttributeCollection.
    // .set({key: read(key)});

    // await FirebaseFirestore.instance
    // .collection(collection)
    // .doc("doc_Id")
    // .set(data);
    // });
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