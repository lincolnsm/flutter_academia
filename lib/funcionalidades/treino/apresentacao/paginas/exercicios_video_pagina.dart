import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../usuario/widgets/painel_usuario.dart';

class ExercicioVideoPagina extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final String urlVideo;
  final String imagem;

  const ExercicioVideoPagina({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.urlVideo,
    required this.imagem,
  });

  @override
  State<ExercicioVideoPagina> createState() => _ExercicioVideoPaginaState();
}

class _ExercicioVideoPaginaState extends State<ExercicioVideoPagina> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.urlVideo,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return _buildScaffold(context, player);
      },
    );
  }

  Scaffold _buildScaffold(BuildContext context, Widget player) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: player,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.subtitulo,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: const Color(0xFF2E3D3C),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              onTap: () => PainelUsuario.abrir(context),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}