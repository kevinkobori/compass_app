// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:compass_app/ui/auth/login/widgets/tilted_cards.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController(text: 'email@example.com');
    final password = useTextEditingController(text: 'password');

    void onResult() {
      if (viewModel.login.value.isSuccess) {
        viewModel.login.reset();
        context.go(Routes.home);
      }
      if (viewModel.login.value.isFailure) {
        viewModel.login.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.of(context).errorWhileLogin),
            action: SnackBarAction(
              label: AppLocalization.of(context).tryAgain,
              onPressed: () => viewModel.login.execute((
                email.value.text,
                password.value.text,
              )),
            ),
          ),
        );
      }
    }

    useEffect(() {
      viewModel.login.addListener(onResult);
      return () => viewModel.login.removeListener(onResult);
    }, [viewModel]);

    useListenable(viewModel.login);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const TiltedCards(),
          Padding(
            padding: Dimens.of(context).edgeInsetsScreenSymmetric,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: email),
                const SizedBox(height: Dimens.paddingVertical),
                TextField(controller: password, obscureText: true),
                const SizedBox(height: Dimens.paddingVertical),
                FilledButton(
                  onPressed: () {
                    viewModel.login.execute((
                      email.value.text,
                      password.value.text,
                    ));
                  },
                  child: Text(AppLocalization.of(context).login),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
