import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/AnotacaoModel.dart';

class CriarEditar extends StatefulWidget {
  Map<String, dynamic> anotacao;

  CriarEditar(this.anotacao);

  @override
  _CriarEditarState createState() => _CriarEditarState();
}

class _CriarEditarState extends State<CriarEditar> {
  TextEditingController tituloController = TextEditingController();
  TextEditingController anotacaoController = TextEditingController();
  String status;

  @override
  initState() {
    super.initState();
    if (widget.anotacao != null) {
      status = 'Editando Anotação';
      tituloController.text = widget.anotacao['titulo'];
      anotacaoController.text = widget.anotacao['anotacao'];
    } else {
      status = 'Nova Anotação';
    }
  }

  bool validarCampos() {
    if (tituloController.text.isEmpty && anotacaoController.text.isEmpty) {
      return false;
    }
    return true;
  }

  salvar() async {
    var titulo = tituloController.text.isEmpty
        ? 'Anotação sem título'
        : tituloController.text;

    AnotacaoModel anotacaoModel = AnotacaoModel(
      titulo: titulo,
      anotacao: anotacaoController.text,
      data: DateTime.now().toString(),
    );
    await anotacaoModel.salvar();
  }

  atualizar() async {
    var titulo = tituloController.text.isEmpty
        ? 'Anotação sem título'
        : tituloController.text;
    AnotacaoModel anotacaoModel = AnotacaoModel(
      id: widget.anotacao['id'],
      titulo: titulo,
      anotacao: anotacaoController.text,
    );
    await anotacaoModel.atualizar();
  }

  Future<String> salvarAlteracoes(String texto) async {
    String result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text(texto),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'nao');
              },
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'sim');
              },
              child: Text('Sim'),
            ),
          ],
        );
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (validarCampos()) {
          if (widget.anotacao != null) {
            if (widget.anotacao['titulo'] != tituloController.text ||
                widget.anotacao['anotacao'] != anotacaoController.text) {
              if (await salvarAlteracoes('Salvar alterações?') == 'sim') {
                await atualizar();
                Navigator.pop(context, 'Sua anotação foi atualizada!');
              }
            }
          } else {
            if (await salvarAlteracoes('Salvar esta anotação?') == 'sim') {
              await salvar();
              Navigator.pop(context, 'Sua anotação foi sava!');
            }
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(status),
          backgroundColor: Colors.cyan,
          actions: [
            IconButton(
              icon: Icon(
                Icons.save,
                size: 30,
              ),
              onPressed: () async {
                if (!validarCampos()) {
                  return;
                }
                if (widget.anotacao != null) {
                  await atualizar();
                  Navigator.pop(context, 'atualizou');
                } else {
                  await salvar();
                  Navigator.pop(context, 'salvou');
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Título',
                  ),
                  style: TextStyle(fontSize: 18),
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  controller: tituloController,
                ),
                TextField(
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Anotação',
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 18),
                  minLines: 20,
                  maxLines: 200,
                  controller: anotacaoController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
