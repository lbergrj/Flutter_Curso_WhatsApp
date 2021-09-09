import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/firebase/internal_firebase_firestore.dart';
import 'package:whatsapp/model/model_usuario.dart';
import '../model/model_conversa.dart';
class AbaConversas extends StatefulWidget {
  String _idUsuario;
  String _emailUsuario;
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  InternalFirebaseFirestore db = InternalFirebaseFirestore();
  //controlador do Stream
  final _controller = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot>_addListenerConversas(){
    final stream = db.buscarConversas(widget._emailUsuario);
    stream.listen((dados) {
        _controller.add(dados);
    });
  }

  _getLogedUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    widget._idUsuario = user.uid;
    widget._emailUsuario = user.email;
    _addListenerConversas();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLogedUser();
  }
  @override
   void dispose(){
    super.dispose();
    _controller.close();

  }

  //Exibe conversas Recuperadas
  Widget _mostarConversas(QuerySnapshot querySnapshot){

    List<DocumentSnapshot>  conversas = querySnapshot.documents.toList();
    return ListView.builder(
        itemCount:conversas.length,
        itemBuilder:(context,index){
          DocumentSnapshot item = conversas[index];

          return ListTile(
            onTap: ()async{
              Usuario usuario = await db.getUser(item["emailDestinatario"]);
              print(usuario.idUsuario);
              Navigator.pushNamed(context, "/mensagens",arguments: usuario);

            },
            contentPadding: EdgeInsets.fromLTRB(16,8,16,8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: item["urlFoto"] != null && item["urlFoto"] != ""
              ? NetworkImage( item["urlFoto"])
              : null,
            ),
            title: Text(
               item["nome"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              item["tipoMensagem"] == "texto"
              ? item["mensagem"]
              : "Imagem...",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          );
        }
    );
  }

  //Recupera conversas
  Widget listarConversas(){
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot){
      switch (snapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.waiting:
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Loading Conversas"),
                CircularProgressIndicator(),
              ],
            ),
          );
          break;
        case ConnectionState.active:
        case ConnectionState.done:

          if (snapshot.hasError) {
            return Text("Erro ao carregar dados");
          }
          else {
            QuerySnapshot querySnapshot = snapshot.data;
            if( querySnapshot.documents.length == 0){
              return Center(
                child: Text(
                  "Você não tem conversas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return _mostarConversas(querySnapshot);
          }
        }; //Fim do Switch
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return listarConversas();
  }
}

