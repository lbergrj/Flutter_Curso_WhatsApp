class Mensagem {

  String _idUsuario;
  String _idDestinatario;
  String _mensagem = "";
  String _urlImagem ="";
  String _tipo;
  String _dataTime;//pode ser texto vou foto



  Mensagem({String idUsuario,
    String idDestinatario,
    String tipo,
    String dataTime
    }){
    this._idUsuario = idUsuario;
    this._idDestinatario = idDestinatario;
    this._tipo = tipo;
    this._dataTime = dataTime;


  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idUsuario" : this._idUsuario,
      "mensagem" : this._mensagem,
      "tipo" : this._tipo,
      "urlImagem" : this._urlImagem,
      "dateTime" : this._dataTime,
    };
    return map;
  }


  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }
  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }


  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }




}