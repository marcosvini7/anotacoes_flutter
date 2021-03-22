import 'package:flutter/material.dart';
import 'Home.dart';
import 'CriarEditar.dart';
import '../models/AnotacaoModel.dart';

class Visualizacao extends StatefulWidget {
  Map<String, dynamic> anotacao;

  Visualizacao(this.anotacao);
  @override
  _VisualizacaoState createState() => _VisualizacaoState();
}

class _VisualizacaoState extends State<Visualizacao> {
  confirmacao() async {
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
                deletar(widget.anotacao['id']);
              },
            ),
          ],
        );
      },
    );
    if (result != null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('Anotação'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              size: 30,
            ),
            onPressed: () {
              editar(context);
            },
          ),
          IconButton(
              icon: Icon(
                Icons.delete,
                size: 30,
              ),
              onPressed: () async {
                confirmacao();
              }),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5),
        child: Card(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  widget.anotacao['titulo'],
                  style: TextStyle(color: Colors.orange[700], fontSize: 24),
                ),
                Divider(),
                Text(
                  widget.anotacao['anotacao'],
                  style: TextStyle(fontSize: 20),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      textoData(DateTime.parse(widget.anotacao['data'])),
                      style:
                          TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  editar(BuildContext context) async {
    var result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CriarEditar(widget.anotacao);
    }));
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Sua anotação foi atualizada!', textAlign: TextAlign.center),
        backgroundColor: Colors.green[300],
        duration: Duration(seconds: 2),
      ));
      AnotacaoModel anotacaoModel = AnotacaoModel(id: widget.anotacao['id']);
      Map<String, dynamic> anotacao = await anotacaoModel.buscar();
      setState(() {
        widget.anotacao = {
          'id': anotacao['id'],
          'titulo': anotacao['titulo'],
          'anotacao': anotacao['anotacao'],
          'data': anotacao['data']
        };
      });
    }
  }

  deletar(int id) async {
    AnotacaoModel anotacaoModel = AnotacaoModel(id: id);
    await anotacaoModel.deletar();
    setState(() {});
  }
}
