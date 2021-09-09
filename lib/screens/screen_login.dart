import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/model_usuario.dart';
import 'package:whatsapp/screens/screen_cadastro.dart';
import 'package:whatsapp/screens/screen_home.dart';

class ScreenLogin extends StatefulWidget {
  FirebaseUser usuarioLogado;

  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {

  TextEditingController _controllerEMail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validar(){
    String email = _controllerEMail.text;
    String senha = _controllerSenha.text;

    if(email.length > 4 && email.contains("@") && email.contains(".")){
      if(senha.length > 0){
        setState(() {
          _mensagemErro = "";
        });
        Usuario usuario = Usuario.login(email,senha);
         _loginUsuario(usuario);
      }
      else{
        setState(() {
          _mensagemErro = "Preencha a senha";
        });
      }
    }
    else{
      setState(() {
        _mensagemErro = "Preencha um email válido";
      });
    }
  }

  _loginUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser){
      Navigator.pushReplacementNamed(context,"/home");
    }).catchError((onError){
      setState(() {
        _mensagemErro = "Erro, verifique usuário e senha";
      });
    });
  }

  Future _checkLogedUser() async{
    FirebaseAuth auth =  FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth .currentUser();
    if(usuarioLogado != null){
      print(usuarioLogado.email.toString());
      Navigator.pushReplacementNamed(context,"/home");
    }
  }

  @override
  void initState() {
    _checkLogedUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                  child: Image.asset("images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding (
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEMail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  keyboardType: TextInputType.text,
                  obscureText: true,
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
                    child: Text("Entrar",
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
                  child: GestureDetector(
                    child: Text(  "Cadastre-se",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScreenCadastro(),
                            ),
                        );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:10),
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
