import '../../dominio/entidades/exercicios.dart';
import '../../dados/repositorios/exercicios_data.dart' as repo;

class Treino {
  final String titulo;
  final bool botaoEscuro;
  final String? linkYoutube;
  final List<Exercicio> exercicios;

  Treino({
    required this.titulo,
    required this.botaoEscuro,
    this.linkYoutube,
    required this.exercicios,
  });

  factory Treino.fromTag({
    required String titulo,
    required bool botaoEscuro,
    String? linkYoutube,
    required String tag,
  }) {
    final listaFiltrada = repo.exercicios.where((e) => e.tags.contains(tag)).toList();
    return Treino(
      titulo: titulo,
      botaoEscuro: botaoEscuro,
      linkYoutube: linkYoutube,
      exercicios: listaFiltrada,
    );
  }
}
