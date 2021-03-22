import 'dart:ui';
import 'package:flutter/material.dart';
import 'Configuracoes.dart';
import 'CriarEditar.dart';
import '../models/AnotacaoModel.dart';
import 'Pesquisa.dart';
import 'Visualizacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

String textoData(DateTime dataParametro) {
  String data;
  DateTime hoje = DateTime.now();

  if (hoje.day == dataParametro.day) {
    data = 'Hoje';
  } else if ((hoje.day.toInt() - 1) == dataParametro.day) {
    data = 'Ontem';
  } else {
    data =
        'Em ${dataParametro.day}/${dataParametro.month}/${dataParametro.year}';
  }
  int minuto = dataParametro.minute.toInt();
  String minutos = minuto < 10 ? '0' + minuto.toString() : minuto.toString();

  return '$data às ${dataParametro.hour}:$minutos';
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> anotacoes;
  AnotacaoModel anotacaoModel = AnotacaoModel();
  var status = 1;
  String pesquisa;

  deletar(int id) async {
    anotacaoModel = AnotacaoModel(id: id);
    await anotacaoModel.deletar();
    setState(() {});
  }

  pesquisar() async {
    var campoPesquisa =
        await showSearch(context: context, delegate: Pesquisa());
    if (campoPesquisa != null && campoPesquisa.isNotEmpty) {
      setState(() {
        status = 2;
        pesquisa = campoPesquisa;
      });
    }
  }

  Future<Map> pesquisarOuListarTodas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('iconesVisiveis') == null) {
      prefs.setBool('iconesVisiveis', true);
    }
    if (status == 1) {
      return {
        'lista': await anotacaoModel.recuperarTodas(),
        'iconesVisiveis': prefs.getBool('iconesVisiveis'),
        'msg': 'Adicione suas anotações e elas aparecerão aqui ;)',
      };
    } else {
      return {
        'lista': await anotacaoModel.pesquisar(pesquisa),
        'iconesVisiveis': prefs.getBool('iconesVisiveis'),
        'msg': 'Ops! nenhuma anotação foi encontrada!'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anotações'),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                status = 1;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            onPressed: () {
              pesquisar();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 30,
            ),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return Configuracoes();
              }));
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Container(
            child: FutureBuilder(
              future: pesquisarOuListarTodas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data['lista'].length > 0) {
                    List<Map> anotacoes = snapshot.data['lista'];
                    return ListView.builder(
                      itemCount: anotacoes.length,
                      itemBuilder: (context, i) {
                        if (snapshot.data['iconesVisiveis']) {
                          return Card(
                            color: Colors.grey.shade100,
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                anotacoes[i]['titulo'],
                                style: TextStyle(
                                    color: Colors.orange[800], fontSize: 18),
                              ),
                              subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      anotacoes[i]['anotacao'],
                                      style: TextStyle(fontSize: 16),
                                      maxLines: 4,
                                    ),
                                    Text(
                                      textoData(
                                          DateTime.parse(anotacoes[i]['data'])),
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        abrirAnotacao(anotacoes[i]);
                                      }),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        size: 25, color: Colors.red),
                                    onPressed: () {
                                      confirmacao(anotacoes[i]['id']);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return Visualizacao(anotacoes[i]);
                                  }),
                                );
                                setState(() {});
                              },
                            ),
                          );
                        } else {
                          return listaComIconesOcultos(anotacoes, i);
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        snapshot.data['msg'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.cyan,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add),
        onPressed: () {
          abrirAnotacao(null);
        },
      ),
    );
  }

  abrirAnotacao(Map<String, dynamic> anotacao) async {
    var result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CriarEditar(anotacao);
    }));
    if (result != null) {
      setState(() {});
      var mensagem = "Sua anotação foi sava!";
      if (anotacao != null) {
        mensagem = "Sua anotação foi atualizada!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem, textAlign: TextAlign.center),
          backgroundColor: Colors.green[300],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  confirmacao(int id) async {
    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirmação',
          ),
          content: Text('Deseja realmente apagar esta anotação?'),
          actions: [
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Sim'),
              onPressed: () {
                Navigator.pop(context, 'value');
              },
            ),
          ],
        );
      },
    );
    if (result != null) {
      await Future.delayed(Duration(milliseconds: 100));
      deletar(id);
    }
  }

  Widget listaComIconesOcultos(List<Map<String, dynamic>> anotacoes, int i) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 3,
      child: ListTile(
        title: Text(
          anotacoes[i]['titulo'],
          style: TextStyle(color: Colors.orange[800], fontSize: 18),
        ),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            anotacoes[i]['anotacao'],
            style: TextStyle(fontSize: 16),
            maxLines: 4,
          ),
          Text(
            textoData(DateTime.parse(anotacoes[i]['data'])),
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ]),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return Visualizacao(anotacoes[i]);
            }),
          );
          setState(() {});
        },
      ),
    );
  }
}
