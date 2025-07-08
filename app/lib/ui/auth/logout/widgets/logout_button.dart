// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/ui/auth/logout/view_models/logout_viewmodel.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LogoutButton extends HookConsumerWidget {
  const LogoutButton({required this.viewModel, super.key});

  final LogoutViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onResult() {
      // We do not need to navigate to `/login` on logout,
      // it is done automatically by GoRouter.
      if (viewModel.logout.value.isFailure) {
        viewModel.logout.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.of(context).errorWhileLogout),
            action: SnackBarAction(
              label: AppLocalization.of(context).tryAgain,
              onPressed: viewModel.logout.execute,
            ),
          ),
        );
      }
    }

    useEffect(() {
      viewModel.logout.addListener(onResult);
      return () => viewModel.logout.removeListener(onResult);
    }, [viewModel]);

    return SizedBox(
      height: 40,
      width: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: InkResponse(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            viewModel.logout.execute();
          },
          child: Center(
            child: Icon(
              size: 24,
              Icons.logout,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
