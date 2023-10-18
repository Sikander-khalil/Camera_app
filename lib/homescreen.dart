import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Select and Crop Image"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(

          children: [

            SizedBox(height: 20.0,),

            imageFile == null ? Image.asset('assets/no_profile_image.png', height: 300, width: 300,) : ClipRRect(

              borderRadius: BorderRadius.circular(150.0),
              child: Image.file(imageFile!, height: 300.0, width: 300.0, fit: BoxFit.fill,),
            ),

            SizedBox(height: 20.0,),
            ElevatedButton(onPressed: ()async{

              Map<Permission, PermissionStatus> status = await [

                Permission.storage, Permission.camera,
              ].request();
              if(status[Permission.storage]!.isGranted && status[Permission.camera]!.isGranted){

                showImagePicker(context);

              }else{

                print("No permission provided");
              }

            }, child: Text("Select Image"))


          ],
        ),
      ),
    );
  }
  final image = ImagePicker();

 void showImagePicker(BuildContext context){

   showModalBottomSheet(context: context, builder: (builder){


     return Card(

       child: Container(

         width: MediaQuery.of(context).size.width,
         height: MediaQuery.of(context).size.height/5.2,
         margin:  EdgeInsets.only(top: 8.0),
         padding: EdgeInsets.all(12),
         child: Row(

           mainAxisAlignment: MainAxisAlignment.center,
           children: [

             Expanded(child: InkWell(
               child: Column(

                 children: [

                   Icon(Icons.image, size: 60,),
                   SizedBox(height: 12.0,),
                   Text("Gallery", textAlign: TextAlign.center,
                   style: TextStyle(fontSize: 16, color:  Colors.black),
                   ),
                 ],
               ),
               onTap: (){

                 _imgFromGallery();
                 Navigator.pop(context);

               },
             ),
             ),

             Expanded(child: InkWell(
               child: Column(

                 children: [

                   Icon(Icons.image, size: 60,),
                   SizedBox(height: 12.0,),
                   Text("Camera", textAlign: TextAlign.center,
                     style: TextStyle(fontSize: 16, color:  Colors.black),
                   ),
                 ],
               ),
               onTap: (){

                 _imgFromCamera();
                 Navigator.pop(context);

               },
             ),
             )
           ],
         ),
       ),
     );

   });


  }

  void _imgFromGallery() async{

   await image.pickImage(source: ImageSource.gallery, imageQuality: 50).then((value) => {

     if(value != null){

       _cropImage(File(value.path))
     }

   });


  }
  void _imgFromCamera() async{

    await image.pickImage(source: ImageSource.camera, imageQuality: 50).then((value) => {

    if(value != null){

        _cropImage(File(value.path))
  }

  });


  }

  _cropImage(File imgFile) async{

    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
     ]
   );

   if(croppedFile != null){


     imageCache.clear();
     setState(() {
       imageFile = File(croppedFile.path);
     });
   }


  }
}
