import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/continuesEdit.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import '../widgets/button.dart';

import '../style.dart';
import '../widgets/fieldAdd.dart';

class EditPetInfo extends StatefulWidget {
  static const String screenRoute = "editPetInfo_page";

  final String petId;
  final String owner;

  EditPetInfo({required this.petId, required this.owner});

  @override
  State<EditPetInfo> createState() => _EditPetInfo();
}

class _EditPetInfo extends State<EditPetInfo> {
  TextEditingController _petName = TextEditingController();
  File? imageFile;

  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  var selectedGender;
  var selectedGenderId;

  var selectedCategory;
  var selectedCategoryId;

  var selectedBreed;
  var selectedBreedId;

  var selectdColor;
  var selectdColorId;

  var selectedAge;
  var selectedAgeId;

  var currentImage;

  bool _isloading = false;

  List<dynamic> petCategories = [];
  List<dynamic> petBreeds = [];
  List<dynamic> petGenders = [];
  List<dynamic> petAges = [];
  List<dynamic> petColors = [];
  // List<dynamic> petWeights = [];
  //
  List<dynamic> breedsList = [];

  late var petName;
  late var petGender;
  late var petCategory;
  late var petBreed;
  late var petColor;
  late var petAge;
  late var PetImage;

  //

  final _auth = FirebaseAuth.instance;
  late User siginUser;

  void getData() async {
    try {
      final _user = _auth.currentUser;
      if (_user != null) {
        siginUser = _user;
        final DocumentSnapshot petInfo = await FirebaseFirestore.instance
            .collection('pets')
            .doc(widget.petId)
            .get();

        setState(() {
          petName = petInfo.get("petName");
          petGender = petInfo.get("gender");
          petCategory = petInfo.get("category");
          petAge = petInfo.get('age');
          petBreed = petInfo.get("breed");
          petColor = petInfo.get("color");
          PetImage = petInfo.get("image");
          currentImage = PetImage;
          _petName.text = petName;
          selectedCategory = petCategory;
          if (selectedCategory.toString() == "????") selectedCategoryId = 1;
          if (selectedCategory.toString() == "??????") selectedCategoryId = 2;

          if (selectedCategoryId == 1) {
            petBreeds.forEach((breeds) {
              if (breeds["parentId"] == 1)
                breedsList.add({"id": breeds["id"], "breed": breeds["breed"]});
            });
          }
          if (selectedCategoryId == 2) {
            petBreeds.forEach((breeds) {
              if (breeds["parentId"] == 2)
                breedsList.add({"id": breeds["id"], "breed": breeds["breed"]});
            });
          }
          selectedBreed = petBreed;
          petBreeds.forEach((br) {
            if (br["breed"] == selectedBreed) selectedBreedId = br["id"];
          });
          selectedAge = petAge;
          petAges.forEach((ag) {
            if (ag["age"] == selectedAge) selectedAgeId = ag["id"];
          });

          selectdColor = petColor;
          petColors.forEach((co) {
            if (co["color"] == selectdColor) selectdColorId = co["id"];
          });
          selectedGender = petGender;

          if (selectedGender.toString() == "??????") selectedGenderId = 1;
          if (selectedGender.toString() == "????????") selectedGenderId = 2;
          _isloading = true;
        });
      }
    } catch (error) {
      setState(() {
        _isloading = false;
      });
    }
  }

