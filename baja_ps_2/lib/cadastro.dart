import 'modelos/modelo_user.dart';

class AuthService {
  final List<User> _usuarios = [
    User(
      nome: "Teste",
      email: "vitorteste@baja.com",
      senha: "ronaldo",
      perfil: "piloto",
    ),
  ];

  void cadastrar(String nome, String email, String senha, String perfil) {
    _usuarios.add(User(nome: nome, email: email, senha: senha, perfil: perfil));
  }

  User? login(String email, String senha) {
    for (final u in _usuarios) {
      if (u.email == email && u.senha == senha) return u;
    }
    return null;
  }
}