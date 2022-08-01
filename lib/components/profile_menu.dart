import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/model/profile_menu.dart';

class ProfileMenu {
  static const List<MenuItem> postItems = [
    postEdit,
    postDelete,
  ];

  static const List<MenuItem> userItems = [
    profileEdit,
    signOut,
  ];

  static const postEdit = MenuItem(
    text: 'Edit',
    icon: Icons.edit,
  );

  static const postDelete = MenuItem(
    text: 'Delete',
    icon: Icons.delete,
  );

  static const profileEdit = MenuItem(
    text: 'Edit Profile',
    icon: Icons.edit,
  );

  static const signOut = MenuItem(
    text: 'Sign Out',
    icon: Icons.logout,
  );
}
