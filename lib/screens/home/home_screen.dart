import 'package:flutter/material.dart';
import 'package:horse_care_pro/screens/horse/horse_profile_screen.dart';
import 'package:horse_care_pro/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../providers/horse_auth_provider.dart';
import '../../providers/horse_provider.dart';
import '../horse/add_horse_screen.dart';
import '../../widgets/horse_card.dart';

import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          Provider.of<HorseAuthProvider>(context, listen: false);

      if (authProvider.user != null) {
        Provider.of<HorseProvider>(context, listen: false)
            .fetchHorses(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HorseAuthProvider>(context);
    final horseProvider = Provider.of<HorseProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant App Bar
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.brown[800],
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${authProvider.userModel?.name?.split(' ')[0] ?? 'Rider'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Your Horses, Your Care',
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://plus.unsplash.com/premium_photo-1661855036857-7855c8de519e?q=80&w=1748&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Notification and Profile
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.userModel?.name?[0].toUpperCase() ?? 'U',
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    authProvider.signOut();
                  }

                  if (value == 'profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // Quick Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStatCard(
                    icon: Icons.pets,
                    label: 'Total Horses',
                    value: horseProvider.horses.length.toString(),
                  ),
                  _buildQuickStatCard(
                    icon: Icons.health_and_safety,
                    label: 'Health Checks',
                    value: 'Soon',
                    isComingSoon: true,
                  ),
                  _buildQuickStatCard(
                    icon: Icons.calendar_today,
                    label: 'Upcoming Events',
                    value: 'Soon',
                    isComingSoon: true,
                  ),
                ],
              ),
            ),
          ),

          // Horses List
          horseProvider.horses.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Horses Yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Add your first horse and start tracking!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final horse = horseProvider.horses[index];
                      return HorseCard(
                        horse: horse,
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HorseProfileScreen(horse: horse),
                            ),
                          );
                        },
                        onDelete: () {
                          // Implement delete confirmation
                        },
                      );
                    },
                    childCount: horseProvider.horses.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddHorseScreen()),
          );
        },
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text('Add Horse',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.brown[800],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    bool isComingSoon = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      height: 140, // Fixed height
      decoration: BoxDecoration(
        color: isComingSoon ? Colors.grey[200] : Colors.brown[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: [
          Icon(icon,
              color: isComingSoon ? Colors.grey : Colors.brown[700], size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isComingSoon ? Colors.grey : Colors.brown[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isComingSoon ? Colors.grey : Colors.brown[600],
              fontStyle: isComingSoon ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (isComingSoon)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
