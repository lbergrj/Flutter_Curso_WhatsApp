import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:whatsapp/firebase/internal_firebase_auth.dart';

class ScreenConfiguracoes extends StatefulWidget {
  @override
  _ScreenConfiguracoesState createState() => _ScreenConfiguracoesState();
}

class _ScreenConfiguracoesState extends State<ScreenConfiguracoes> {

  TextEditingController _controllerNome = TextEditingController();
  File _imagem;
  String _pathImage = "https://firebasestorage.googleapis.com/v0/b/whatsapp-66b58.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=d36cd655-4350-4d03-a0db-8265b7343631";
  FirebaseUser usuarioLogado;
  bool _uploadingImage = false;
  String _urlRecuperada;

  Future _getImage( String origem) async{
    File imagemSelecionada;

    switch (origem){
      case "camera" :
        imagemSelecionada = await ImagePicker.pickImage(
            source: ImageSource.camera
        );
        break;
      case "galeria" :
        imagemSelecionada = await ImagePicker.pickImage(
            source: ImageSource.gallery
        );
        break;
    }
    setState(() {

      _imagem = imagemSelecionada;
      if(_imagem != null){
        _uploadingImage = true;
        _uploadImage();
      }
    });


  }
  setUser() async{
    usuarioLogado = await InternalFirebaseAuth.checkLogedUser();
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
        .document(usuarioLogado.uid)
        .get();
    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text = dados["nome"];
    setState(() {
      if(dados["urlImagem"] != null){
        _urlRecuperada = dados["urlImagem"];
      }
    });
    print(dados["urlImagem"]);

  }

  Future _uploadImage() async{

    FirebaseStorage storage = await FirebaseStorage.instance;
    StorageReference ref = storage.ref();
    StorageReference file = ref
      .child("perfil")
      .child("profile_${usuarioLogado.uid}.jpg");

    StorageUploadTask task = file.putFile(_imagem);

    task.events.listen((StorageTaskEvent storageEvent ){
      if(storageEvent.type == StorageTaskEventType.failure){
        setState(() {
          _uploadingImage = false;
          print ("Falha no upload");
        });
      }

      else if(storageEvent.type == StorageTaskEventType.progress){
        setState(() {
          _uploadingImage = true;
          print ("Fazendo no upload");
        });
      }

      else if(storageEvent.type == StorageTaskEventType.success){
        setState(() {
          _uploadingImage = false;
          print ("Upload Concluido");
        });
      }

    });

    task.events.listen((StorageTaskEvent storageEvent){
      if(storageEvent == StorageTaskEventType.progress ){
        setState(() {

          _uploadingImage = true;
        });
      }

      else if(storageEvent == StorageTaskEventType.success ){

        setState(() {
          _uploadingImage = false;
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _getUrlImage(snapshot);
    });

  }

  Future  _getUrlImage(StorageTaskSnapshot snapshot) async{
    String url = await snapshot.ref.getDownloadURL();
    _updateImageUrl(url);
    setState(() {
      _urlRecuperada = url;
    });

  }

  _updateImageUrl( String url){
    Firestore db = Firestore.instance;
    db.collection("usuarios")
    .document(usuarioLogado.uid)
    .updateData({"urlImagem" : url});
    
  }
  _updateName(nome){
    Firestore db = Firestore.instance;
    db.collection("usuarios")
        .document(usuarioLogado.uid)
        .updateData({"nome" : nome});

  }

  _getUserData() async{
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
      .document(usuarioLogado.uid)
      .get();
    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text = dados["nome"];
    if(dados["urlImagem" ] != null){
      _urlRecuperada = dados["urlImagem"];
    }



  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUser();



  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
       child: Center(
         child: SingleChildScrollView(
           child: Column(

             children: <Widget>[
               //Carregando
               Container(
                 padding:EdgeInsets.all(16) ,
                 child: _uploadingImage
                     ? CircularProgressIndicator()
                     : Container(),
               ),
               CircleAvatar(
                 radius: 100,
                 backgroundColor: Colors.grey[300],
                 backgroundImage:
                  _urlRecuperada != null
                   ? NetworkImage (_urlRecuperada)
                   : null,

               ),
               Row(

                 mainAxisAlignment: MainAxisAlignment.center ,
                 children: <Widget>[
                   FlatButton(
                     child: Text("Câmera",
                       style: TextStyle(
                         fontSize: 20
                       ),
                     ),
                     onPressed: (){
                       _getImage("camera");
                     },
                   ),

                   FlatButton(
                     child: Text("Galeria",
                       style: TextStyle(
                           fontSize: 20
                       ),
                     ),
                     onPressed: (){
                       _getImage("galeria");
                     },
                   ),
                 ],
               ),
               Padding (
                 padding: EdgeInsets.only(bottom: 8),
                 child: TextField(
                   controller: _controllerNome,
                   autofocus: true,
                   keyboardType: TextInputType.text,
                   style: TextStyle(
                     fontSize: 20,
                   ),


                   onChanged: (nome){
                     _updateName(nome);
                   },


                   decoration: InputDecoration(
                     contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                     hintText: "Nome",
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(32)
                     ),
                   ),
                 ),
               ),


               Padding(
                 padding: EdgeInsets.only(top:16, bottom: 10),

                 child: RaisedButton(

                   child: Text("Salvar",
                     style: TextStyle(
                         color: Colors.white,
                         fontSize: 20
                     ),
                   ),
                   color: Colors.green,
                   padding: EdgeInsets.fromLTRB(64, 16, 64, 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(32),
                   ),
                   onPressed: (){
                     _updateName(_controllerNome.text);
                   },
                 ),
               ),
             ]
           ),
         ),
       ),
      ),
    );
  }
}

