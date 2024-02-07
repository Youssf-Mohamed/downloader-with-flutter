import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

//https://pub.dev/packages/youtube_explode_dart the lib for youtube downloader

class HomeScreenPc extends StatefulWidget {
  @override
  State<HomeScreenPc> createState() => _HomeScreenPcState();
}

class _HomeScreenPcState extends State<HomeScreenPc> {
  late String audiosize ;
  late String videosize ;
  var search = TextEditingController();
  var thumbnailimage=null;
  var video=null;
  String? videoname=null;
  final yt = YoutubeExplode();
  String? downloadpath=null;
  Future<StreamManifest>? manifest=null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        Column(
          children: [
              //  IconButton(onPressed: (){}, icon: Icon(Icons.video_collection)),
                IconButton(onPressed: () async {
                   downloadpath = await getpath();
                }, icon: Icon(Icons.file_copy))
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5,),
                Text('Downloader',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 40,),),
                SizedBox(height: 5,),
                Container(
                 width: 600,
                 height: 50,
                 child: TextFormField(
                  controller: search,
                   decoration: InputDecoration(
                     hintText: 'Put Youtube Video Url here',
                     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                     border: OutlineInputBorder()
                   ),
                   onChanged: (value) {
                     video = yt.videos.get(search.text)
                         .then((value) async {
                       print(value.url);
                       thumbnailimage=value.thumbnails.standardResUrl;
                       print(value.title);
                       print(value.thumbnails);
                       print(value.duration);
                       print(value.id);
                       manifest = yt.videos.streamsClient.getManifest(value.id);
                      await manifest?.then((value) {
                         videosize = value.muxed.withHighestBitrate().size.totalMegaBytes.toStringAsPrecision(3);
                         print('video size ${value.muxed.withHighestBitrate().size.totalMegaBytes.toStringAsPrecision(3)}');
                         audiosize = value.audioOnly.withHighestBitrate().size.totalMegaBytes.toStringAsPrecision(3);
                         print('audio size ${value.audioOnly.withHighestBitrate().size.totalMegaBytes.toStringAsPrecision(3)}');
                       });
                       videoname=await handelNameErrors(value.title);
                     }).then((value) {
                       setState(() {
                         print(thumbnailimage);
                       });
                     }).onError((error, stackTrace) {
                       thumbnailimage = videoname = manifest =null!;
                     });

                   },
              ),
               ),
                SizedBox(height: 5,),
                thumbnailimage!=null?
                Expanded(
                  flex: 8,
                  child: Container(
                    width: 700,
                    height: 600,
                    child: Image.network('$thumbnailimage'),),
                )
                    :Container(),
                SizedBox(height: 5,),
                thumbnailimage!=null?
               Expanded(
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     MaterialButton(onPressed: () async {
                       if(downloadpath==null)
                         {
                           downloadpath = await getpath();
                         }
                       print(manifest);
                       if(manifest!=null)
                       {
                         var streamInfo;
                         await manifest?.then((value) { streamInfo = value.muxed.withHighestBitrate();});
                         if(streamInfo!=null&&downloadpath!=null)
                         {
                           print('downloading');
                           var stream=yt.videos.streamsClient.get(streamInfo);
                           var file = File(downloadpath!+videoname!+'.mp4');
                           print(downloadpath!+videoname!+'.mp4');
                           var fileStream = file.openWrite();
                           await stream.pipe(fileStream);
                           await fileStream.flush();
                           await fileStream.close();
                         }
                         else{
                           print('Error on streaminfo or downloadpath !!!');
                         }
                       }else{
                         print('Error');
                       }
                       print('downloading done');
                     },child: Row(
                       children: [
                         Icon(Icons.ondemand_video_outlined,size: 30),
                         Text('Download (MP4) 720p ${videosize} MB',style: TextStyle(fontSize: 20)),
                       ],
                     ),),
                     MaterialButton(onPressed: () async {
                       if(downloadpath==null)
                       {
                         downloadpath = await getpath();
                       }
                       print(manifest);
                       if(manifest!=null)
                       {
                         var streamInfo;
                         await manifest?.then((value) {
                           streamInfo = value.audioOnly.withHighestBitrate();
                         });
                         if(streamInfo!=null&&downloadpath!=null)
                         {
                           print('downloading');
                           var stream=yt.videos.streamsClient.get(streamInfo);
                           var file = File(downloadpath!+videoname!+'.mp3');
                           print(downloadpath!+videoname!+'.mp3');
                           var fileStream = file.openWrite();
                           await stream.pipe(fileStream);
                           await fileStream.flush();
                           await fileStream.close();
                         }
                         else{
                           print('Error on streaminfo or downloadpath !!!');
                         }
                       }else{
                         print('Error');
                       }
                       print('downloading done');
                     },child: Row(
                       children: [
                         Icon(Icons.music_video,size: 30),
                         Text('Download (MP3) HD ${audiosize} MB',style: TextStyle(fontSize: 20)),
                       ],
                     ),)
                   ],
                 ),
               )
                    :Container(),

          ]),

        ),
      ],),
    );
  }

  String? handelNameErrors(String title) {
    String NewVideoName='';
    for(int i=0;i<title.length;i++)
    {
      if(title[i]!=':'&&title[i]!='\\'&&title[i]!='.')
      {
        NewVideoName = NewVideoName+title[i];
      }
    }
    return NewVideoName;
  }

  Future<String?> getpath() async {
    downloadpath = await FilePicker.platform.getDirectoryPath();
    while(downloadpath==null)
    {
      print('Error try again');
      downloadpath = await FilePicker.platform.getDirectoryPath();
    }
    if(downloadpath![downloadpath!.length-1]!='\\')
    {
      downloadpath = '$downloadpath\\';
    }
    print(downloadpath);
    return downloadpath;
  }
}
