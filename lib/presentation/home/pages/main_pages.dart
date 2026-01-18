import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/home/pages/history_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/home_page.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/core.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgets =  [
    HomePage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgets,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8), // 👈 bikin icon & text turun
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (value) => setState(() => _selectedIndex = value),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.transparent,

              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.grey,

              selectedFontSize: 11,
              unselectedFontSize: 11,
              iconSize: 22,

              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/nav/home_prisma.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 0
                          ? AppColors.primary
                          : AppColors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/nav/history_prisma.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 1
                          ? AppColors.primary
                          : AppColors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'History',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
