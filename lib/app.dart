import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nyay Report',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey.shade50,
          fontFamily: 'Roboto',
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
