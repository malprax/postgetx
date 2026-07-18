# Module Guide

Each feature lives below `lib/app/modules/<feature>` with optional `bindings`, `controllers`, `views`, and `widgets` folders. A module owns screen-specific state and components; reusable panels, dialogs, tables, forms, charts, and layouts belong in `lib/app/shared`.

The workspace module is the reference implementation. `WorkspaceController` combines repository streams into UI-ready inventory, sales, receipt, order, and product statistics. Its widgets receive or observe state and never read Hive. New modules should use constructor-injected repository contracts registered in `InitialBinding`.

Routes are declared once in `AppRoutes` and registered once in `AppPages`. Navigation labels that switch workspace sections are centralized in `WorkspaceView.sections`.
