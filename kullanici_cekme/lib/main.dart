import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Users',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RandomUsersScreen(),
    );
  }
}

class RandomUsersScreen extends StatefulWidget {
  @override
  _RandomUsersScreenState createState() => _RandomUsersScreenState();
}

class _RandomUsersScreenState extends State<RandomUsersScreen> {
  List<User> _users = [];
  int _userCount = 10; // Default olarak 10 kullanıcı çekiyoruz.

  @override
  void initState() {
    super.initState();
    fetchRandomUsers(_userCount);
  }

  Future<void> fetchRandomUsers(int count) async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/?results=$count'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<User> users = [];

      for (var userJson in jsonData['results']) {
        final user = User.fromJson(userJson);
        users.add(user);
      }

      setState(() {
        _users = users;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  void _onUserCountChanged(double value) {
    setState(() {
      _userCount = value.toInt();
    });
    fetchRandomUsers(_userCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Kullanıcı Sayısı: $_userCount',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Slider(
            value: _userCount.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: _onUserCountChanged,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.pictureUrl),
                  ),
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cinsiyet: ${user.gender}'),
                      Text('Email: ${user.email}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  final String firstName;
  final String lastName;
  final String gender;
  final String email;
  final String pictureUrl;

  User({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.pictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final picture = json['picture'];
    return User(
      firstName: name['first'],
      lastName: name['last'],
      gender: json['gender'],
      email: json['email'],
      pictureUrl: picture['large'],
    );
  }
}
