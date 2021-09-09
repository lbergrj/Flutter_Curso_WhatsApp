
class Usuario{
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;
  String _urlImagem;



  Usuario(this._nome,this._email, this._senha);

  Usuario.vazio(){
    this._idUsuario ="";
    this._nome = "";
    this._email ="";
    this._senha = "";
    this.urlImagem = "";
  }

  Usuario.conversa(this._idUsuario, this._nome,this._urlImagem);

  Usuario.fromMap(Map map){
    this._nome = map["nome"];
    this._email = map["email"];
    this._urlImagem = map["urlImagem"];
  }

  Usuario.login(this._email, this._senha);

  Map<String,dynamic> toMap(){
    return {
      "nome" : this._nome,
      "email" : this.email
    };
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

}