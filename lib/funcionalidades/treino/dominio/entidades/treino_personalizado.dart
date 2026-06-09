import 'package:flutter/material.dart';

class GrupoMuscular {
  final String id;
  final String nome;
  final String descricao;
  final IconData icone;
  final String tagTreino;

  const GrupoMuscular({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.tagTreino,
  });

  static const List<GrupoMuscular> todos = [
    GrupoMuscular(
      id: 'peito',
      nome: 'Peito',
      descricao: 'Peito & Tríceps',
      icone: Icons.sports_gymnastics,
      tagTreino: 'treinoA',
    ),
    GrupoMuscular(
      id: 'costas',
      nome: 'Costas',
      descricao: 'Costas & Bíceps',
      icone: Icons.rowing,
      tagTreino: 'treinoB',
    ),
    GrupoMuscular(
      id: 'pernas',
      nome: 'Pernas',
      descricao: 'Quadríceps, Glúteos & Panturrilha',
      icone: Icons.directions_run,
      tagTreino: 'treinoC',
    ),
    GrupoMuscular(
      id: 'ombros',
      nome: 'Ombros',
      descricao: 'Deltóides & Trapézio',
      icone: Icons.accessibility_new,
      tagTreino: 'treinoD',
    ),
    GrupoMuscular(
      id: 'bracos',
      nome: 'Braços',
      descricao: 'Bíceps & Tríceps isolados',
      icone: Icons.sports_mma,
      tagTreino: 'treinoE',
    ),
    GrupoMuscular(
      id: 'upper',
      nome: 'Upper Body',
      descricao: 'Peito, Costas & Ombros',
      icone: Icons.fitness_center,
      tagTreino: 'upper',
    ),
    GrupoMuscular(
      id: 'lower',
      nome: 'Lower Body',
      descricao: 'Pernas & Glúteos',
      icone: Icons.directions_walk,
      tagTreino: 'lower',
    ),
    GrupoMuscular(
      id: 'fullbody',
      nome: 'Full Body',
      descricao: 'Treino corpo completo',
      icone: Icons.star_outline,
      tagTreino: 'fullbody',
    ),
  ];

  static GrupoMuscular? porId(String id) {
    try {
      return todos.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}

// Canonical week-day order used throughout the app
const List<String> ordemDiasSemana = [
  'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'
];

class DiaPersonalizado {
  final String diaSemana;
  final GrupoMuscular grupo;
  /// Names of exercises selected for this day. Empty list means "all".
  final List<String> exerciciosSelecionados;

  const DiaPersonalizado({
    required this.diaSemana,
    required this.grupo,
    this.exerciciosSelecionados = const [],
  });

  DiaPersonalizado copyWith({List<String>? exerciciosSelecionados}) {
    return DiaPersonalizado(
      diaSemana: diaSemana,
      grupo: grupo,
      exerciciosSelecionados:
          exerciciosSelecionados ?? this.exerciciosSelecionados,
    );
  }

  Map<String, dynamic> toMap() => {
        'diaSemana': diaSemana,
        'grupoId': grupo.id,
        'exerciciosSelecionados': exerciciosSelecionados,
      };

  static DiaPersonalizado? fromMap(Map<String, dynamic> m) {
    final grupo = GrupoMuscular.porId(m['grupoId'] ?? '');
    if (grupo == null) return null;
    final selecionados = (m['exerciciosSelecionados'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    return DiaPersonalizado(
      diaSemana: m['diaSemana'] ?? '',
      grupo: grupo,
      exerciciosSelecionados: selecionados,
    );
  }
}

class TreinoPersonalizado {
  final List<DiaPersonalizado> dias;

  const TreinoPersonalizado({required this.dias});

  Map<String, dynamic> toMap() => {
        'dias': dias.map((d) => d.toMap()).toList(),
      };

  static TreinoPersonalizado fromMap(Map<String, dynamic> m) {
    final lista = (m['dias'] as List? ?? [])
        .map((d) => DiaPersonalizado.fromMap(Map<String, dynamic>.from(d)))
        .whereType<DiaPersonalizado>()
        .toList();
    // Sort by canonical week order when loading
    lista.sort((a, b) => ordemDiasSemana
        .indexOf(a.diaSemana)
        .compareTo(ordemDiasSemana.indexOf(b.diaSemana)));
    return TreinoPersonalizado(dias: lista);
  }
}

class SplitTemplate {
  final String id;
  final String nome;
  final String descricao;
  final int dias;
  final List<String> gruposIds;

  const SplitTemplate({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dias,
    required this.gruposIds,
  });

  static const List<SplitTemplate> todos = [
    // 2 dias
    SplitTemplate(
      id: 'ab_2',
      nome: 'A/B Split',
      descricao: 'Push + Pull alternados',
      dias: 2,
      gruposIds: ['peito', 'costas'],
    ),
    SplitTemplate(
      id: 'upperlower_2',
      nome: 'Upper / Lower',
      descricao: 'Superior e inferior',
      dias: 2,
      gruposIds: ['upper', 'lower'],
    ),
    // 3 dias
    SplitTemplate(
      id: 'ppl_3',
      nome: 'Push / Pull / Legs',
      descricao: 'A divisão clássica',
      dias: 3,
      gruposIds: ['peito', 'costas', 'pernas'],
    ),
    SplitTemplate(
      id: 'upperlowerfull_3',
      nome: 'Upper / Lower / Full',
      descricao: 'Corpo completo no 3º dia',
      dias: 3,
      gruposIds: ['upper', 'lower', 'fullbody'],
    ),
    // 4 dias
    SplitTemplate(
      id: 'pplbracos_4',
      nome: 'PPL + Braços',
      descricao: 'PPL com dia dedicado a braços',
      dias: 4,
      gruposIds: ['peito', 'costas', 'pernas', 'bracos'],
    ),
    SplitTemplate(
      id: 'pplombros_4',
      nome: 'PPL + Ombros',
      descricao: 'PPL com foco em ombros',
      dias: 4,
      gruposIds: ['peito', 'costas', 'pernas', 'ombros'],
    ),
    SplitTemplate(
      id: 'upperlowerx2_4',
      nome: 'Upper / Lower x2',
      descricao: 'Ciclo completo 2 vezes',
      dias: 4,
      gruposIds: ['upper', 'lower', 'upper', 'lower'],
    ),
    // 5 dias
    SplitTemplate(
      id: 'pplabracos_5',
      nome: 'PPL + Arms + Ombros',
      descricao: '5 grupos distintos por semana',
      dias: 5,
      gruposIds: ['peito', 'costas', 'pernas', 'bracos', 'ombros'],
    ),
    SplitTemplate(
      id: 'pplul_5',
      nome: 'PPL + Upper / Lower',
      descricao: 'PPL seguido de upper/lower',
      dias: 5,
      gruposIds: ['peito', 'costas', 'pernas', 'upper', 'lower'],
    ),
    // 6 dias
    SplitTemplate(
      id: 'pplx2_6',
      nome: 'PPL x2',
      descricao: 'Cada grupo 2× por semana',
      dias: 6,
      gruposIds: ['peito', 'costas', 'pernas', 'peito', 'costas', 'pernas'],
    ),
    SplitTemplate(
      id: 'fullsplit_6',
      nome: 'Full Split',
      descricao: 'Um grupo muscular por dia',
      dias: 6,
      gruposIds: ['peito', 'costas', 'pernas', 'ombros', 'bracos', 'upper'],
    ),
  ];

  static List<SplitTemplate> paraDias(int dias) =>
      todos.where((t) => t.dias == dias).toList();
}
