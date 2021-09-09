import 'model_mensagem.dart';
import 'model_usuario.dart';

class Conversa{
  String _emailRemetente;
  String _emailDestinatario;
  String _nome;
  String _mensagem;
  String _urlFotoPerfil;
  String _tipo;

  Conversa({ String emailRemetente, String emailDestinatario, String nome,
        String mensagem, String urlFotoPerfil, String tipo }){
    this.emailRemetente = emailRemetente;
    this._emailDestinatario = emailDestinatario;
    this._nome =  nome;
    this._mensagem =  mensagem;
    this._urlFotoPerfil =  urlFotoPerfil;
    this._tipo = tipo;
  }

  Conversa.fromMensagem(Mensagem msg, Usuario usuario ){
    this.emailRemetente = msg.idUsuario;
    this._emailDestinatario = msg.idDestinatario;
    this._nome =  usuario.nome;
    this._mensagem =  msg.mensagem;
    this._urlFotoPerfil =  usuario.urlImagem;
    this._tipo = msg.tipo;
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = {
    "emailRemetente" : this._emailRemetente,
    "emailDestinatario": this._emailDestinatario,
     "nome" :this._nome,
    "mensagem" :  this._mensagem,
    "urlFoto" : this._urlFotoPerfil,
    "tipoMensagem" : this._tipo };

    return map;
  }

  String get emailRemetente => _emailRemetente;

  set emailRemetente(String value) {
    _emailRemetente = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }


  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get urlFotoPerfil=> _urlFotoPerfil;

  set urlFotoPerfil(String value) {
    _urlFotoPerfil = value;
  }

  String get emailDestinatario => _emailDestinatario;

  set emailDestinatario(String value) {
    _emailDestinatario = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }
}