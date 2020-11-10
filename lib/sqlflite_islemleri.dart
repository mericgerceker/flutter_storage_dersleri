import 'package:flutter/material.dart';
import 'package:flutter_storage_dersleri/model/ogrenci.dart';
import 'package:flutter_storage_dersleri/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteIslemleri extends StatefulWidget {
  @override
  _SqfliteIslemleriState createState() => _SqfliteIslemleriState();
}

class _SqfliteIslemleriState extends State<SqfliteIslemleri> {
  DatabaseHelper _databaseHelper;
  List<Ogrenci> tumOgrencilerListesi;
  bool aktiflik = false;
  var _controller = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  int tiklanilanOgrenciIndeksi;
  int tiklanilanOgrenciIDsi;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumOgrencilerListesi = List<Ogrenci>();
    _databaseHelper = DatabaseHelper();
    _databaseHelper.tumOgrenciler().then((tumOgrencileriTutanMapListesi) {
      for (Map okunanOgrenciMapi in tumOgrencileriTutanMapListesi) {
        tumOgrencilerListesi
            .add(Ogrenci.dbdenOkudugunMapiObjeyeDonustur(okunanOgrenciMapi));
      }
      print("dbden gelen ogrenci sayısı:" +
          tumOgrencilerListesi.length.toString());
    }).catchError((hata) => print("hata:" + hata));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Sqflite Kullanımı"),
      ),
      body: Container(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      autofocus: false,
                      controller: _controller,
                      validator: (kontrolEdilecekIsimDegeri) {
                        if (kontrolEdilecekIsimDegeri.length < 3) {
                          return "en az 3 karakter olmalı";
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Ogrenci ismini giriniz",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: Text("Aktif"),
                    value: aktiflik,
                    onChanged: (aktifMi) {
                      setState(() {
                        aktiflik = aktifMi;
                      });
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  child: Text("Kaydet"),
                  color: Colors.green,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _ogrenciEkle(
                          Ogrenci(_controller.text, aktiflik == true ? 1 : 0));
                    }
                  },
                ),
                RaisedButton(
                  child: Text("Güncelle"),
                  color: Colors.blue,
                  onPressed: tiklanilanOgrenciIDsi == null ? null : () {
                    if (_formKey.currentState.validate()) {
                      _ogrenciGuncelle(Ogrenci.withId(tiklanilanOgrenciIDsi, _controller.text, aktiflik == true ? 1 : 0));
                    }
                  },
                ),
                RaisedButton(
                  child: Text("Tüm Tabloyu Sil"),
                  color: Colors.red,
                  onPressed: () {
                    _tumTabloyuTemizle();
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: tumOgrencilerListesi.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: tumOgrencilerListesi[index].aktif == 1
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                      child: ListTile(
                        onTap: (){
                          setState(() {
                            _controller.text = tumOgrencilerListesi[index].isim;
                            aktiflik = tumOgrencilerListesi[index].aktif == 1 ? true : false;
                            tiklanilanOgrenciIndeksi = index;
                            tiklanilanOgrenciIDsi = tumOgrencilerListesi[index].id;
                          });
                        },
                        title: Text(tumOgrencilerListesi[index].isim),
                        subtitle:
                            Text(tumOgrencilerListesi[index].id.toString()),
                        trailing: GestureDetector(
                          onTap: () {
                            _ogrenciSil(tumOgrencilerListesi[index].id, index);
                          },
                          child: Icon(Icons.delete),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _ogrenciEkle(Ogrenci ogrenci) async {
    var eklenenYeniOgrencininIDsi = await _databaseHelper.ogrenciEkle(ogrenci);
    ogrenci.id = eklenenYeniOgrencininIDsi;
    debugPrint("eklenen : " + ogrenci.toString());
    if (eklenenYeniOgrencininIDsi > 0) {
      setState(() {
        tumOgrencilerListesi.insert(0, ogrenci);
      });
    }
  }

  void _tumTabloyuTemizle() async {
    var silinenElemanSayisi = await _databaseHelper.tumOgrenciTablosunuSil();
    if (silinenElemanSayisi > 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(silinenElemanSayisi.toString() + " kayıt silindi"),
      ));
      setState(() {
        tumOgrencilerListesi.clear();
      });
    }
    tiklanilanOgrenciIDsi = null;
  }

  void _ogrenciSil(
      int dbdenSilmeyeYarayacakID, int listedenSilmeyeYarayacakIndex) async {
    var sonuc = await _databaseHelper.ogrenciSil(dbdenSilmeyeYarayacakID);
    if (sonuc == 1) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(
          seconds: 2,
        ),
        content: Text(" kayıt silindi"),
      ));

      setState(() {
        tumOgrencilerListesi.removeAt(listedenSilmeyeYarayacakIndex);
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text("Silerken hata cıktı"),
      ));
    }
    tiklanilanOgrenciIDsi = null;
  }

  void _ogrenciGuncelle(Ogrenci ogrenci) async{
    var sonuc = await _databaseHelper.ogrenciGuncelle(ogrenci);
    if(sonuc == 1){
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(" kayıt güncellendi"),
      ));

      setState(() {
        tumOgrencilerListesi[tiklanilanOgrenciIndeksi] = ogrenci;
      });
    }
  }
}
