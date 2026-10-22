import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/categoria_cubit.dart';
import '../cubits/categoria_state.dart';
import '../cubits/transacao_form_cubit.dart';
import '../cubits/transacao_form_state.dart';
import '../models/transacao.dart';

class CadastroTransacaoPage extends StatefulWidget {

  final Transacao? transacaoParaEdicao;
  
  const CadastroTransacaoPage({super.key, this.transacaoParaEdicao});

  @override
  State<CadastroTransacaoPage> createState() => _CadastroTransacaoPageState();

}

class _CadastroTransacaoPageState extends State<CadastroTransacaoPage> {
  late final TextEditingController _descricaoController;
  late final TextEditingController _valorController;
  late TipoTransacao _tipoSelecionado;
  String? _categoriaSelecionada;

  bool get _isEdicao => widget.transacaoParaEdicao != null;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.transacaoParaEdicao?.descricao ?? ""
    );
    _valorController = TextEditingController(
      text: widget.transacaoParaEdicao?.valor.toStringAsFixed(2) ?? ""
    );
    _tipoSelecionado = widget.transacaoParaEdicao?.tipo ?? TipoTransacao.receita;
    _categoriaSelecionada = widget.transacaoParaEdicao?.categoriaId;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? "Editar Transação" : "Nova Transação"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocListener<TransacaoFormCubit, TransacaoFormState>(
          listener: (context, state) {
            if (state is TransacaoFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.erro),
                  backgroundColor: Colors.red                  
                )
              );
            }

            if (state is TransacaoFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensagem),
                  backgroundColor: Colors.green,
                )
              );
              if (_isEdicao) {
                Navigator.of(context).pop();
              } else {
                _descricaoController.clear();
                _valorController.clear();
                setState(() {
                  _categoriaSelecionada = null;
                });
              }
              context.read<TransacaoFormCubit>().resertarEstado();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Botões de seleção do tipo de transação
                SegmentedButton<TipoTransacao>(
                  segments: [
                    ButtonSegment(
                      value: TipoTransacao.receita,
                      label: Text('Receita'),
                      icon: Icon(Icons.arrow_upward, color: Colors.green)
                    ),
                    ButtonSegment(
                      value: TipoTransacao.despesa,
                      label: Text('Despesa'),
                      icon: Icon(Icons.arrow_downward, color: Colors.red)
                    )
                  ],
                  selected: {_tipoSelecionado},
                  onSelectionChanged: (Set<TipoTransacao> newSelection) {
                    setState(() {
                      _tipoSelecionado = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 20),

                //Campo de descrição
                TextField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 20),

                //Campo de Valor
                TextField(
                  controller: _valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 20),

                //Campo de Categoria (as categorias vêm do banco, pelo CategoriaCubit)
                BlocBuilder<CategoriaCubit, CategoriaState>(
                  builder: (context, categoriaState) {
                    final categorias = categoriaState.categorias;
                    final categoriaExiste = categorias.any(
                      (categoria) => categoria.id == _categoriaSelecionada
                    );

                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder()
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          isDense: true,
                          value: categoriaExiste ? _categoriaSelecionada : null,
                          hint: Text(
                            categorias.isEmpty
                              ? 'Nenhuma categoria cadastrada'
                              : 'Selecione uma categoria'
                          ),
                          items: categorias.map((categoria) {
                            return DropdownMenuItem<String>(
                              value: categoria.id,
                              child: Text(categoria.nome)
                            );
                          }).toList(),
                          onChanged: (String? novaCategoria) {
                            setState(() {
                              _categoriaSelecionada = novaCategoria;
                            });
                          },
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 20),

                //Botão de salvar
                BlocBuilder<TransacaoFormCubit, TransacaoFormState>(
                  builder: (context, state) {
                    final isLoading = state is TransacaoFormLoading;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _tipoSelecionado == TipoTransacao.receita
                          ? Colors.green
                          : Colors.red,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        )
                      ),
                      onPressed: isLoading
                        ? null
                        : () {
                        context.read<TransacaoFormCubit>().salvarTransacao(
                          id: widget.transacaoParaEdicao?.id,
                          descricao: _descricaoController.text, 
                          valorText: _valorController.text, 
                          tipo: _tipoSelecionado,
                          categoriaId: _categoriaSelecionada
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
                        : Text(
                          _isEdicao ? 'Alterar Transação' : 'Salvar Transação',
                          style: TextStyle(fontSize: 16, color: Colors.white)
                        )
                    );
                  }
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}