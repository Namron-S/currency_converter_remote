import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
/*
Since dartpad doesn't support importing the http package, we use isntead of a real api call (line 55) a dummy-json-string (line 58).
If you run this web-app on your local machine, uncomment lines 9, 55, 261-274, and comment out line 58.
*/
// Uncomment this line, if running on a local machine with internet connection.
// Import 'package:http/http.dart' as http; 

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
    //Case: BaseAmount field is empty.
    if (baseAmountController.text.isEmpty) {
      targetAmountController.text = '';
      return;
    }
    if (baseCurrencyName == targetCurrencyName) {
      targetAmountController.text = baseAmountController.text;
      return;
    }
    //Uncomment this line when running on a local machine with internet connection.
    //makeApiCall();

    //When running in dartpad:
    calcAndShowResultInDartPad(jsonStrInDartPad);
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
              DropdownButton<String>(
                value: baseCurrencyName,
                items: listCurNames.map((String curName) {
                  return new DropdownMenuItem<String>(
                    value: curName,
                    child: createCurrListTile(curName),
                  );
                }).toList(),
                onChanged: (String newCurName) {
                  setState(() {
                    baseCurrencyName = newCurName;
                    convertCurrency();
                  });
                },
              ),
              DropdownButton<String>(
                value: targetCurrencyName,
                items: listCurNames.map((String curName) {
                  return DropdownMenuItem<String>(
                    value: curName,
                    child: createCurrListTile(curName),
                  );
                }).toList(),
                onChanged: (String newCurName) {
                  setState(() {
                    targetCurrencyName = newCurName;
                    convertCurrency();
                  });
                },
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

  Widget createCurrListTile(String currName) {
    return Container(
      height: 60,
      width: 160,
      //color: Colors.lightBlue,
      child: ListTile(
        leading: Text(currName),
        title: Text(mapCurLongNames[currName]),
      ),
    );
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

  final String jsonStrInDartPad =
      '{"rates":{"CAD":1.5524,"HKD":8.7466,"ISK":148.64,"PHP":57.645,"DKK":7.4727,"HUF":338.37,"CZK":26.203,"AUD":1.7674,"RON":4.8213,"SEK":10.8945,"IDR":16434.0,"INR":83.468,"BRL":5.5081,"RUB":84.0284,"HRK":7.6,"JPY":116.84,"THB":35.586,"CHF":1.0549,"SGD":1.5779,"PLN":4.3599,"BGN":1.9558,"TRY":7.0361,"CNY":7.8877,"NOK":11.3682,"NZD":1.8173,"ZAR":18.4447,"USD":1.124,"MXN":24.8028,"ILS":4.0909,"GBP":0.88623,"KRW":1359.4,"MYR":4.7944},"base":"EUR","date":"2020-03-12"}';

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

//Uncomment following lines if you run the app on a local machine with internet connection:

//   void makeApiCall() {
//     String reqUrl =
//         'https://api.exchangeratesapi.io/latest?base=$baseCurrencyName';
//     Future<http.Response> resp = http.get(reqUrl);
//     resp.then((value) => processResp(value));
//   }

//     void processResp(http.Response resp) {
//     if (resp.statusCode != 200) {
//       showAlertDialog(context, 'Failed to load currency rates.');
//     } else {
//       calcAndShowResult(resp.body);
//     }
//   }

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
