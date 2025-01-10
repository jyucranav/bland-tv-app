import 'package:flutter/material.dart';

class DrawerChangedNotification extends Notification {
  final bool isOpen;

  DrawerChangedNotification(this.isOpen);
}
