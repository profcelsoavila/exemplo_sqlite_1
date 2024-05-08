import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  //impede a ocorrência de erros causados por atualização do Flutter
  WidgetsFlutterBinding.ensureInitialized();
  //Abre o banco de dados no caminho padrão da plataforma utilizada pelo aplicativo
  final database = openDatabase(
    join(await getDatabasesPath(), 'minhas_atividades.db'),
    //quando o banco de dados é criado pela primeira vez
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE atividades(id INTEGER PRIMARY KEY, disciplina TEXT, descricao TEXT, dataEntrega TEXT)',
      );
    },
    version: 1,
  );

  // funçao para inserir dados
  Future<void> insertAtividade(Atividade atividade) async {
    // obtém a referência do banco de dados
    final db = await database;

    //insere um registo na tabela atividades
    await db.insert(
      'atividades',
      atividade.toMap(),
      //evita conflitos caso o registro seja inserido mais de uma vez
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // função para listar todos os registros
  Future<List<Atividade>> atividades() async {

    final db = await database;
    final List<Map<String, Object?>> atividadeMaps = await db.query('atividades');

    // converte cada registro obtido em um objeto Atividade
    return [
      for (final {
      'id': id as int,
      'disciplina': disciplina as String,
      'descricao': descricao as String,
      'dataEntrega': dataEntrega as String,
      } in atividadeMaps)
        Atividade(id: id, disciplina: disciplina, descricao: descricao, dataEntrega: dataEntrega),
    ];
  }
//função para atualizar os dados
  Future<void> updateAtividade(Atividade atividade) async {

    final db = await database;
    await db.update(
      'atividades',
      atividade.toMap(),
      // Certifica-se de que se trata de um registro válido
      where: 'id = ?',
      whereArgs: [atividade.id],
    );
  }

//função para excluir um registro
  Future<void> deleteAtividade(int id) async {
    // Get a reference to the database.
    final db = await database;
    await db.delete(
      'atividades',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  //dados de teste
  var atividade1 = Atividade(
    id: 1,
    disciplina: 'Programação para Dispostivos Móveis',
    descricao: 'Criar um aplicativo com layout em colunas',
    dataEntrega: '20/05/2024'
  );
  await insertAtividade(atividade1);
  print(await atividades()); // Prints a list that include Fido.

  atividade1 = Atividade(
    id: atividade1.id,
    disciplina: 'Desenvolvimento Web Front End',
    descricao: 'Criar uma página com layout responsivo',
    dataEntrega: '20/05/2024'
  );
  await updateAtividade(atividade1);
  print(await atividades());

  await deleteAtividade(atividade1.id);
  print(await atividades());
}

class Atividade {
  final int id;
  final String disciplina;
  final String descricao;
  final String dataEntrega;

  Atividade({
    required this.id,
    required this.disciplina,
    required this.descricao,
    required this.dataEntrega,
  });

  //Converte um objeto Atividade em um Map chave valor
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'disciplina': disciplina,
      'descricao': descricao,
      'dataEntrega': dataEntrega,
    };
  }

 //Sobrescreve toString para facilitar a exibição dos dados com o comando print
  @override
  String toString() {
    return 'Atividade{id: $id, disciplina: $disciplina, descricao: $descricao, dataEntrega: $dataEntrega}';
  }
}