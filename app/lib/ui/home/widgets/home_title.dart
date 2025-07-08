// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/ui/auth/logout/view_models/logout_viewmodel.dart';
import 'package:compass_app/ui/auth/logout/widgets/logout_button.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = viewModel.user;
    if (user == null) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.asset(
                user.picture,
                width: Dimens.of(context).profilePictureSize,
                height: Dimens.of(context).profilePictureSize,
              ),
            ),
            LogoutButton(
              viewModel: LogoutViewModel(
                authRepository: ref.read(authRepositoryProvider),
                itineraryConfigRepository:
                    ref.read(itineraryConfigRepositoryProvider),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimens.paddingVertical),
        _Title(text: AppLocalization.of(context).nameTrips(user.name)),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback:
          (bounds) => RadialGradient(
            center: Alignment.bottomLeft,
            radius: 2,
            colors: [Colors.purple.shade700, Colors.purple.shade400],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: GoogleFonts.rubik(
          textStyle: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
