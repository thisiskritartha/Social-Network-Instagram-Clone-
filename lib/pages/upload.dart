import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_storage/firebase_storage.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  const Upload({super.key, required this.currentUser});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  File? file;
  bool isUploading = false;
  String postId = const Uuid().v4();

  imageFromCamera() async {
    Navigator.pop(context);

    final XFile? pickFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 960,
      maxHeight: 675,
    );
    if (pickFile == null) return;
    setState(() {
      file = File(pickFile.path);
    });
  }

  imageFromGallery() async {
    Navigator.pop(context);
    final XFile? pickFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 960,
      maxHeight: 675,
    );
    if (pickFile == null) return;
    setState(() {
      file = File(pickFile.path);
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create Post'),
            children: [
              SimpleDialogOption(
                onPressed: imageFromCamera,
                child: const Text('Photo with Camera'),
              ),
              SimpleDialogOption(
                onPressed: imageFromGallery,
                child: const Text('Photo from Gallery'),
              ),
              SimpleDialogOption(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            color: Colors.white,
            height: 260,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () => selectImage(context),
              child: const Text(
                'Upload Images',
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
      locationController.clear();
      captionController.clear();
      isUploading = false;
    });
  }

  Future<String> uploadImage(imgFile) async {
    UploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imgFile);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirebase(
      {required String mediaUrl, String? location, String? description}) {
    postRef.doc(widget.currentUser.id).collection('userPosts').doc(postId).set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'location': location!,
      'description': description!,
      'timestamp': dateTime,
      'likes': {},
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 90));
    setState(() {
      file = compressedImageFile;
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirebase(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    locationController.clear();
    captionController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = const Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white54,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        centerTitle: true,
        title: const Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : const Text(''),
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 2.0,
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file!),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser!.photoUrl),
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: "Write a caption",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              size: 32.0,
              color: Colors.orange,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 50.0,
              width: 220.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextButton.icon(
                icon: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                onPressed: getUserLocation,
                label: const Text(
                  'Use my current location',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      String address = '${placemark.locality}, ${placemark.country}';
      setState(() {
        locationController.text = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
