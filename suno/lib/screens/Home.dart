import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suno/controles/AssinaturaDB.dart';
import 'package:suno/controles/ControleBanco.dart';
import 'package:suno/model/Assinatura.dart';
import 'package:suno/widgets/AppDrawer.dart';
import 'package:suno/widgets/CardItemList.dart';
import 'AddAssinatra.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AssinaturaDB assDB = AssinaturaDB();
  List<Assinatura> listaAssinaturas = List();
  List<Assinatura> listaAssinaturasMesCorrente = List();
  List<Assinatura> listaTeste = List();

  var total;
  var formatMMyyyy = DateFormat("MM/yyyy");
  var dataAtual = new DateTime.now();
  String totalAssinaturas = "";
  ControleBanco cb = ControleBanco();
  DateFormat format_dd = DateFormat("dd");
  DateFormat format_MM = DateFormat("MM");
  DateFormat format_yyyy = DateFormat("yyyy");

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  _allMovMes(String data) {
    assDB.getAllAssinaturasPorMes(data).then((list) {
      //print(list);
      listaAssinaturasMesCorrente.clear();

      if (list.isNotEmpty) {

        for (int i = 0; i < list.length; i++) {
          Assinatura ass = list[i];
          int mesAss = int.parse(ass.data.substring(3, 5));
          int mesParam = int.parse(data.substring(0, 2));
          int anoAss = int.parse(ass.data.substring(6, 10));
          int anoParam = int.parse(data.substring(3, 7));
          //print("ASS DATA: ${ass.data.substring(3,5)}");
          //  print("DATA: ${data.substring(0,2)}");
          //print("ASS Ano: ${anoAss}");
          //print("DATA Ano: ${anoParam}");
          
          if (ass.recorrencia == 'mensal') {
            if (mesAss <= mesParam  ) {
              if(anoAss <= anoParam){
                listaAssinaturasMesCorrente.add(ass);
              }              
            } 
            if (mesAss >= mesParam  ) {
              if(anoAss < anoParam){
                listaAssinaturasMesCorrente.remove(ass);
                listaAssinaturasMesCorrente.add(ass);
              }              
            } 

          }
          if (ass.recorrencia == 'anual' || ass.recorrencia == 'unica') {
            listaAssinaturasMesCorrente.add(ass);
          }

        }
        setState(() {
          listaAssinaturas = listaAssinaturasMesCorrente;
          //listaAssinaturas = list;
        });

        total = listaAssinaturas.map((item) => item.valor).reduce((a, b) => a + b);
        totalAssinaturas = format(total).toString();

      } else {
        setState(() {
          listaAssinaturas.clear();
          total = 0;
          totalAssinaturas = total.toString();
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_allMovMes(formatMMyyyy.format(dataAtual));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _allMovMes(formatMMyyyy.format(dataAtual));

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            "Assinaturas",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddAssinatura()));
                }),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Container(          
          height: height,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  padding:
                      EdgeInsets.only(top: 30, bottom: 30, left: 15, right: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border.all(width: 0.2, color: Colors.orange[700]),
                    borderRadius: BorderRadius.circular(15),
                    
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(-3, 3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Total: ",
                            style: TextStyle(fontSize: 25, color: Colors.grey)),
                        Text(
                          totalAssinaturas,
                          style: TextStyle(fontSize: 40, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: listaAssinaturas.length,
                    itemBuilder: (context, index) {
                      Assinatura ass = listaAssinaturas[index];
                      return CardItemList(
                        id: ass.id,
                        nome: ass.assinaturaName,
                        imagemUrl: ass.urlLogo,
                        valor: ass.valor.toString(),
                        plano: ass.plano,
                        recorrencia: ass.recorrencia,
                        nota: ass.nota,
                        metodoPG: ass.metodoPG,
                        descricao: ass.descricao,
                        data: ass.data,
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