  //--------------section ------------------------------------
  Widget buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.only(left: 26, right: 26),
      alignment: Alignment.topRight,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Style.black,
          fontSize: 24,
          fontFamily: 'ElMessiri',
        ),
      ),
    );
  }

  //--------------uploade image from camera------------------------------------
  void pickImageCamera() async {
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxWidth: 1000, maxHeight: 1000);
    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  //--------------uploade image from gallery------------------------------------
  void pickImageGallery() async {
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000);
    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  //--------------uploade images------------------------------------
  uploadeImage(context) {
    showDialog(
        context: context,
        builder: (contex) {
          return AlertDialog(
            title: Text(
              "?????????? ???????? ???? ",
              style: TextStyle(color: Style.buttonColor_pink),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              InkWell(
                onTap: pickImageCamera,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Style.purpole,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "????????????",
                        style: TextStyle(color: Style.purpole),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: pickImageGallery,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Style.purpole,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "???????? ??????????",
                        style: TextStyle(color: Style.purpole),
                      )
                    ],
                  ),
                ),
              )
            ]),
          );
        });
  }

  //--------------initState------------------------------------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();

    this.petGenders.add({"id": 1, "gender": "??????"});
    this.petGenders.add({"id": 2, "gender": "????????"});
    this.petCategories.add({"id": 1, "type": "????"});
    this.petCategories.add({"id": 2, "type": "??????"});
    this.petBreeds = [
      {"id": 1, "breed": "??????????????", "parentId": 1},
      {"id": 2, "breed": "????????????????", "parentId": 1},
      {"id": 3, "breed": "????????????????????", "parentId": 1},
      {"id": 4, "breed": "?????????? ????????", "parentId": 1},
      {"id": 5, "breed": "????????", "parentId": 1},
      {"id": 1, "breed": "????????", "parentId": 2},
      {"id": 2, "breed": "??????????????", "parentId": 2},
      {"id": 3, "breed": "????????????", "parentId": 2},
      {"id": 4, "breed": "????????????", "parentId": 2},
      {"id": 5, "breed": "????????", "parentId": 2},
    ];
    this.petAges = [
      {"id": 1, "age": "??????"},
      {"id": 2, "age": "????????"},
      {"id": 3, "age": "????????"},
    ];
    this.petColors = [
      {"id": 1, "color": "????????"},
      {"id": 2, "color": "????????"},
      {"id": 3, "color": "??????"},
      {"id": 4, "color": "??????????????"},
      {"id": 5, "color": "??????????"},
      {"id": 6, "color": "??????????"},
    ];
  }

  //------show error massage---
  void _showErrorDialog(error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('??????'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, '????????'),
              child: const Text(
                '????????',
                style: TextStyle(
                    color: Color.fromRGBO(116, 98, 133, 1), fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent, //transparent
              elevation: 0.0,
              iconTheme: IconThemeData(color: Style.black, size: 28),
              toolbarHeight: 75,
              title: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.only(left: 20),
                    icon: Icon(
                      Icons.person_sharp,
                      size: 30,
                    ),
                    onPressed: () {
                      if (_auth.currentUser == null) {
                        Navigator.pushNamed(context, Register.screenRoute);
                      } else {
                        Navigator.pushNamed(context, ProfilePage.screenRoute);
                      }
                    },
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/logo.png",
                        height: 35,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "??????????",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                    icon: Icon(
                      Icons.arrow_forward_sharp,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ]),
          drawer: listView(),
          body: !_isloading
              ? Center(
                  child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 155, 140, 181)),
                        backgroundColor: Style.purpole,
                      )),
                )
              : Column(children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true, // use it
                      scrollDirection: Axis.vertical,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        buildSectionTitle(context, "?????????????? ????????"),

                        Container(
                          margin:
                              EdgeInsets.only(bottom: 26, left: 26, right: 26),
                          alignment: Alignment.center,
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Style.textFieldsColor_lightpink,
                          ),
                          child: imageFile == null
                              ? Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                            child: Image.network(
                                          currentImage!,
                                          fit: BoxFit.fill,
                                        )),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          uploadeImage(context);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Style.buttonColor_pink,
                                                border: Border.all(
                                                  width: 2,
                                                  color: Style.buttonColor_pink,
                                                ),
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 25,
                                            )),
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      bottom: 0,
                                      left: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                            child: Image.file(
                                          imageFile!,
                                          fit: BoxFit.fill,
                                        )),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          uploadeImage(context);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Style.buttonColor_pink,
                                                border: Border.all(
                                                  width: 2,
                                                  color: Style.buttonColor_pink,
                                                ),
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 25,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Form(
                          key: formState,
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: FileldsAdd2(
                                "???????? ?????? ??????????????/?????? ????????????",
                                _petName,
                                TextInputType.text,
                                (_petName) {
                                  if (!_petName.toString().isEmpty) {
                                    if (!RegExp(
                                            r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z-_ ]+$')
                                        .hasMatch(_petName
                                            .toString()
                                            .toLowerCase())) {
                                      return "???????????? ?????????? ?????? ?????? ?????????? ?????? ????????";
                                    }
                                  }

                                  return null;
                                },
                                1,
                                10,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "??????????",
                                  style: TextStyle(
                                    color: Style.black,
                                    fontSize: 19,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: RadioListTile(
                                      activeColor: Style.purpole,
                                      contentPadding: EdgeInsets.all(0),
                                      tileColor: Colors.purple.shade50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      value: "??????",
                                      groupValue: selectedGender,
                                      title: Text("??????"),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                          selectedGenderId = 1;
                                        });
                                      }),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: RadioListTile(
                                      activeColor: Style.purpole,
                                      contentPadding: EdgeInsets.all(0),
                                      tileColor: Colors.purple.shade50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      value: "????????",
                                      groupValue: selectedGender,
                                      title: Text("????????"),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                          selectedGenderId = 2;
                                        });
                                      }),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FormHelper.dropDownWidget(
                              context,
                              selectedCategory!,
                              selectedCategoryId,
                              this.petCategories,
                              (type) {
                                setState(() {
                                  selectedCategoryId = type;
                                  breedsList = this
                                      .petBreeds
                                      .where((breeds) =>
                                          breeds["parentId"].toString() ==
                                          type.toString())
                                      .toList();
                                  selectedBreed = "??????????????";
                                  selectedBreedId = null;

                                  petCategories.forEach((c) {
                                    if (c["id"].toString() ==
                                        selectedCategoryId)
                                      selectedCategory = c["type"].toString();
                                  });
                                });
                              },
                              (value) {},
                              optionValue: "id",
                              optionLabel: "type",
                              borderColor: Style.gray,
                              borderFocusColor: Style.gray,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            //--------------Breeds-----------------------------------
                            FormHelper.dropDownWidget(
                              context,
                              selectedBreed!,
                              this.selectedBreedId,
                              this.breedsList,
                              (breed) {
                                setState(() {
                                  selectedBreedId = breed;
                                  breedsList.forEach((b) {
                                    if (b["id"].toString() == selectedBreedId)
                                      selectedBreed = b["breed"].toString();
                                  });
                                });
                              },
                              (value) {
                                if (selectedBreed == "??????????????") {
                                  if (value == null) {
                                    return " ???? ??????????????????";
                                  }
                                }
                              },
                              optionValue: "id",
                              optionLabel: "breed",
                              borderColor: Style.gray,
                              borderFocusColor: Style.purpole,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            //--------------colors-----------------------------------
                            FormHelper.dropDownWidget(
                              context,
                              selectdColor!,
                              this.selectdColorId,
                              this.petColors,
                              (Color) {
                                setState(() {
                                  selectdColorId = Color;

                                  petColors.forEach((c) {
                                    if (c["id"].toString() == selectdColorId)
                                      selectdColor = c["color"].toString();
                                  });
                                });
                              },
                              (value) {},
                              optionValue: "id",
                              optionLabel: "color",
                              borderColor: Style.gray,
                              borderFocusColor: Style.purpole,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            FormHelper.dropDownWidget(
                              context,
                              selectedAge!,
                              this.selectedAgeId,
                              this.petAges,
                              (age) {
                                setState(() {
                                  selectedAgeId = age;
                                  petAges.forEach((a) {
                                    if (a["id"].toString() == selectedAgeId)
                                      selectedAge = a["age"].toString();
                                  });
                                });
                              },
                              (value) {},
                              optionValue: "id",
                              optionLabel: "age",
                              borderColor: Style.gray,
                              borderFocusColor: Style.purpole,
                            ),
                          ]),
                        ),
                        //=======================================
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: MyButton(
                            color: Style.buttonColor_pink,
                            title: "????????????",
                            onPeressed: () {
                              if (formState.currentState!.validate()) {
                                var petimage;

                                if (imageFile == null)
                                  petimage = currentImage;
                                else if (imageFile != null)
                                  petimage = imageFile;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContinuesEdit(
                                      petId: widget.petId,
                                      name: _petName.text,
                                      gender: selectedGender,
                                      type: selectedCategory,
                                      breed: selectedBreed,
                                      age: selectedAge,
                                      color: selectdColor,
                                      image: petimage,
                                    ),
                                  ),
                                );
                              } else {
                                _showErrorDialog("???? ???????????? ???????? ??????????????????");
                              }
                            },
                            minwidth: 500,
                            circular: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
    );
  }
}
