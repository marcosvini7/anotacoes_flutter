import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  bool iconesVisiveis;

  Future<Map<String, dynamic>> obterPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {'iconesVisiveis': prefs.getBool('iconesVisiveis')};
  }

  Map<String, dynamic> validarPrefs(Map prefs) {
    if (prefs['iconesVisiveis'] == null) {
      prefs['iconesVisiveis'] = true;
    }
    return prefs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('Configurações'),
      ),
      body: FutureBuilder(
        future: obterPreferencias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> prefs = validarPrefs(snapshot.data);
            iconesVisiveis = prefs['iconesVisiveis'];
            return Container(
              width: double.infinity,
              child: Column(
                children: [
                  Card(
                    child: SwitchListTile(
                      value: iconesVisiveis,
                      onChanged: (value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setBool('iconesVisiveis', value);
                        setState(() {
                          iconesVisiveis = value;
                        });
                      },
                      title: Text('Mostrar ícones editar/apagar'),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
