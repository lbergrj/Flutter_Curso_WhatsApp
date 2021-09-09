import 'package:flutter/material.dart';
import 'package:whatsapp/screens/screen_cadastro.dart';
import 'package:whatsapp/screens/screen_configuracoes.dart';
import 'package:whatsapp/screens/screen_home.dart';
import 'package:whatsapp/screens/screen_login.dart';
import 'package:whatsapp/screens/screen_mensagens.dart';

class RouteGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(
          builder: (_) => ScreenHome(),
        );
      case "/login":
        return MaterialPageRoute(
          builder: (_) => ScreenLogin(),
        );
      case "/cadastro":
        return MaterialPageRoute(
          builder: (_) => ScreenCadastro(),
        );
      case "/home":
        return MaterialPageRoute(
          builder: (_) => ScreenHome(),
        );
      case "/configuracoes":
        return MaterialPageRoute(
          builder: (_) => ScreenConfiguracoes(),
        );
      case "/mensagens":
        return MaterialPageRoute(
          builder: (_) => ScreenMensagens(args),
        );
      default:
        _erroRota();

    }
  }
  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada"),
          ),
          body: Center(
            child:  Text("Tela não encontrada"),
          ),
        );
      },
    );
  }

}
