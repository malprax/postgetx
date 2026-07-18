# Role and Permission Guide

## Owner

Owner has cashier and administrative permissions: products, categories, inventory, customers, expenses, reports, settings, refunds, soft delete, Trash, and restore. `permanentDeleteOrder` is intentionally absent.

## Staff

Staff may access cashier, create transactions, Hold, Save, Resume, view/cancel open orders, and manage sale customers. Staff cannot refund, restore, soft-delete, manage products/inventory/expenses/settings/users, or enter Trash.

## Enforcement

`RolePermissions` defines the matrix. `PermissionMiddleware` guards direct routes, `WorkspaceController` guards navigation/actions, and `LocalHiveRepository` authoritatively rejects forbidden mutations. Session restoration resolves the stored user ID against active local users; logout clears it.

The visible seeded passwords are demo-only. Their salted hashes protect against accidental plain-text storage but are not production authentication.
