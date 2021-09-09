import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/firebase/internal_firebase_auth.dart';
import '../widgets/aba_contatos.dart';
import '../widgets/aba_conversas.dart';
import 'dart:io';

class ScreenHome extends StatefulWidget {

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> intensMenu = ["Configurações", "Sair"];

  Future _LogedUser() async {
    FirebaseUser logedUser = await InternalFirebaseAuth.checkLogedUser();
    if (logedUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  _sair() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }


  _menuItemEscolhido(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        break;
      case "Sair":
        _sair();
        break;
    }
  }

  @override
  void initState() {
   _LogedUser();
    super.initState();
    // TODO: implement initState
      _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("WhatsApp"),
          elevation: Platform.isIOS
          ? 0
          : 4,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _menuItemEscolhido,
              itemBuilder: (context) {
                return intensMenu.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
            ),
          ],
          bottom: TabBar(
            indicatorWeight: 4,
            controller: _tabController,
            indicatorColor: Platform.isIOS
            ? Colors.grey[400]
            :Colors.white,
            labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
            tabs: <Widget>[
              Tab(text: "Conversas"),
              Tab(text: "Contatos"),
            ],
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            AbaConversas(),
            AbaContatos(),
          ],
        )
    );
  }
}
