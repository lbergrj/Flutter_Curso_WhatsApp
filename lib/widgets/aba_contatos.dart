import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/firebase/internal_firebase_firestore.dart';
import '../model/model_conversa.dart';
import '../model/model_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {

  Future<List<Usuario>> _recoverContatos() async{
      InternalFirebaseFirestore db = new InternalFirebaseFirestore();
      return await db.getListUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recoverContatos(),
      builder: (context, snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading Contatos"),
                  CircularProgressIndicator(
                  ),

                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context,index){
                List<Usuario> listaItens = snapshot.data;
                Usuario usuario = listaItens[index];
                return ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/mensagens",
                      arguments: usuario,
                    );
                  },
                  contentPadding: EdgeInsets.fromLTRB(16,8,16,8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                    usuario.urlImagem != null
                    ? NetworkImage(usuario.urlImagem)
                    : null,
                  ),
                  title: Text(usuario.nome,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),

                  ),
                );
              },
            );
            break;
        }
      },
    );
  }
}
