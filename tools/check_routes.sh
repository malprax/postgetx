#!/usr/bin/env bash
set -euo pipefail
rg -q "static const login" lib/app/routes/app_routes.dart
rg -q "AppRoutes.login" lib/app/routes/app_pages.dart
rg -q "WorkspaceRouteMetadata.destinations" lib/app/routes/app_pages.dart
rg -q "AppRoutes.cashier" lib/app/routes/workspace_route_metadata.dart
rg -q "AppRoutes.notifications" lib/app/routes/workspace_route_metadata.dart
rg -q "AppRoutes.trash" lib/app/routes/workspace_route_metadata.dart
rg -q "PermissionMiddleware" lib/app/routes/app_pages.dart
echo "routes: ok"
