import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Currency Converter',
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

  Widget getBaseAmountInputField(BuildContext ctx) {
    return Container(
      width: 200,
      child: TextField(
        onSubmitted: (value) => convertCurrency(ctx),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Base Amount',
        ),
        controller: baseAmountController,
      ),
    );
  }

  Widget getTargetAmountOutputField() {
    return Container(
      width: 200,
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
            border: OutlineInputBorder(), labelText: 'Target Amount'),
        controller: targetAmountController,
      ),
    );
  }

  Widget getDrpDwnBttnBaseCur(BuildContext ctx) {
    return DropdownButton<String>(
      value: baseCurrencyName,
      items: listCurNames.map((String curName) {
        return new DropdownMenuItem<String>(
          value: curName,
          child: Text('$curName, ${mapCurLongNames[curName]}'),
        );
      }).toList(),
      onChanged: (String newCurName) {
        setState(() {
          baseCurrencyName = newCurName;
          convertCurrency(ctx);
        });
      },
    );
  }

  Widget getDrpDwnBttnTargetCur(BuildContext ctx) {
    return DropdownButton<String>(
      value: targetCurrencyName,
      items: listCurNames.map((String curName) {
        return DropdownMenuItem<String>(
          value: curName,
          child: Text('$curName, ${mapCurLongNames[curName]}'),
        );
      }).toList(),
      onChanged: (String newCurName) {
        setState(() {
          targetCurrencyName = newCurName;
          convertCurrency(ctx);
        });
      },
    );
  }

  Widget _buildVerticalLayout(BuildContext ctx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            margin: EdgeInsets.only(bottom: 10),
            child: getDrpDwnBttnBaseCur(ctx)),
        Container(
            margin: EdgeInsets.only(bottom: 20),
            child: getBaseAmountInputField(ctx)),
        Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            margin: EdgeInsets.only(bottom: 10),
            child: getDrpDwnBttnTargetCur(ctx)),
        getTargetAmountOutputField(),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext ctx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getDrpDwnBttnBaseCur(ctx),
            getDrpDwnBttnTargetCur(ctx)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: getBaseAmountInputField(ctx),
            ),
            Flexible(
              child: getTargetAmountOutputField(),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Currency Converter"),
      ),
      body: Center(
        child: orientation == Orientation.portrait
            ? _buildVerticalLayout(context)
            : _buildHorizontalLayout(context),
      ),
    );
  }

  void convertCurrency(BuildContext ctx) {
    //Case: BaseAmount field is empty.
    if (baseAmountController.text.isEmpty) {
      targetAmountController.text = '';
      return;
    }
    if (baseCurrencyName == targetCurrencyName) {
      targetAmountController.text = baseAmountController.text;
      return;
    }
    makeApiCall(ctx);
  }

  void calcAndShowResult(String jsonString) {
    Map<String, dynamic> respAsJson = jsonDecode(jsonString);
    double rate = getRate(respAsJson);
    double newTargetAmount = calcTargetAmount(rate);
    setTargetAmount(newTargetAmount);
  }

  void setTargetAmount(double newTargetAmount) {
    targetAmountController.text =
        newTargetAmount.toStringAsFixed(2); //two fraction digits only
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

  final Map<String, String> mapCurLongNames = {
    "EUR": "Euro",
    "USD": "US Dollar",
    "GBP": "Pound Sterling",
    "CAD": "Canadian Dollar",
    "AUD": "Australian Dollar",
    "HKD": "Hong Kong Dollar",
    "ISK": "Iceland Krona",
    "PHP": "Philippine Peso",
    "DKK": "Danish Krone",
    "HUF": "Forint",
    "CZK": "Czech Koruna",
    "RON": "New Leu",
    "SEK": "Swedish Krona",
    "IDR": "Rupiah",
    "INR": "Indian Rupee",
    "BRL": "Brazilian Real",
    "RUB": "Russian Rubble",
    "HRK": "Croatian Kuna",
    "JPY": "Yen",
    "THB": "Baht",
    "CHF": "Swiss Franc",
    "MYR": "Malaysian Ringgit",
    "BGN": "Bulgarian Lev",
    "TRY": "Turkish Lira",
    "CNY": "Yuan Renminbi",
    "NOK": "Norwegian Krone",
    "NZD": "New Zeeland Dollar",
    "ZAR": "Rand",
    "MXN": "Mexican Peso",
    "SGD": "Singapore Dollar",
    "ILS": "New Israeli Sheqel",
    "KRW": "Won",
    "PLN": "Zloty",
  };
  final List<String> listCurNames = [
    "EUR", //Euro
    "USD", //US Dollar
    "GBP", //Pound Sterling
    "CAD", //Canadian Dollar
    "AUD", //Australian Dollar
    "ISK", //Iceland Krona
    "PHP", //Philippine Peso
    "DKK", //Danish Krone
    "HUF", //Forint
    "CZK", //Czech Koruna
    "RON", //New Leu
    "SEK", //Swedish Krona
    "IDR", //Rupiah
    "INR", //Indian Rupee
    "BRL", //Brazilian Real
    "RUB", // Russian Rubble
    "HRK", //Croatian Kuna
    "JPY", //Yen
    "THB", //Baht
    "CHF", //Swiss Franc
    "MYR", //Malaysian Ringgit
    "BGN", //Bulgarian Lev
    "TRY", //Turkish Lira
    "CNY", //Yuan Renminbi
    "NOK", //Norwegian Krone
    "NZD", //New Zeeland Dollar
    "ZAR", //Rand
    "MXN", //Mexican Peso
    "SGD", //Singapore Dollar
    "ILS", //New Israeli Sheqel
    "KRW", //Won
    "PLN", //Zloty
    "HKD", //Hong Kong Dollar
  ];

  void makeApiCall(BuildContext ctx) {
    String reqUrl =
        'https://api.exchangeratesapi.io/latest?base=$baseCurrencyName';
    Future<http.Response> resp = http.get(reqUrl);
    resp
        .then((value) => processResp(value))
        .catchError((error) => handleError(error, ctx));
  }

  void handleError(error, BuildContext context) {
    if (error.runtimeType.toString() == 'SocketException') {
      targetAmountController.clear();
      showAlertDialog(
          context, 'Networkerror. Please check your networkconnection.');
    }
  }

  void processResp(http.Response resp) {
    if (resp.statusCode != 200) {
      showAlertDialog(context, 'Failed to load currency rates.');
    } else {
      calcAndShowResult(resp.body);
    }
  }
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
