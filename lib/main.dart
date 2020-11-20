import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
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

  Widget getBaseAmountInputField() {
    return TextField(
      onSubmitted: (value) => convertCurrency(),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: 'Base Amount'),
      controller: baseAmountController,
    );
  }

  Widget getTargetAmountOutputField() {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: 'Target Amount'),
      controller: targetAmountController,
    );
  }

  Widget getDrpDwnBttnBaseCur() {
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
          convertCurrency();
        });
      },
    );
  }

  Widget getDrpDwnBttnTargetCur() {
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
          convertCurrency();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Currency Converter"),
      ),
      body: Center(
        child: Column(
          children: [
            getDrpDwnBttnBaseCur(),
            getBaseAmountInputField(),
            getDrpDwnBttnTargetCur(),
            getTargetAmountOutputField()
          ],
        ),
      ),
    );
  }

  void convertCurrency() {
    //Case: BaseAmount field is empty.
    if (baseAmountController.text.isEmpty) {
      targetAmountController.text = '';
      return;
    }
    if (baseCurrencyName == targetCurrencyName) {
      targetAmountController.text = baseAmountController.text;
      return;
    }
    makeApiCall();
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
  void calcAndShowResultInDartPad(String jsonString) {
    Map<String, dynamic> respAsJson = jsonDecode(jsonString);
    double rate = getRateInDartPad(respAsJson);
    double newTargetAmount = calcTargetAmount(rate);
    setTargetAmount(newTargetAmount);
  }

  double getRateInDartPad(Map<String, dynamic> respAsJson) {
    double result = -1;
    Map<String, dynamic> rates = respAsJson['rates'];
    if (baseCurrencyName != "EUR")
      result = rates[targetCurrencyName] / rates[baseCurrencyName];
    else
      result = rates[targetCurrencyName];
    return result;
  }

  void makeApiCall() {
    String reqUrl =
        'https://api.exchangeratesapi.io/latest?base=$baseCurrencyName';
    Future<http.Response> resp = http.get(reqUrl);
    resp.then((value) => processResp(value));
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
