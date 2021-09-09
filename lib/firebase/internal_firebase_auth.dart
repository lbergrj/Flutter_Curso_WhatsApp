
import 'package:firebase_auth/firebase_auth.dart';

class InternalFirebaseAuth{

  static Future<FirebaseUser> checkLogedUser() async{
    FirebaseAuth auth =  FirebaseAuth.instance;
    return  await auth .currentUser();
  }

}