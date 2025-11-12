import 'package:flutter/material.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Store"), centerTitle: true),
      body: Center(
          child:
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Book Store"),
              ]
          )
      ),
    );
  }
}
