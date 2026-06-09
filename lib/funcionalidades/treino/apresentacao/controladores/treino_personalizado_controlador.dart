import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dominio/entidades/treino_personalizado.dart';

class TreinoPersonalizadoControlador extends ChangeNotifier {
  TreinoPersonalizado? _treino;
  bool _carregando = false;
  bool _carregado = false;

  TreinoPersonalizado? get treino => _treino;
  bool get carregando => _carregando;
  bool get carregado => _carregado;
  bool get temTreino => _treino != null && _treino!.dias.isNotEmpty;

  Future<void> carregar() async {
    if (_carregado) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _carregando = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('treinos_personalizados')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        _treino = TreinoPersonalizado.fromMap(doc.data()!);
      }
    } catch (_) {}
    _carregando = false;
    _carregado = true;
    notifyListeners();
  }

  Future<bool> salvar(TreinoPersonalizado treino) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    _carregando = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('treinos_personalizados')
          .doc(uid)
          .set(treino.toMap());
      _treino = treino;
      _carregando = false;
      notifyListeners();
      return true;
    } catch (_) {
      _carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> excluir() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('treinos_personalizados')
          .doc(uid)
          .delete();
      _treino = null;
      _carregado = false;
      notifyListeners();
    } catch (_) {}
  }

  void resetar() {
    _treino = null;
    _carregado = false;
    notifyListeners();
  }
}
