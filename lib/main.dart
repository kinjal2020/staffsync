import 'package:carparking/Chat/provider/chat_provider.dart';
import 'package:carparking/Home/Employee/provider/employee_provider.dart';
import 'package:carparking/Home/HomeScreen/home_screen.dart';
import 'package:carparking/Home/Profile/provider/profile_provider.dart';
import 'package:carparking/Home/Secret%20Locker/provider/secret_locker_provider.dart';
import 'package:carparking/Home/Task/provider/task_provider.dart';
import 'package:carparking/LeaveRequest/provider/leave_provider.dart';
import 'package:carparking/ShiftDetails/screen/shift_details_screen.dart';
import 'package:carparking/util/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Auth/provider/auth_provider.dart';
import 'Chat/screen/chat_list_screen.dart';
import 'Chat/screen/chat_screen.dart';
import 'Home/HomeScreen/provider/holiday_provider.dart';

import 'LeaveRequest/screen/leave_request_screen.dart';
import 'PayRoll/screen/payroll_screen.dart';

import 'package:carparking/IntroScreen/intro_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => EmployeeProvider()),
        ChangeNotifierProvider(create: (context) => HolyDayProvider()),
        ChangeNotifierProvider(create: (context) => LeaveProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => SecretLockerProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: Consumer<AuthenticationProvider>(
          builder: (context, authProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StaffSync',
          theme: ThemeData(
            fontFamily: 'Gantari',
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            useMaterial3: true,
          ),
          // home: SecretLockerScreen() ,

          home: authProvider.user == null ? IntroScreen() : MyHomePage(),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String role = '';
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[];

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  getData() async {

    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    SharedPreferences pref = await SharedPreferences.getInstance();

    authProvider.role = pref.getString('role') ?? '';
    print(authProvider.role);
    print(authProvider.role);
    print(authProvider.role);
    await authProvider.getLoginUserInfo();
    String room =authProvider.doc!.docs.isEmpty?'':
        chatRoomId(authProvider.doc!.docs[0]['employeeFirstName'], 'tester');
    setState(() {});
    _widgetOptions = [
      HomeScreen(),
      PayRollScreen(),
      (authProvider.role == 'emp') ? ShiftDetailsScreen() : LeaveRequestScreen(),
      (authProvider.role == 'emp')
          ? ChatScreen(
              empName: 'HR',
              chatRoomId: room,
            )
          : ChatListScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
    Provider.of<AuthenticationProvider>(context, listen: false);
    return Scaffold(
      body: (authProvider.role == '')
          ? Center(
              child: CircularProgressIndicator(
              color: primaryColor,
            ))
          : Center(
              child: (_widgetOptions.isEmpty)?Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  )):_widgetOptions.elementAt(_selectedIndex),
            ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: grayColor,
        unselectedLabelStyle: TextStyle(color: grayColor, fontSize: 14),
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            label: 'PayRoll',
          ),
          BottomNavigationBarItem(
            icon: (authProvider.role == 'emp')
                ? Icon(Icons.quick_contacts_mail_outlined)
                : Icon(Icons.logout),
            label: (authProvider.role == 'emp') ? 'Shift' : 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_chat_unread_outlined),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
