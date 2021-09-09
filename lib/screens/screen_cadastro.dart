import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/model/model_usuario.dart';
import 'package:whatsapp/screens/screen_home.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class ScreenCadastro extends StatefulWidget {
  @override
  _ScreenCadastroState createState() => _ScreenCadastroState();
}

class _ScreenCadastroState extends State<ScreenCadastro> {
  //Controladores
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEMail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  String _mensagemErro = "";

  _validar(){
    String nome = _controllerNome.text;
    String email = _controllerEMail.text;
    String senha = _controllerSenha.text;

    if(nome.length > 4){

      if(email.length > 4 && email.contains("@") && email.contains(".")){

        if(senha.length > 4){
            setState(() {
              _mensagemErro = "OK ";
            });
             Usuario usuario = Usuario(nome,email,senha);
            _cadastrarUsuario(usuario);
        }
        else{
          setState(() {
            _mensagemErro = "Senha deve ter ao menos 5 caractéres";
          });
        }

      }
      else{
        setState(() {
          _mensagemErro = "Digite um email válido";
        });
      }
    }
    else{
      setState(() {
        _mensagemErro = "Nome deve ter ao menos 5 caractéres";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario){
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.createUserWithEmailAndPassword(
          email: usuario.email,
          password:usuario.senha,
      ).then((firebaseUser){

        //Salvar dados do usuario

        Firestore db = Firestore.instance;
        db.collection("usuarios")
        .document(firebaseUser.uid)
        .setData(usuario.toMap());

        //Eanviar para a tela principal
        //Navigator.pushReplacementNamed(context, "/home");
        Navigator.pushNamedAndRemoveUntil(context, "/home",(_) => false);

      }).catchError((onError){
        setState(() {
          _mensagemErro = "Erro cadastrar usuário";
        });
      });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text("Cadastro"),
        ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff075e54),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset("images/usuario.png",
                    width: 200,
                    height: 150,
                  ),
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

                Padding (
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEMail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:16, bottom: 10),
                  child: RaisedButton(
                    child: Text("Cadastar",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    onPressed: (){
                      _validar();
                    },
                  ),
                ),
                Center(
                  child: Text(_mensagemErro,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

