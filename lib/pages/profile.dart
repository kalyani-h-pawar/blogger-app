import 'dart:convert';
import 'dart:io';
import 'package:bloggers/pages/signin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import 'dashboard.dart';
class MyProfile extends StatefulWidget {
  MyProfile();

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  var userId;
  var currentUser={};
  late String username='';
  late String fullName='';
  late String companyName='';
  late String password='';
  late String fullNameEdit='';
  late String companyNameEdit='';
  late String passwordEdit='';
  var profilePic;
  bool isLoading=true;
  bool isEditable=false;
  bool _showPassword=false;
  bool isProfileChange=false;
  String passwordError='';
  String formError = '';
  @override
  void initState() {
    getProfile();
    super.initState();
  }
  getProfile()async{
    dynamic sessionUid= await FlutterSession().get("userId");
    setState(() {
      userId=sessionUid;
    });
   await get(Uri.parse(
       "https://blogger-mobile.herokuapp.com/user-by-id/$userId"),
       headers: {
         "content-type": "application/json",
         "accept": "application/json",
       }
   ).then((result) => {
     print('Res of profile is ${result.body}'),
     currentUser=jsonDecode(result.body),
     print("current user is $currentUser"),
     userId=currentUser['userId'],
     username=currentUser['username'],
     password=currentUser['password'],
     fullName=currentUser['fullName'],
     companyName=currentUser['companyName'],
     profilePic=currentUser['profilePic'],
   print("data after profile get call is $userId,$username,$profilePic,$password,$fullName,$companyName"),
    setState((){
      isLoading=false;
    })
   });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(
            builder: (context) => SignIn()),
            ModalRoute.withName("/signin")
            );
          }, icon: Icon(Icons.logout),color: Colors.white),
        ],
      ),
      body:isLoading ? SpinKitRotatingCircle(color: Colors.blueAccent[400],size: 70.0,) :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 20, 2, 0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3,10,3,10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Row(
              children: [
                profilePic == null ? Padding(
                  padding: const EdgeInsets.fromLTRB(90, 10, 0, 0),
                  child: CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('assets/nodp.png')
              ),
                ):Padding(
                padding: const EdgeInsets.fromLTRB(90, 10, 0, 0),
                child: CircleAvatar(backgroundImage: FileImage(File(profilePic)),radius: 70,)),
             IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () { getImage(); },
                  padding: EdgeInsets.fromLTRB(0.0, 40, 0, 0),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Center(child: Text(formError,style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),)),
            SizedBox(height: 10,),
                Table(
        // defaultColumnWidth: FixedColumnWidth(120.0),
        border: TableBorder.all(
        color: Colors.black,
                style: BorderStyle.solid,
                width: 1
        ),
              children: [
                TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,15,0,0),
                        child: Column(
                            children:[Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,0,10),
                                child: Text('User ID', style: TextStyle(fontSize: 20.0))),
                            ]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,15,0,0),
                            child: Text('$userId',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ]),
                TableRow( children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,13,0,5),
                    child: Column(children:[Text('Username', style: TextStyle(fontSize: 20.0))]),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5,10,0,5),
                        child: Text("$username", style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)
                        ),
                      )
                    ],
                  )
                ]),
                TableRow( children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,15,0,0),
                    child: Column(children:[Text('Full Name', style: TextStyle(fontSize: 20.0))]),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5,0,0,0),
                        child: TextFormField(
                            initialValue: fullName,
                            enabled: isEditable,
                            keyboardType: TextInputType.text,
                            onChanged: (e){setState(() {
                              fullNameEdit=e;
                            });
                            },
                            style: TextStyle(fontSize: 20.0,)
                        ),
                      )
                    ],
                  )
                ]),
                TableRow( children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,15,0,0),
                    child: Column(children:[Text('Password', style: TextStyle(fontSize: 20.0))]),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5,0,0,0),
                        child: TextFormField(
                            initialValue: password,
                            obscureText: !_showPassword,
                            enabled: isEditable,
                            keyboardType: TextInputType.text,
                            onChanged: (e){setState(() {
                              if(e.length <8){
                                setState(() {
                                  passwordError="Password must be 8 characters";
                                });
                              }else{
                                setState(() {
                                  passwordEdit=e;
                                  passwordError='';
                                });

                                FocusScope.of(context).requestFocus(FocusNode());
                              }
                            });
                            },
                            style: TextStyle(fontSize: 20.0)
                        ),
                      ),
                      Text("$passwordError",style: TextStyle(color: Colors.red),),
                    ],
                  )
                ]),
                TableRow( children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,15,0,0),
                    child: Column(children:[Text('Company Name', style: TextStyle(fontSize: 20.0))]),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5,0,0,0),
                        child: TextFormField(
                            initialValue: companyName,
                            enabled: isEditable,
                            keyboardType: TextInputType.text,
                            onChanged: (e){setState(() {
                              companyNameEdit=e;
                            });
                            },
                            style: TextStyle(fontSize: 20.0)
                        ),
                      )
                    ],
                  )
                ]),
                TableRow( children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10,10,10,10),
                    child: Text("")
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10,10,10,10),
                        child: isLoading ? SpinKitFadingCircle(color: Colors.blueAccent[400],size: 40.0,) :ElevatedButton(onPressed: (){
                          if(isEditable){
                            saveDetails(context);
                          }
                          else{
                            setState(() {
                              isEditable=!isEditable;
                              _showPassword= !_showPassword;
                            });
                          }
                        },
                            child: isEditable ? Text('Save Record'):Text('Edit Record')),
                      ),
                    ],
                  )
                ])
              ]),
          ]
            ),
          )
        ),
      )
    );
  }
  getImage() async {
    if(!isEditable){
      setState(() {
        isEditable=true;
        _showPassword= !_showPassword;
      });
    }
    final PickedFile = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic=PickedFile!.path;
      isProfileChange = true;
      formError='';
    });
    print('clicked profile img is $profilePic and pic flag is $isProfileChange');
  }
  saveDetails(BuildContext context) async{
    isLoading=true;
      print("before edited data is $fullName, $companyName, $password, $profilePic,$isProfileChange");
      print('pic flag $isProfileChange');
    if(fullNameEdit == '' && passwordEdit == '' && companyNameEdit == '' && isProfileChange == false){
      setState(() {
        // isEditable=false;
        formError="Please provide the data to update";
      });

    }else {
      setState(() {
        formError='';
      });
        if(fullNameEdit == '' && companyNameEdit == '' && passwordEdit == ''){

          setState(() {
            fullNameEdit=fullName;
            companyNameEdit=companyName;
            passwordEdit=password;
          });

      }
      else if(fullNameEdit == '' && companyNameEdit == ''){
          setState(() {
            fullNameEdit=fullName;
            companyNameEdit=companyName;
          });
      }
      else if(companyNameEdit == '' && passwordEdit == ''){
        setState(() {
          companyNameEdit=companyName;
          passwordEdit=password;
        });
      }
        else if(fullNameEdit == '' && passwordEdit == ''){
          setState(() {
            fullNameEdit=fullName;
            passwordEdit=password;
          });
        }


      print(
          "after editing is $fullNameEdit,$passwordEdit,$companyNameEdit,$profilePic");

        await put(Uri.parse(
            "https://blogger-mobile.herokuapp.com/users"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              "userId": userId,
              "fullName": fullNameEdit,
              "username": username,
              "password": passwordEdit,
              "companyName": companyNameEdit,
              "profilePic": profilePic
            })
        ).then((result) =>
        {
          print('edited data is ${result.body}'),
          Fluttertoast.showToast(
            msg: "Record Saved !",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          ).then((value) => {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>
                Dashboard()))
          })
        }
        );

      setState(() {
        isEditable=false;
        _showPassword=!_showPassword;
        isLoading=false;
      });
    }
  }
}
