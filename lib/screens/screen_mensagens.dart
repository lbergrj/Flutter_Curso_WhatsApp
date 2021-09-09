import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:whatsapp/firebase/internal_firebase_firestore.dart';
import 'package:whatsapp/model/model_mensagem.dart';
import '../model/model_usuario.dart';
import '../model/model_conversa.dart';

class ScreenMensagens extends StatefulWidget {
  Usuario contato;
  String idUsuario;
  String emailUsuario;
  Usuario usuarioLogado;



  ScreenMensagens(this.contato);
  @override
  _ScreenMensagensState createState() => _ScreenMensagensState();
}

class _ScreenMensagensState extends State<ScreenMensagens> {
  InternalFirebaseFirestore db = InternalFirebaseFirestore();
  TextEditingController _controllerMessage = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  //File _imagem;
  bool _uploadingImage = false;
  ScrollController _scrollController = ScrollController();



  _getLogedId() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser = await auth.currentUser();
  widget.idUsuario = firebaseUser.uid;
  widget.emailUsuario = firebaseUser.email;

  }

  Stream<QuerySnapshot>_addListenerConversas(){
    final stream = db.buscarMensagens(widget.idUsuario, widget.contato.idUsuario);
    stream.listen((dados) {
      _controller.add(dados);
      //Depois do tempo chama uma função anônima
      Timer(Duration(seconds: 1),(){
        //maxScrollExtent vai para o final da lista do scroll
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  _getLogedUser()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    Usuario user = await db.getUser(firebaseUser.email);
    widget.usuarioLogado = user;
    _addListenerConversas();
  }

  _sendMessage() async {

    String textoMensagem = _controllerMessage.text;
    if (textoMensagem.isNotEmpty) {

      Mensagem mensagem = Mensagem(
          idUsuario: widget.idUsuario,
          idDestinatario: widget.contato.idUsuario,
          //A classe timestamp indica um momento único na linha temporal  temporal
          //dataTime: Timestamp.now().toString()
          dataTime: DateTime.now().toString(),
          tipo: "texto");
      mensagem.mensagem = textoMensagem;
      await db.salvarMensagem(mensagem, widget.contato);

      //Salva a conveersa para o Remetente
      Conversa conversaRemetente = Conversa(
        nome: "Me",
        emailDestinatario: widget.contato.email,
        emailRemetente: widget.emailUsuario,
        urlFotoPerfil:  widget.contato.urlImagem,
        tipo: mensagem.tipo,
        mensagem: mensagem.mensagem,
      );
      await db.salvarConversa(conversaRemetente);


      //Salva a conveersa para o Destinatário
      Conversa conversaDestinatario = Conversa(
        nome: widget.usuarioLogado.nome,
        emailDestinatario: widget.emailUsuario,
        emailRemetente:  widget.contato.email,
        urlFotoPerfil:  widget.usuarioLogado.urlImagem,
        tipo: mensagem.tipo,
        mensagem: mensagem.mensagem,
      );
      await db.salvarConversa(conversaDestinatario);

      _controllerMessage.clear();
    }
    else{

      print ("UserLogado " + widget.usuarioLogado.urlImagem);

    }
  }

  //Captura a foto da galeria
  _sendPhoto() async{
    File imagemSelecionada = await ImagePicker.pickImage(
        source: ImageSource.gallery);
    _uploadImage(imagemSelecionada);

  }

  Future _uploadImage(File imagem) async{
    //Faz o upload da foto
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = await FirebaseStorage.instance;
    StorageReference ref = storage.ref();
    StorageReference file = ref
        .child("mensagens")
        .child( widget.idUsuario)
        .child("${nomeImagem }.jpg");

    StorageUploadTask task = file.putFile(imagem);

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

    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent == StorageTaskEventType.progress) {
        setState(() {
          _uploadingImage = true;
        });
      }
    });
    //Retona a Url da foto
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _getUrlImage(snapshot);
    });
  }

  //Salva a Url da foto como mensagem no banco de dados
  Future  _getUrlImage(StorageTaskSnapshot snapshot) async{
    String url = await snapshot.ref.getDownloadURL();
    Mensagem mensagem = Mensagem(
        idUsuario:  widget.idUsuario,
        idDestinatario: widget.contato.idUsuario,
        dataTime: DateTime.now().toString(),
        tipo: "imagem");
    mensagem.urlImagem = url;
    mensagem.mensagem = "";
    db.salvarMensagem(mensagem,widget.contato);
  }

  Widget widgetCaixadeMensagem() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: TextField(
                controller: _controllerMessage,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                  hintText: "Digite a mensagem",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                  prefixIcon:
                  _uploadingImage == true
                  ? CircularProgressIndicator()
                  : IconButton( icon: Icon( Icons.camera_alt,),
                    onPressed: _sendPhoto,
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075e54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

   _streamBuilder() {
    return StreamBuilder(

        stream: db.buscarMensagens( widget.idUsuario, widget.contato.idUsuario),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Loading Mensagens"),
                    CircularProgressIndicator(),
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;
              if (snapshot.hasError) {
                return Expanded(
                  child: Text("Erro ao carregar dados"),
                );
              }
              else if(snapshot.data == null){
                return Expanded(
                  child: Text("Retorno nulo"),
                );
              }
              else {
                return Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, index) {
                     List<DocumentSnapshot>  mensagens = querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[index];
                      double largura = MediaQuery.of(context).size.width * 0.8;
                      return Align(
                        alignment:  widget.idUsuario == item["idUsuario"]
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: largura,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color:  widget.idUsuario == item["idUsuario"]
                                    ? Color(0xffd2ffa5)
                                    : Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                )),
                            child:
                            item["tipo"] == "texto"
                            ? Text(
                              item["mensagem"],
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                            : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              break;
          }
        });
  }



  @override
  void initState() {
    // TODO: implement initState
    _getLogedId();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    _getLogedUser();
    String nome = widget.contato.nome;
    String urlImagem = widget.contato.urlImagem;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    urlImagem != null ? NetworkImage(urlImagem) : null,
              ),
            ),
            Text("$nome"),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                //listview
                _streamBuilder(),
                //Caixa de mensagem
                widgetCaixadeMensagem(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
