import 'package:get/get.dart';

import '../modules/auth/views/demo_login_view.dart';
import '../modules/workspace/controllers/workspace_controller.dart';
import '../modules/workspace/views/workspace_view.dart';
import 'app_routes.dart';
import 'workspace_route_metadata.dart';
import 'permission_middleware.dart';

abstract final class AppPages {
  static final pages = [
    GetPage(
        name: AppRoutes.login,
        page: DemoLoginView.new,
        middlewares: [LoginSessionMiddleware()]),
    ...WorkspaceRouteMetadata.destinations.map(
      (destination) => GetPage(
        name: destination.route,
        page: () {
          Get.find<WorkspaceController>().syncDestination(destination);
          return const WorkspaceView();
        },
        middlewares: [PermissionMiddleware(destination.permission)],
      ),
    ),
  ];
}
