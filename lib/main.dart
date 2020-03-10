import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//TODO: editor shortcut fürs auskommentieren belegen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'simple currency converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State {
  String baseCurrencyName = 'EUR';
  String targetCurrencyName = 'USD';
  final baseAmountController = TextEditingController();
  final targetAmountController = TextEditingController();

  void convertCurrency() {
    //case: BaseAmount field is empty
    if (baseAmountController.text.isEmpty) {
      targetAmountController.text = '';
      return;
    }
    //case: baseCurrency == target Currency
    if (baseCurrencyName == targetCurrencyName) {
      targetAmountController.text = baseAmountController.text;
      return;
    }
    String reqUrl =
        'https://api.exchangeratesapi.io/latest?base=$baseCurrencyName';
    Future<http.Response> resp = http.get(reqUrl);
    resp.then((value) => processResp(value));
  }

  void processResp(http.Response resp) {
    if (resp.statusCode != 200) {
      showAlertDialog(context, 'Failed to load currency rates.');
    } else {
      debugPrint(resp.body);
      Map<String, dynamic> respAsJson = jsonDecode(resp.body);
      double rate = getRate(respAsJson);
      double newTargetAmount = calcTargetAmount(rate);
      setTargetAmount(newTargetAmount);
    }
  }

  void setTargetAmount(double newTargetAmount) {
    targetAmountController.text = newTargetAmount.toString();
  }

  double calcTargetAmount(double rate) {
    double baseAmount = double.parse(baseAmountController.text);
    return baseAmount * rate;
  }

  double getRate(Map<String, dynamic> respAsJson) {
    double result = -1;
    Map<String, dynamic> rates = respAsJson['rates'];
    result = rates[targetCurrencyName];
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("A simple currency converter"),
      ),
      body: Center(
        child: Table(
          defaultColumnWidth: FractionColumnWidth(0.45),
          children: <TableRow>[
            TableRow(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: baseCurrencyName,
                  items: listCurNames.map((String curName) {
                    return new DropdownMenuItem<String>(
                      value: curName,
                      child: new Text(curName),
                    );
                  }).toList(),
                  onChanged: (String newCurName) {
                    setState(() {
                      baseCurrencyName = newCurName;
                      convertCurrency();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: targetCurrencyName,
                  items: listCurNames.map((String curName) {
                    return new DropdownMenuItem<String>(
                      value: curName,
                      child: new Text(curName),
                    );
                  }).toList(),
                  onChanged: (String newCurName) {
                    setState(() {
                      targetCurrencyName = newCurName;
                      convertCurrency();
                    });
                  },
                ),
              ),
            ]),
            TableRow(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onSubmitted: (value) => convertCurrency(),
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Base Amount'),
                  controller: baseAmountController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Target Amount'),
                  controller: targetAmountController,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  final List<String> listCurNames = [
    "CAD",
    "HKD",
    "ISK",
    "PHP",
    "DKK",
    "HUF",
    "CZK",
    "GBP",
    "RON",
    "SEK",
    "IDR",
    "INR",
    "BRL",
    "RUB",
    "HRK",
    "JPY",
    "THB",
    "CHF",
    "EUR",
    "MYR",
    "BGN",
    "TRY",
    "CNY",
    "NOK",
    "NZD",
    "ZAR",
    "USD",
    "MXN",
    "SGD",
    "AUD",
    "ILS",
    "KRW",
    "PLN",
  ];
}

Future<void> showAlertDialog(BuildContext context, String msg) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Info'),
        content: Text(msg),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
