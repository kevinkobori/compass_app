// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/core/themes/colors.dart';
import 'package:compass_app/ui/core/ui/blur_filter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home button to navigate back to the '/' path.
class HomeButton extends StatelessWidget {
  const HomeButton({super.key, this.blur = false});

  final bool blur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (blur)
            ClipRect(
              child: BackdropFilter(
                filter: kBlurFilter,
                child: const SizedBox(height: 40, width: 40),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey1),
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                context.go(Routes.home);
              },
              child: Center(
                child: Icon(
                  size: 24,
                  Icons.home_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
