import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../controllers/Language_Provider.dart';
import '../controllers/user_controller.dart';
import '../models/Localization.dart';

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        title:  Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            String mostPopularText = languageProvider.isEnglish
                ? Localization.en['myWallet']!
                : Localization.ar['myWallet']!;

            return Text(
              mostPopularText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                fontFamily: 'PlayfairDisplay',
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletBalanceCard(),
              SizedBox(height: 20),
              SendGiftCard(onGiftSent: () {
                final walletBalanceCardState = context.findAncestorStateOfType<_WalletBalanceCardState>();
                walletBalanceCardState?._fetchBalance(); // Refresh the balance
              }),
              SizedBox(height: 20),
              RecentTransactionsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletBalanceCard extends StatefulWidget {
  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard> {
  int   _balance = 0;
  int _points = 0;
  int _factor = 10;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchPointsAndFactor();
  }

  void _fetchBalance() async {
    try {
      int balance = await UserController.getBalance();
      setState(() {
        _balance = balance;
      });
    } catch (e) {
      print('Failed to fetch balance: $e');
    }
  }

  void _fetchPointsAndFactor() async {
    try {
      final token = UserController.getToken();
      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/wallet/getUserPointsWithFactor'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _points = data['points'] ?? 0;
          _factor = data['factor'] ?? 10;
        });
      } else {
        throw Exception('Failed to load points and factor');
      }
    } catch (e) {
      print('Failed to fetch points and factor: $e');
    }
  }

  void _showConversionDialog() async {
    if (_points == 0) {
      _showNoPointsDialog();
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConversionDialog(points: _points, factor: _factor);
      },
    );

    if (result == 'success') {
      _fetchBalance(); // Refresh the balance after conversion
      _fetchPointsAndFactor(); // Refresh points and factor after conversion
    }
  }

  void _showNoPointsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Points'),
          content: Text('You have no points to convert.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$$_balance',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz),
                color: Color(0xFF00C853),
                onPressed: _showConversionDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }}

class ConversionDialog extends StatefulWidget {
  final int points;
  final int factor;

  ConversionDialog({required this.points, required this.factor});

  @override
  _ConversionDialogState createState() => _ConversionDialogState();
}

class _ConversionDialogState extends State<ConversionDialog> {
  int _selectedPoints = 0;
  bool _isLoading = false;

  Future<void> _convertPoints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = UserController.getToken();
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/wallet/exchangePoints'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "points": _selectedPoints,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSuccessDialog(data['message']);
      } else {
        _showErrorDialog('Failed to convert points');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop('success'); // Close the ConversionDialog and return 'success'
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Convert Points to Money'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Points: ${widget.points}'),
          Slider(
            value: _selectedPoints.toDouble(),
            min: 0,
            max: widget.points.toDouble(),
            divisions: widget.points,
            label: _selectedPoints.toString(),
            onChanged: (value) {
              setState(() {
                _selectedPoints = value.toInt();
              });
            },
          ),
          Text('Money: \$${_selectedPoints * widget.factor}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _convertPoints,
          child: _isLoading ? CircularProgressIndicator() : Text('Convert'),
        ),
      ],
    );
  }
}









class SendGiftCard extends StatefulWidget {

  final VoidCallback onGiftSent;

  SendGiftCard({required this.onGiftSent});
  @override
  _SendGiftCardState createState() => _SendGiftCardState();
}

class _SendGiftCardState extends State<SendGiftCard> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<Map<String, dynamic>> _followers = [];
  Map<String, dynamic>? _selectedFollower;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  void _fetchFollowers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = UserController.getToken();
      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/users/getFollowers'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        setState(() {
          _followers = List<Map<String, dynamic>>.from(data['Followers']);
        });
      } else {
        throw Exception('Failed to load followers');
      }
    } catch (e) {
      print('Failed to fetch followers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendGift() async {
    if (_recipientController.text.isEmpty || _amountController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = UserController.getToken();
      final response = await http.post(
        Uri.parse('http://192.168.7.39:8000/api/wallet/gift'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "receiverId": _selectedFollower!['id'],
          "quantity": int.parse(_amountController.text),
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        _showSuccessDialog(data['message']);
        widget.onGiftSent(); // Call the callback to refresh the balance
      } else {
        _showErrorDialog(data['message']);
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _recipientController.clear();
                _amountController.clear();
                setState(() {
                  _selectedFollower = null;
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFollowersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Follower'),
          content: _isLoading
              ? CircularProgressIndicator()
              : Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _followers.length,
              itemBuilder: (BuildContext context, int index) {
                final follower = _followers[index];
                return ListTile(
                  title: Text('${follower['first_name']} ${follower['last_name']}'),
                  onTap: () {
                    setState(() {
                      _selectedFollower = follower;
                      _recipientController.text = '${follower['first_name']} ${follower['last_name']}';
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                String mostPopularText = languageProvider.isEnglish
                    ? Localization.en['sendGift']!
                    : Localization.ar['sendGift']!;

                return Text(
                  mostPopularText,
                  style: TextStyle(
                    fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                  ),
                );
              },
            ),


            SizedBox(height: 10),
            TextField(
              controller: _recipientController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Recipient',
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              onTap: _showFollowersDialog,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendGift,
                child: _isLoading ? CircularProgressIndicator() :  Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    String mostPopularText = languageProvider.isEnglish
                        ? Localization.en['send']!
                        : Localization.ar['send']!;

                    return Text(
                      mostPopularText,
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        // fontFamily: 'PlayfairDisplay',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}













class RecentTransactionsCard extends StatefulWidget {
  @override
  _RecentTransactionsCardState createState() => _RecentTransactionsCardState();
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecentTransactions();
  }

  void _fetchRecentTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = UserController.getToken();
      final response = await http.get(
        Uri.parse('http://192.168.7.39:8000/api/wallet/recentTransactions'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = data['All transactions'] as List<dynamic>;

        setState(() {
          _transactions = transactions.map((transaction) {
            return {
              'id': transaction['id'],
              'quantity': transaction['quantity'],
              'state': transaction['state'],
              'date': 'N/A',
              // Adjust this if you have date information
              'description': 'Transaction #${transaction['id']}',
              // Adjust description if needed
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load recent transactions');
      }
    } catch (e) {
      print('Failed to fetch recent transactions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                String mostPopularText = languageProvider.isEnglish
                    ? Localization.en['recentTransactions']!
                    : Localization.ar['recentTransactions']!;

                return Text(
                  mostPopularText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                );
              },
            ),


            // Text(
            //   'Recent Transactions',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFF333333),
            //   ),
            // ),
            //





            SizedBox(height: 10),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
              height: 180,
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(transaction['description']),
                      subtitle: Text('\$${transaction['quantity']}'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,
                            vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          transaction['state'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}