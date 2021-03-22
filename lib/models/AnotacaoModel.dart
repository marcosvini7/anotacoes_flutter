import 'package:sqflite/sqflite.dart';
import '../config/AnotacaoHelper.dart';

class AnotacaoModel {
  int id;
  String titulo;
  String anotacao;
  String data;

  AnotacaoModel({this.id, this.anotacao, this.titulo, this.data});

  salvar() async {
    Database db = await AnotacaoHelper().db;
    Map<String, dynamic> anotacaoMap = {
      'titulo': titulo,
      'anotacao': anotacao,
      'data': data,
    };
    await db.insert('anotacoes', anotacaoMap);
  }

  atualizar() async {
    Database db = await AnotacaoHelper().db;
    Map<String, dynamic> anotacaoMap = {
      'id': id,
      'titulo': titulo,
      'anotacao': anotacao,
    };
    await db.update(
      'anotacoes',
      anotacaoMap,
      where: 'id = ?',
      whereArgs: [anotacaoMap['id']],
    );
  }

  deletar() async {
    Database db = await AnotacaoHelper().db;
    await db.delete('anotacoes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List> pesquisar(String pesquisa) async {
    Database db = await AnotacaoHelper().db;
    List<Map<String, dynamic>> anotacoes = await db.rawQuery('select * from ' +
        'anotacoes where anotacao like "%' +
        pesquisa +
        '%" or titulo like "%' +
        pesquisa +
        '%" order by id desc');
    return anotacoes;
  }

  Future<List> recuperarTodas() async {
    Database db = await AnotacaoHelper().db;
    List<Map<String, dynamic>> anotacoes =
        await db.rawQuery('select * from anotacoes order by id desc');
    return anotacoes;
  }

  Future<Map> buscar() async {
    Database db = await AnotacaoHelper().db;
    List<Map<String, dynamic>> anotacao =
        await db.rawQuery('select * from anotacoes where id = $id');
    return anotacao[0];
  }
}
