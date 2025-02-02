import 'package:fitnessapp/user_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'database_handler.dart';
import 'gainmeal.dart';
import 'nextpage.dart';
import 'stepcounter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';


class MyHomepage extends StatefulWidget {
  const MyHomepage({Key? key}) : super(key: key);

  @override
  State<MyHomepage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomepage> {

  TextEditingController emailController = TextEditingController();
  Database? _database;
  @override
  void initState() {
    super.initState();
    // Show email popup after a delay
    Future.delayed(Duration(seconds: 3), () {
      _showEmailPopup();
    });
  }

  void dispose() {
    super.dispose();
  }
  void _showEmailPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('Enter Your Confirm Email', style: TextStyle(color: Colors.purple)),
                content: TextField(
                  controller: emailController,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      String email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        bool emailExists = await checkEmailExists(email);
                        if (emailExists) {
                          sendMail(recipientEmail: emailController.text.toString(),mailMessage: 'u are using gritfit!!!');
                          getcurrentweightgainuser(emailController.text.toString());
                          String Email = emailController.text.toString();
                          String? name = await getNameFromEmail(Email);
                          if (name != null) {
                            Navigator.of(context).pop();
                            prefs.setBool('isFirstTime', false);
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Email not found in the database. Please try again.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close error dialog
                                        emailController.clear();
                                      },
                                      child: Text('Try Again'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text('This E-mail is not same as previous entered E-mail. Please try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close error dialog
                                      emailController.clear();
                                      _showEmailPopup(); // Reopen the original email entering dialog box
                                    }, child: Text('OK Fine'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: Text('Continue', style: TextStyle(color: Colors.purple)),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<bool> checkEmailExists(String email) async {
    // Implement your logic to check if the email exists in the database
    // Return true if the email exists, false otherwise
    _database=await openDB();
    UserRepo userRepo=new UserRepo();
    if(await userRepo.isEmailExists(_database,email)) {

      return true;

    }
    else{
      return false;
    }
    await _database?.close();

  }




  @override
  Widget build(BuildContext context) {
    String? usern=ModalRoute.of(context)?.settings.arguments as String?;
    // Retrieve email from the controller
    String email = emailController.text.toString();

    // Get name asynchronously
    Future<String?> getName() async {
      String error='Dear!!';
      String? name = null;
      if (name == null) {
        String? nam= await getNameFromEmail(email);
        await Future.delayed(Duration(seconds: 1)); //process indicator
        if(nam!=null){
          return nam;
        }
      }
      else{
        return error;
      }
    }
    Future<int?> getAge() async {
      var age=null;
      if (age == null) {
        age= await getAgeFromEmail(email);
        if(age!=null){
          return age;
        }
      }
      else{
        print('age cant fetched');
      }
    }
    Future<int?> getHeight() async {
      var height = null;
      if (height == null) {
        height= await getHeightFromEmail(email);
        if(height!=null){
          return height;
        }
      }
      else{
        print('height cant fetched');
      }
    }
    Future<int?> get_cweight() async {
      var cweight = null;
      if (cweight == null) {
        cweight= await get_cweight_FromEmail(email);
        if(cweight!=null){
          return cweight;
        }
      }
      else{
        print('cweight cant fetched');
      }
    }
    Future<int?> get_gweight() async {
      var gweight = null;
      if (gweight == null) {
        gweight= await get_gweight_FromEmail(email);
        if(gweight!=null){
          return gweight;
        }
      }
      else{
        print('gweight cant fetched');
      }
    }
    Future<String?> getGender() async {
      String? gender = null;
      if (gender == null) {
        gender= await getGenderFromEmail(email);
        if(gender!=null){
          return gender;
        }
      }
      else{
        print('gender cant fetched');
      }
    }
    Future<String?> getActivityLevel() async {
      String error='error!!!!!!!!!!!!!!!!!!!!';
      String? activity_level= null;
      if (activity_level == null) {
        activity_level= await getActivityLevelFromEmail(email);
        if(activity_level!=null){
          return activity_level;
        }
      }
      else{
        return error;
      }
    }
    return FutureBuilder<String?>(
      future: getName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the name, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If there's an error, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If name is fetched successfully, build the UI with the name

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                              title: Text(
                                //  name!=null? 'Hello': 'hello $name',
                                'Hello $usern',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              trailing: Lottie.asset(
                                'assets/images/alien.json',
                                width: 90,
                                height: 150,
                                repeat: true,
                                reverse: true,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.purple,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 30,
                          children: [
                            itemDashboard(
                              'Recipes',
                              'assets/images/.jpg',
                                  () {
                                navigateToPage(page());
                              },
                            ),
                            itemDashboard(
                              'Exercises',
                              'assets/images/ex.jpg',
                                  () {
                                navigateToPage(page());
                              },
                            ),
                            itemDashboard(
                              'Water',
                              'assets/images/dink.jpg',
                                  () {
                                navigateToPage(page());
                              },
                            ),
                            itemDashboard(
                              'Meal',
                              'assets/images/eaat.png',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => meal(),
                                    settings: RouteSettings(arguments: emailController.text.toString()),
                                  ),
                                );
                              },
                            ),
                            itemDashboard(
                              'StepCounter',
                              'assets/images/walk.jpg',
                                  () {
                                navigateToPage(step());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                Positioned(
                  top: 27,
                  right: 4,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.exit_to_app_sharp),
                    onPressed: () {
                      showLogoutDialog();
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CurvedNavigationBar(
              backgroundColor: Colors.white,
              color: Colors.purple,
              animationDuration: Duration(microseconds: 300),
              items: [
                Icon(Icons.home, color: Colors.white),
                Icon(Icons.message_outlined, color: Colors.white),

                Icon(Icons.info, color: Colors.white),
              ],
              onTap: (index) {
                if (index == 1) {
                  _showMessageOptions(); // Show message options when message icon is tappeds
                } else {
                  // Handle navigation for other icons
                  switch (index) {
                    case 0:
                      navigateToPage(page());
                      break;
                    case 2:
                      navigateToPage(page());
                      break;
                  }
                }
              },
            ),
          );
        }
      },
    );
  }
  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToChatScreen(context, isChatbot: true);
                },
                title: Text('Chat with Chatbot'),
                leading: Icon(Icons.chat),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToChatScreen(context, isChatbot: false);
                },
                title: Text('Chat with Dietitian'),
                leading: Icon(Icons.people),
              ),
            ],
          ),
        );
      },
    );
  }



  void _navigateToChatScreen(BuildContext context, {required bool isChatbot}) {
    // Implement navigation logic to the chat screen based on isChatbot
    // For example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ChatScreen(isChatbot: isChatbot)),
    // );
  }
  Widget itemDashboard(String title, String imagePath, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 5),
                color: Theme.of(context).primaryColor.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(imagePath, width: 90, height: 70),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );


  void navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exit'),
          content: Text('Are you sure you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Clear shared preferences data
                clearSharedPreferences();
                // Navigate to the next page
                navigateToNextPage();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data stored in SharedPreferences
  }

  void navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page()),
    );
  }

  Future<Database?> openDB() async{
    _database=await DatabaseHandler().openDB();

    return _database;
  }
  Future<void> getcurrentweightgainuser(String email)async{
    _database=await openDB();
    UserRepo userRepo=new UserRepo();
    await userRepo.getcurrentweightgainuser(_database, email);
    await _database?.close();
  }
  Future<String?> getNameFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['name'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? name;
    if (result.isNotEmpty) {
      name = result[0]['name'];
    }
    await _database!.close();
    return name;
  }
  Future<int> getAgeFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['age'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var age;
    if (result.isNotEmpty) {
      age = result[0]['age'];
    }
    await _database!.close();
    return age;
  }
  Future<int> getHeightFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['height'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var height;
    if (result.isNotEmpty) {
      height = result[0]['height'];
    }
    await _database!.close();
    return height;
  }
  Future<int> get_cweight_FromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['cweight'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var cweight;
    if (result.isNotEmpty) {
      cweight = result[0]['cweight'];
    }
    await _database!.close();
    return cweight;
  }
  Future<int> get_gweight_FromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['gweight'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var gweight;
    if (result.isNotEmpty) {
      gweight = result[0]['gweight'];
    }
    await _database!.close();
    return gweight;
  }
  Future<String?> getGenderFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['gender'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? gender;
    if (result.isNotEmpty) {
      gender = result[0]['gender'];
    }
    await _database!.close();
    return gender;
  }
  Future<String?> getActivityLevelFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['activity_level'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? activity_level;
    if (result.isNotEmpty) {
      activity_level = result[0]['activity_level'];
    }
    await _database!.close();
    return activity_level;
  }

  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = emailController.text.toString();
    // change your password here
    String password = 'uujedrnwaxeikqzu';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Message: $mailMessage';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail is sent on your account.'),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        print('error in sending email');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong ,cant send email'),
          ),
        );
      }
    }
  }
}