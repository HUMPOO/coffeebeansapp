import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'coffee_bean_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Beans App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submitAuthForm() async {
    var result = await _authService.signIn(
        _emailController.text.trim(), _passwordController.text.trim());
    if (result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(role: result['role']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Authentication failed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAuthForm,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String role;

  HomePage({required this.role});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CoffeeBeanService _coffeeBeanService = CoffeeBeanService();
  List<Map<String, dynamic>> _coffeeBeanList = [];

  @override
  void initState() {
    super.initState();
    _loadCoffeeBeans();
  }

  Future<void> _loadCoffeeBeans() async {
    var data = await _coffeeBeanService.fetchCoffeeBeans();
    setState(() {
      _coffeeBeanList = data;
    });
  }

  void _addCoffeeBean() async {
    if (widget.role == 'admin') {
      await _coffeeBeanService.addCoffeeBean({
        'name': 'New Coffee Bean',
        'price': '15.99',
        'quantity': '50',
        'description': 'Premium coffee beans.',
      });
      _loadCoffeeBeans();
    }
  }

  void _deleteCoffeeBean(String id) async {
    if (widget.role == 'admin') {
      await _coffeeBeanService.deleteCoffeeBean(id);
      _loadCoffeeBeans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Beans List'),
        actions: [
          if (widget.role == 'admin')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addCoffeeBean,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _coffeeBeanList.length,
        itemBuilder: (context, index) {
          var bean = _coffeeBeanList[index];
          return ListTile(
            title: Text(bean['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: \$${bean['price']}'),
                Text('Quantity: ${bean['quantity']} kg'),
                Text(bean['description']),
              ],
            ),
            trailing: widget.role == 'admin'
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteCoffeeBean(bean['id']),
                  )
                : null,
          );
        },
      ),
    );
  }
}
