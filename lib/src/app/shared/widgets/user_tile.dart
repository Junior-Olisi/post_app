import 'package:flutter/material.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    required this.user,
    required this.onTap,
    required this.tileType,
    super.key,
  });

  final User user;
  final void Function()? onTap;
  final UserTileType tileType;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return switch (tileType) {
      UserTileType.minimal => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            user.profileImage ?? '',
          ),
        ),
        title: Text(
          user.name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onTap: onTap,
      ),
      UserTileType.small => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            user.profileImage ?? '',
          ),
        ),
        title: Text(
          user.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '@${user.username}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        onTap: onTap,
      ),
      UserTileType.large => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: size.height * 0.032,
          backgroundImage: NetworkImage(
            user.profileImage ?? '',
          ),
        ),
        title: Text(
          user.name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    };
  }
}

enum UserTileType {
  minimal,
  small,
  large,
}
