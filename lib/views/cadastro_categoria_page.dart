import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/categoria_cubit.dart';
import '../cubits/categoria_state.dart';

class CadastroCategoriaPage extends StatefulWidget {

  const CadastroCategoriaPage({super.key});

  @override
  State<CadastroCategoriaPage> createState() => _CadastroCategoriaPageState();

}

class _CadastroCategoriaPageState extends State<CadastroCategoriaPage> {
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Categorias"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocConsumer<CategoriaCubit, CategoriaState>(
          listener: (context, state) {
            if (state is CategoriaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.erro),
                  backgroundColor: Colors.red
                )
              );
            }

            if (state is CategoriaSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensagem),
                  backgroundColor: Colors.green,
                )
              );
              _nomeController.clear();
            }
          },
          builder: (context, state) {
            final isLoading = state is CategoriaLoading;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Campo de nome da categoria
                  TextField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome da categoria',
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Botão de salvar
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      )
                    ),
                    onPressed: isLoading
                      ? null
                      : () {
                      context.read<CategoriaCubit>().salvarCategoria(
                        _nomeController.text
                      );
                    },
                    child: isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2
                        ),
                      )
                      : const Text(
                        'Salvar Categoria',
                        style: TextStyle(fontSize: 16, color: Colors.white)
                      )
                  ),
                  const SizedBox(height: 24),

                  //Lista das categorias já cadastradas
                  const Text(
                    "Categorias Cadastradas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: state.categorias.isEmpty
                      ? Center(
                        child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                            "Nenhuma categoria cadastrada.",
                            style: TextStyle(color: Colors.grey)
                          ),
                      )
                      : ListView.builder(
                        itemCount: state.categorias.length,
                        itemBuilder: (context, index) {
                          final categoria = state.categorias[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade200,
                                child: const Icon(
                                  Icons.label_outline,
                                  color: Colors.white
                                ),
                              ),
                              title: Text(
                                categoria.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                      )
                  )
                ],
              ),
            );
          }
        )
      ),
    );
  }

}
