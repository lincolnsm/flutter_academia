import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../recursos/erros/falhas.dart';

class LoginControlador extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool carregando = false;
  Falha? falha;

  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    if (email.isEmpty) {
      falha = FalhaDeValidacao.campoVazio("e-mail");
      notifyListeners();
      return false;
    }
    if (senha.isEmpty) {
      falha = FalhaDeValidacao.campoVazio("senha");
      notifyListeners();
      return false;
    }
    try {
      carregando = true;
      falha = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      carregando = false;

      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code == 'user-not-found' || msg.contains('user not found')) {
        falha = FalhaDeLogin.credenciaisInvalidas();
      } else if (code == 'wrong-password' || msg.contains('wrong password')) {
        falha = FalhaDeLogin.credenciaisInvalidas();
      } else if (code == 'invalid-email' || msg.contains('invalid email')) {
        falha = FalhaDeLogin.fromCode('invalid-email');
      } else if (code == 'user-disabled' || msg.contains('disabled')) {
        falha = FalhaDeLogin.fromCode('user-disabled');
      } else {
        falha = FalhaDeLogin.fromCode(code);
      }
      notifyListeners();
      return false;
    } catch (_) {
      carregando = false;
      falha = const FalhaGeral(mensagem: "Erro inesperado no login.");
      notifyListeners();
      return false;
    }
  }
}