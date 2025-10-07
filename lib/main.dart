import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'funcionalidades/usuario/apresentacao/controladores/cadastro_controlador.dart';
import 'funcionalidades/usuario/apresentacao/controladores/login_controlador.dart';
import 'funcionalidades/usuario/apresentacao/paginas/cadastro_pagina.dart';
import 'funcionalidades/usuario/apresentacao/paginas/inicial_pagina.dart';
import 'funcionalidades/usuario/apresentacao/paginas/escolha_nivel_pagina.dart';
import 'funcionalidades/treino/apresentacao/paginas/treino_pagina.dart';
import 'funcionalidades/treino/apresentacao/paginas/exercicios_lista_pagina.dart';
import 'funcionalidades/treino/apresentacao/paginas/exercicios_video_pagina.dart';
import 'funcionalidades/treino/dominio/entidades/treino.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CadastroControlador()),
        ChangeNotifierProvider(create: (_) => LoginControlador()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Academia',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1B2B2A),
        ),
        initialRoute: '/inicial',
        routes: {
          '/inicial': (_) => const InicioPagina(),
          '/cadastro': (_) => const CadastroPagina(),
          '/escolha-nivel': (_) => const EscolhaNivelPagina(),
          '/treino/exercicios': (_) => const PaginaExerciciosWrapper(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/treino') {
            final args = settings.arguments as Map<String, dynamic>;
            final nivel = args['nivel'] ?? 'iniciante';
            return MaterialPageRoute(
              builder: (_) => TreinoPagina(nivel: nivel),
            );
          }
          if (settings.name == '/treino/video') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ExercicioVideoPagina(
                titulo: args['titulo'] ?? 'Exercício',
                subtitulo: args['subtitulo'] ?? '',
                urlVideo: args['urlVideo'] ?? '',
                imagem: '',
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class PaginaExerciciosWrapper extends StatelessWidget {
  const PaginaExerciciosWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Treino) {
      int casaCount = 0;
      int academiaCount = 0;
      for (final ex in args.exercicios) {
        if (ex.tipoEquipamento.toLowerCase() == 'casa') {
          casaCount++;
        } else if (ex.tipoEquipamento.toLowerCase() == 'academia') {
          academiaCount++;
        }
      }
      final tipoPredominante = casaCount >= academiaCount ? 'casa' : 'academia';
      return ExerciciosListaPagina(
        tipo: tipoPredominante,
        exercicios: args.exercicios,
      );
    }
    if (args is String) {
      return ExerciciosListaPagina(tipo: args);
    }
    return const ExerciciosListaPagina(tipo: 'academia');
  }
}