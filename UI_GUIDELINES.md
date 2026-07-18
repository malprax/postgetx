# Malprax UI Guidelines

Use the official POS references as the information architecture: persistent navigation, searchable and filterable catalog, transactional cart, operational alerts, sales insight, receipt health, recent orders, and ranked products.

All colors, spacing, radius, shadows, animation timing, typography, and icons come from `lib/app/theme`. Build surfaces with `MalpraxPanel`, actions with `MalpraxButton`, and statuses with `StatusBadge`. Repeated sections must become reusable widgets. Dark mode is the primary operational presentation; light and system modes remain supported by the preserved theme controller.

Desktop uses three operational columns at 1300px and above. Narrow widths stack catalog, cart, and insights. At less than 900px the navigation becomes a drawer. Controls must remain keyboard accessible, labeled, and functional.
