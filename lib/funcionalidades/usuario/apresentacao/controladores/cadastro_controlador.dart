import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../recursos/erros/falhas.dart';

class CadastroControlador extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  bool carregando = false;
  Falha? falha;

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (nome.isEmpty) {
      falha = FalhaDeValidacao.campoVazio("nome");
      notifyListeners();
      return false;
    }
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
    if (senha.length < 6) {
      falha = FalhaDeValidacao.generica("A senha deve ter pelo menos 6 caracteres.");
      notifyListeners();
      return false;
    }
    try {
      carregando = true;
      falha = null;
      notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        'nome': nome,
        'email': email,
        'nivel': null,
        'criadoEm': DateTime.now(),
      });
      carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      carregando = false;
      falha = FalhaDeCadastro.fromCode(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      carregando = false;
      falha = const FalhaGeral(mensagem: "Erro inesperado no cadastro.");
      notifyListeners();
      return false;
    }
  }
  String? get mensagemErro => falha?.mensagem;
}