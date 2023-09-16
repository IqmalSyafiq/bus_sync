import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constant/app_colors.dart';
import '../../../constant/app_text_styles.dart';
import '../../../services/auth/auth_services.dart';

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildAuthPageImages(),
            _buildHeroStatements(),
            Expanded(
                child: Center(
                    child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => AuthServices().signInwithGoogle(context),
              child: Container(
                width: 303,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.lightGrey)),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: AppColors.white),
                      child: Image.asset('assets/images/google.png', width: 20, height: 20),
                    ),
                    Expanded(
                        child: Center(
                            child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text('Login With Google', style: AppTextStyles.medium().copyWith(fontSize: 16)),
                    )))
                  ],
                ),
              ),
            )))
          ],
        ));
  }

  List<Widget> _buildAuthPageImages() => <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Image.asset('assets/images/icon.png', width: 50, height: 50),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 15, left: 30),
          child: Image.asset('assets/images/authHero.png', height: 254),
        ),
      ];

  Widget _buildHeroStatements() => Center(
        child: Column(
          children: [
            Text('Welcome!', style: AppTextStyles.h1().copyWith(fontSize: 50, fontWeight: FontWeight.w900, color: AppColors.primaryColor)),
            Text(
              'Never miss a bus,\nfind your bus routes in the area.',
              style: AppTextStyles.medium().copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
