import 'dart:io';
import 'dart:typed_data';

import 'package:develope_someting/image_picker_screen.dart';
import 'package:develope_someting/imageremove.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ProcessStatus {
  notstarted,
  processing,
  done;
}

class RemoveBg extends StatefulWidget {
  const RemoveBg({super.key});

  @override
  State<RemoveBg> createState() => _RemoveBgState();
}

class _RemoveBgState extends State<RemoveBg> {
  ImagePicker2 imagepicker = ImagePicker2();
  XFile? xFile;

  ProcessStatus processStatus = ProcessStatus.notstarted;

  Uint8List? imageInBytes;

  ImgRemoveBg imgRemoveBg = ImgRemoveBg();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Upload Image"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      imagepicker.getImageFromGallery().then((value) {
                        setState(() {
                          xFile = value;
                        });
                      });
                    },
                    child: const Text("Gallery"))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: xFile == null
                  ? const Placeholder()
                  : Image.file(File(xFile!.path)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: xFile == null
                        ? null
                        : () {
                            //for loading

                            setState(() {
                              processStatus = ProcessStatus.processing;
                            });

                            imgRemoveBg.removebg(context, xFile!).then((value) {
                              setState(() {
                                processStatus = ProcessStatus.done;

                                imageInBytes = value;
                              });
                            });
                          },
                    child: const Text("Remove BG"))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: processStatus == ProcessStatus.notstarted
                  ? const Placeholder()
                  : processStatus == ProcessStatus.processing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 45,
                              width: 45,
                              child: CircularProgressIndicator(),
                            )
                          ],
                        )
                      : imageInBytes == null
                          ? Container()
                          : Image.memory(imageInBytes!),
            ),
          )
        ],
      )),
    );
  }
}
