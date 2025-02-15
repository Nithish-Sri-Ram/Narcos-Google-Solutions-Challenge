// logged out route
// logged in route

import 'package:drug_discovery/features/home/screens/home_screen.dart';
import 'package:drug_discovery/features/screens/login_screen.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter/material.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});


final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
});