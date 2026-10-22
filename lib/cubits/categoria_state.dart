import '../models/categoria.dart';

// Todos os estados guardam a lista de categorias,
// assim a tela sempre consegue mostrar a lista (mesmo durante um erro ou carregamento).
abstract class CategoriaState {
  final List<Categoria> categorias;
  CategoriaState(this.categorias);
}

class CategoriaLoading extends CategoriaState {
  CategoriaLoading(super.categorias);
}

class CategoriaLoaded extends CategoriaState {
  CategoriaLoaded(super.categorias);
}

class CategoriaSuccess extends CategoriaState {
  final String mensagem;
  CategoriaSuccess(this.mensagem, super.categorias);
}

class CategoriaError extends CategoriaState {
  final String erro;
  CategoriaError(this.erro, super.categorias);
}
