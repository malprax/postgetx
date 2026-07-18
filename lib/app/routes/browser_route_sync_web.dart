// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Publishes an app-initiated GetX Router 2 route to browser history.
/// Incoming popstate events continue through Flutter's Router normally.
void publishBrowserRoute(String route, {bool replace = false}) {
  final url = '#$route';
  if (replace) {
    html.window.history.replaceState(null, '', url);
  } else {
    html.window.history.pushState(null, '', url);
  }
}
