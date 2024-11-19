import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "User";
  String email = "user@example.com";
  int userAge = 29;
  List<String> interests = [];
  bool mediaComplete = false;
  double profileCompletion = 0.0;

  final List<String> predefinedInterests = [
    "Music",
    "Sports",
    "Travel",
    "Movies",
    "Cooking",
    "Reading",
  ];

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "user@example.com";
      });

      try {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await userDocRef.get();
        if (doc.exists) {
          setState(() {
            userName = doc['userName'] ?? "User";
            userAge = doc['userAge'] ?? 0;
            interests = List<String>.from(doc['interests'] ?? []);
            mediaComplete = doc['mediaComplete'] ?? false;
          });
        } else {
          await userDocRef.set({
            'userName': user.displayName ?? "User",
            'userAge': 0,
            'interests': [],
            'mediaComplete': false,
          });

          setState(() {
            userName = user.displayName ?? "User";
            userAge = 0;
            interests = [];
            mediaComplete = false;
          });
        }

        calculateProfileCompletion();
      } catch (e) {
        print("Failed to load or create profile: $e");
      }
    }
  }

  void calculateProfileCompletion() {
    int completedSections = 0;
    if (userName.isNotEmpty && userName != "User") completedSections++;
    if (userAge > 0) completedSections++;
    if (interests.isNotEmpty) completedSections++;

    setState(() {
      profileCompletion = completedSections / 3;
    });
  }

  Future<void> updateProfileField(String field, dynamic value) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        field: value,
      });
      setState(() {
        switch (field) {
          case 'userName':
            userName = value;
            break;
          case 'userAge':
            userAge = value;
            break;
          case 'interests':
            interests = List<String>.from(value);
            break;
        }
      });
      calculateProfileCompletion();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        loadCurrentUser();
      });
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarLetter = email.isNotEmpty ? email[0].toUpperCase() : "U";
    final loc = AppLocalizations.of(context);

    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: user == null
          ? Center(
              child: ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Login with Google"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 250, 246, 247),
                    Color.fromARGB(255, 255, 254, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (profileCompletion == 0)
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: const CircleAvatar(radius: 45),
                                )
                              else
                                SizedBox(
                                  width: 104,
                                  height: 104,
                                  child: CircularProgressIndicator(
                                    value: profileCompletion,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.grey[300],
                                    color:
                                        const Color.fromARGB(255, 226, 82, 255),
                                  ),
                                ),
                              if (profileCompletion > 0)
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor:
                                      const Color.fromARGB(255, 247, 110, 240),
                                  child: Text(
                                    avatarLetter,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 226, 82, 255),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    loc?.completionText(
                                          (profileCompletion * 100).toInt(),
                                        ) ??
                                        "{percentage}% Complete",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          buildGlassContainer(
                            child: profileCompletion == 0
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(height: 24, width: 100),
                                  )
                                : Text(
                                    "$userName, $userAge",
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                          buildGlassContainer(
                            child: profileCompletion == 0
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(height: 16, width: 150),
                                  )
                                : Text(
                                    email,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 188, 6, 224)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildEditableProfileDetail(
                            loc?.nameLabel ?? "Name",
                            userName,
                            "userName",
                          ),
                          buildEditableProfileDetail(
                            loc?.ageLabel ?? "Age",
                            userAge.toString(),
                            "userAge",
                          ),
                          buildInterestsSelection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildGlassContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 243, 243).withOpacity(1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 245, 244, 244).withOpacity(1),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget buildEditableProfileDetail(String label, String value, String field) {
    final loc = AppLocalizations.of(context);

    return buildGlassContainer(
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
              color: Color.fromARGB(255, 217, 64, 255),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value.isNotEmpty ? value : loc?.notSet ?? "Not set"),
        trailing:
            const Icon(Icons.edit, color: Color.fromARGB(255, 184, 68, 204)),
        onTap: () async {
          final newValue = await openEditDialog(label, value);
          if (newValue != null && newValue != value) {
            updateProfileField(
                field, field == "userAge" ? int.parse(newValue) : newValue);
          }
        },
      ),
    );
  }

  Widget buildInterestsSelection() {
    final loc = AppLocalizations.of(context);

    return buildGlassContainer(
      child: ExpansionTile(
        title: Text(
          loc?.interestsLabel ?? "Interests",
          style: const TextStyle(
              color: Color.fromARGB(255, 217, 64, 255),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(interests.isNotEmpty
            ? interests.join(", ")
            : loc?.notSet ?? "Not set"),
        children: predefinedInterests.map((interest) {
          return CheckboxListTile(
            title: Text(
              interest,
              style: const TextStyle(
                color: Color.fromARGB(255, 94, 2, 241),
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            value: interests.contains(interest),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected == true) {
                  interests.add(interest);
                } else {
                  interests.remove(interest);
                }
                updateProfileField("interests", interests);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Future<String?> openEditDialog(String label, String value) async {
    final loc = AppLocalizations.of(context);
    TextEditingController controller = TextEditingController(text: value);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${loc?.editButton ?? 'Edit'} $label"),
          content: TextField(
            controller: controller,
            keyboardType: label == (loc?.ageLabel ?? "Age")
                ? TextInputType.number
                : TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(loc?.saveButton ?? "Save"),
            ),
          ],
        );
      },
    );
  }
}
