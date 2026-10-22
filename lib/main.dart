import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- 1. Importe o pacote do Supabase
import 'cubits/auth_cubit.dart';
import 'cubits/auth_state.dart' as app_auth_state;
import 'cubits/categoria_cubit.dart';
import 'cubits/transacao_form_cubit.dart';
import 'cubits/transacao_cubit.dart';
import 'repositories/auth_repository.dart';
import 'repositories/categoria_repository.dart';
import 'repositories/transacao_repository.dart';
import 'views/tela_principal.dart';
import 'views/login_page.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  
  await Supabase.initialize(
    url: 'https://skspjwkugtydevhbgyfh.supabase.co', 
    publishableKey: 'sb_publishable_OqLPvWKDZjVYJQPsGI0Mjw_nQkmL4gH'
  );

  runApp(const FinanceiroApp());
}

class FinanceiroApp extends StatelessWidget {
  const FinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(repository: AuthRepository()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Controle Financeiro',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)
        ),
        home: BlocBuilder<AuthCubit, app_auth_state.AuthState>(
          builder: (context, state) {
            if (state is app_auth_state.Authenticated) {
              final transacaoRepository = TransacaoRepository(accessToken: state.usuario.accessToken);
              final categoriaRepository = CategoriaRepository(accessToken: state.usuario.accessToken);
              return MultiBlocProvider(
                      providers: [
                        BlocProvider<TransacaoCubit>(
                          create: (context) => TransacaoCubit(repository: transacaoRepository)..carregarTransacoes()
                        ),
                        BlocProvider<CategoriaCubit>(
                          create: (context) => CategoriaCubit(repository: categoriaRepository)..carregarCategorias()
                        ),
                        BlocProvider<TransacaoFormCubit>(
                          create: (context) => TransacaoFormCubit(
                            transacaoCubit: context.read<TransacaoCubit>()
                          )
                        )
                      ],
                      child: const TelaPrincipal()
                );
            }

            return const LoginPage();
          }
        )
      ),
    );
  }
}