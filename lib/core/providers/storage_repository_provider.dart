import 'dart:io';

import 'package:drug_discovery/core/failure.dart';
import 'package:drug_discovery/core/providers/firebase_providers.dart';
import 'package:drug_discovery/core/type_defs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final storageRepositoryProvider = Provider(
    (ref) => StorageRepository(firebaseStorage: ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  // FutureEither<String> storeFile({
  //   required String path,
  //   required String id,
  //   required File? file,
  // }) async {
  //   try {
  //     // users/banner/123
  //     final ref = _firebaseStorage.ref().child(path).child(id);

  //     UploadTask uploadTask = ref.putFile(file!);

  //     final snapShot = await uploadTask;

  //     return right(await snapShot.ref.getDownloadURL());
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }
  FutureEither<String> storeFile({
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      if (file == null) {
        return left(Failure("File is null, cannot upload."));
      }

      final ref =
          _firebaseStorage.ref().child("$path/$id"); // Ensure correct path

      print("Uploading file to: $path/$id"); // Debugging log

      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot snapShot = await uploadTask.whenComplete(() => {});

      if (snapShot.state == TaskState.error) {
        return left(Failure("Upload failed, please try again."));
      }

      final downloadUrl = await snapShot.ref.getDownloadURL();

      print("File uploaded successfully. URL: $downloadUrl"); // Debugging log

      return right(downloadUrl);
    } catch (e) {
      print("Upload error: $e"); // Debugging log
      return left(Failure(e.toString()));
    }
  }
}
