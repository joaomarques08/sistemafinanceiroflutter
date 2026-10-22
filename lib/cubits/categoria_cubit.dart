import 'package:flutter_bloc/flutter_bloc.dart';
import 'categoria_state.dart';
import '../models/categoria.dart';
import '../repositories/categoria_repository.dart';

class CategoriaCubit extends Cubit<CategoriaState> {
  List<Categoria> _categorias = [];
  final CategoriaRepository repository;

  CategoriaCubit({required this.repository}) : super(CategoriaLoading([]));

  Future<void> carregarCategorias() async {
    emit(CategoriaLoading(_categorias));

    try {
      _categorias = await repository.buscarCategorias();
      emit(CategoriaLoaded(_categorias));
    } catch (e) {
      emit(CategoriaError('Erro ao carregar as categorias. $e', _categorias));
    }
  }

  Future<void> salvarCategoria(String nome) async {
    if (nome.trim().isEmpty) {
      emit(CategoriaError('O nome da categoria não pode ser vazio.', _categorias));
      return;
    }

    emit(CategoriaLoading(_categorias));

    try {
      final novaCategoria = await repository.criarCategoria(
        Categoria(id: '', nome: nome.trim())
      );

      // Cria uma nova lista com a categoria salva e deixa em ordem alfabética
      _categorias = [..._categorias, novaCategoria];
      _categorias.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

      emit(CategoriaSuccess('Categoria salva com sucesso!', _categorias));
    } catch (e) {
      emit(CategoriaError('Falha ao salvar a categoria. $e', _categorias));
    }
  }

}
