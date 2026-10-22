class Categoria {
  final String id;
  final String nome;

  Categoria({
    required this.id,
    required this.nome
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome
    };
  }

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as String,
      nome: json['nome'] as String
    );
  }

}
