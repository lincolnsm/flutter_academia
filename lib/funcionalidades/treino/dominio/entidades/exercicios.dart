class Exercicio {
  final String nome;
  final String imagem;
  final String tipoEquipamento;
  final String? linkYoutube;
  final List<String> tags;

  Exercicio({
    required this.nome,
    required this.imagem,
    required this.tipoEquipamento,
    this.linkYoutube,
    this.tags = const [],
  });
}