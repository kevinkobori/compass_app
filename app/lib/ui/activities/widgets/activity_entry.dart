// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:compass_app/ui/core/ui/custom_checkbox.dart';
import 'package:compass_app/utils/image_error_listener.dart';
import 'package:flutter/material.dart';

class ActivityEntry extends StatelessWidget {
  const ActivityEntry({
    required this.activity,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Activity activity;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: activity.imageUrl,
              height: 80,
              width: 80,
              errorListener: imageErrorListener,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.timeOfDay.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  activity.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          CustomCheckbox(
            key: ValueKey('${activity.ref}-checkbox'),
            value: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
