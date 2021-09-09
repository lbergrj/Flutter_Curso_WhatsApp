import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/firebase/internal_firebase_auth.dart';
import 'package:whatsapp/model/model_conversa.dart';
import 'package:whatsapp/model/model_mensagem.dart';
import '../model/model_usuario.dart';

class InternalFirebaseFirestore{
  Firestore _db = Firestore.instance;


  Future<List<Usuario>> getListUsers() async{
    //Verifica o Usuario Logado
    FirebaseUser user  = await InternalFirebaseAuth.checkLogedUser();

    QuerySnapshot querySnapshot = await _db.collection("usuarios")
        .getDocuments();
    List<Usuario> usuarios = List();
    for(DocumentSnapshot item in querySnapshot.documents){
       var dados = item.data;
       Usuario usuario = Usuario.fromMap(dados);
       usuario.idUsuario = item.documentID;
       //Não insere o Usuário Logado na Lista de contatos
       if (user.email != usuario.email){
         usuarios.add(usuario);
       }
    }
    return usuarios;
  }

  Future<Usuario> getUser(String email) async{
    QuerySnapshot querySnapshot = await _db.collection("usuarios")
        .where("email", isEqualTo: email)
        .getDocuments();
      if(querySnapshot.documents.isNotEmpty){
        DocumentSnapshot item  = querySnapshot.documents[0];
        var dados = item.data;
        Usuario usuario = Usuario.fromMap(dados);
        usuario.idUsuario = item.documentID;
        return usuario;
      }
      else{
        return null;
      }

  }



  salvarMensagem( Mensagem mensagem, Usuario usuario) async{

    await _db.collection("mensagens")
        .document(mensagem.idUsuario)
        .collection(mensagem.idDestinatario)
        .add(mensagem.toMap());
    await _db.collection("mensagens")
        .document(mensagem.idDestinatario)
        .collection(mensagem.idUsuario)
        .add(mensagem.toMap());
    Conversa conversa = Conversa.fromMensagem(mensagem, usuario);


  }

  salvarConversa (Conversa conversa) async {
    await _db.collection("conversas")
        .document(conversa.emailRemetente)
        .collection("ultima_conversa")
        .document(conversa.emailDestinatario)
        .setData(conversa.toMap());
  }

  Stream<dynamic> buscarMensagens(String idUsuario, String idDestinatario)  {
    var saida =  _db.collection("mensagens")
        .document(idUsuario)
        .collection(idDestinatario)
        .orderBy("dateTime", descending: false)
        .snapshots();
     return saida;
  }

  Stream<dynamic> buscarMensagem(String idUsuario, String idDestinatario)  {
    var saida =  _db.collection("mensagens")
        .document(idUsuario)
        .collection(idDestinatario)
        .orderBy("dateTime", descending: false)
        .limit(1)
        .snapshots();
    return saida;
  }

  Stream<dynamic> buscarConversas(String emailUsuario)  {
    var saida =  _db.collection("conversas")
        .document(emailUsuario)
        .collection("ultima_conversa")
        .snapshots();
    return saida;
  }

}








