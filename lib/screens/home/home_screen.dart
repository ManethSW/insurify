import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurify/providers/user_provider.dart';
import 'package:insurify/screens/add_insurance/add_insurance_main_screen.dart';
import 'package:insurify/screens/blog/blog_main_screen.dart';
import 'package:insurify/screens/profile/profile_main_screen.dart';
import 'package:provider/provider.dart';

import 'package:insurify/providers/global_provider.dart';
import 'package:insurify/providers/theme_provider.dart';
import 'package:insurify/screens/components/top_bar.dart';
import 'package:insurify/screens/components/policy_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late ThemeProvider themeProvider;
  late GlobalProvider globalProvider;
  late UserDataProvider userDataProvider;
  String activeFilter = 'All';
  late List<PolicyCardTemplate> policyCardList;

  @override
  void initState() {
    super.initState();
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    policyCardList = [];
    loadPolicies().then((policies) {
      setState(() {
        policyCardList = policies;
      });
    });
  }

  Future<List<PolicyCardTemplate>> loadPolicies() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    List<dynamic> jsonData = jsonDecode(jsonString);
    var userData = jsonData.firstWhere(
      (item) => item['phoneNo'] == userDataProvider.userData.phoneNo,
      orElse: () => null,
    );
    if (userData == null) {
      return [];
    }
    List<dynamic> policiesData = userData['policies'];
    List<PolicyCardTemplate> policies =
        policiesData.map((item) => PolicyCardTemplate.fromJson(item)).toList();
    return policies;
  }

  Widget buildQuickActionButton(
      int flexNumber, String label, String icon, Widget page) {
    return Expanded(
      flex: flexNumber,
      child: Container(
        height: 102,
        decoration: BoxDecoration(
          color: themeProvider.themeColors["secondary"],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Text(
                label,
                style: TextStyle(
                  color: themeProvider.themeColors["white"],
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                height: 2,
                width: 25,
                decoration: BoxDecoration(
                  color: themeProvider.themeColors["startUpBodyText"],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
              child: FractionallySizedBox(
                widthFactor: 1,
                child: GestureDetector(
                  onTap: () {
                    if (icon == "plus") {
                      globalProvider.setCurrentScreen('addInsurance');
                    } else if (icon == "profile") {
                      globalProvider.setCurrentScreen('profile');
                    } else if (icon == "blog") {
                      globalProvider.setCurrentScreen('blogs');
                    }
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            page,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var tween = Tween(begin: begin, end: end);
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: themeProvider.themeColors["primary"],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Image.asset(
                        themeProvider.themeIconPaths[icon]!,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildFilterItem(String label, String count) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeFilter = label;
        });
      },
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: activeFilter == label
                  ? themeProvider.themeColors["white"]
                  : themeProvider.themeColors["white"]!.withOpacity(0.75),
              fontWeight: FontWeight.w600,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          CircleAvatar(
            radius: 7.5,
            backgroundColor: activeFilter == label
                ? themeProvider.themeColors["white"]
                : themeProvider.themeColors["white"]!.withOpacity(0.75),
            child: Text(
              count,
              style: TextStyle(
                color: themeProvider.themeColors["secondary"],
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
                fontFamily: 'Inter',
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: themeProvider.themeColors["secondary"],
        systemNavigationBarColor: themeProvider.themeColors["primary"],
      ),
    );
    final double height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    List<PolicyCardTemplate> filteredList = policyCardList.where((policy) {
      if (activeFilter == 'All') {
        return true;
      } else if (activeFilter == 'Active') {
        return policy.policyStatus == 'due' || policy.policyStatus == 'payed';
      } else if (activeFilter == 'Expired') {
        return policy.policyStatus == 'expired';
      }
      return false;
    }).toList();

    int allCount = policyCardList.length;
    int activeCount = policyCardList
        .where((policy) {
          return policy.policyStatus == 'due' || policy.policyStatus == 'payed';
        })
        .toList()
        .length;
    int expiredCount = policyCardList
        .where((policy) {
          return policy.policyStatus == 'expired';
        })
        .toList()
        .length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              const TopBar(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 90, bottom: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor:
                            themeProvider.themeColors["secondary"]!,
                        child: userDataProvider.userData.profilePic == null
                            ? Icon(Icons.person_rounded,
                                color: themeProvider.themeColors["white"]!
                                    .withOpacity(0.75),
                                size: 40.0)
                            : CircleAvatar(
                                radius: 33.5,
                                backgroundImage:
                                    userDataProvider.userData.profilePic!.image,
                              ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${userDataProvider.userData.fname!} ${userDataProvider.userData.lname!}',
                        style: TextStyle(
                          color: themeProvider.themeColors["white"],
                          fontWeight: FontWeight.w600,
                          fontSize: 22.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildQuickActionButton(2, "Add New \nMotor Insurance",
                              "plus", const AddInsuranceMainScreen()),
                          const SizedBox(
                            width: 10,
                          ),
                          buildQuickActionButton(1, "View Profile", "profile",
                              const ProfileMainScreen()),
                          const SizedBox(
                            width: 10,
                          ),
                          buildQuickActionButton(
                              1, "View Blogs", "blog", const BlogMainScreen()),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Text(
                          "My Insurances",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: themeProvider.themeColors["white"],
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Text(
                          "View & Manage Your Insurances",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: themeProvider.themeColors["white"]!
                                .withOpacity(0.75),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Stack(
                          alignment: AlignmentDirectional.centerStart,
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: [
                                buildFilterItem('All', allCount.toString()),
                                const SizedBox(
                                  width: 20,
                                ),
                                buildFilterItem(
                                    'Active', activeCount.toString()),
                                const SizedBox(
                                  width: 20,
                                ),
                                buildFilterItem(
                                    'Expired', expiredCount.toString()),
                              ],
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                              left: activeFilter == 'All'
                                  ? 7.5
                                  : activeFilter == 'Active'
                                      ? 77.5
                                      : 165,
                              bottom: -7.5,
                              child: Container(
                                width: 25,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: themeProvider.themeColors["white"]!,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      Expanded(
                        child: filteredList.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: themeProvider.themeColors["secondary"],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    activeFilter == 'All'
                                        ? 'You do not own any\ninsurance policies'
                                        : activeFilter == 'Active'
                                            ? 'You do not have any\nactive insurance policies'
                                            : 'You do not have any\nexpired insurance policies',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeProvider
                                          .themeColors["startUpBodyText"],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredList.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 15,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return filteredList[index];
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
