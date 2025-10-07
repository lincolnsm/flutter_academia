abstract class Falha {
  final String mensagem;
  const Falha(this.mensagem);
}

class FalhaGeral extends Falha {
  const FalhaGeral({required String mensagem}) : super(mensagem);
}

class FalhaDeCadastro extends Falha {
  const FalhaDeCadastro({required String mensagem}) : super(mensagem);
  factory FalhaDeCadastro.fromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const FalhaDeCadastro(mensagem: "Este e-mail já está em uso.");
      case 'invalid-email':
        return const FalhaDeCadastro(mensagem: "E-mail inválido.");
      case 'weak-password':
        return const FalhaDeCadastro(mensagem: "A senha é muito fraca.");
      case 'operation-not-allowed':
        return const FalhaDeCadastro(
            mensagem: "Cadastro desabilitado. Contate o suporte.");
      default:
        return const FalhaDeCadastro(
            mensagem: "Erro desconhecido ao cadastrar.");
    }
  }
}

class FalhaDeLogin extends Falha {
  const FalhaDeLogin({required String mensagem}) : super(mensagem);
  factory FalhaDeLogin.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const FalhaDeLogin(mensagem: "E-mail inválido.");
      case 'user-disabled':
        return const FalhaDeLogin(mensagem: "Usuário desativado.");
      default:
        return const FalhaDeLogin(mensagem: "Erro desconhecido no login.");
    }
  }
  factory FalhaDeLogin.credenciaisInvalidas() {
    return const FalhaDeLogin(
      mensagem: "E-mail ou senha incorretos. Verifique e tente novamente.",
    );
  }
}

class FalhaDeValidacao extends Falha {
  const FalhaDeValidacao({required String mensagem}) : super(mensagem);
  factory FalhaDeValidacao.campoVazio(String campo) {
    return FalhaDeValidacao(mensagem: "O campo $campo não pode estar vazio.");
  }
  factory FalhaDeValidacao.generica(String mensagem) {
    return FalhaDeValidacao(mensagem: mensagem);
  }
}