# Malprax UI Guidelines

Use the shared Malprax design tokens, panels, tables, buttons, form fields, and status badges. Dialog content must scroll when vertical space is constrained, labels must remain visible, and actions must wrap or stack at narrow widths.

## Checkout controls

Discount and tax controls use the same panel-row and dialog pattern. A control change must immediately update its summary row, grand total, and Pay label. Tax labels are `Tax (None)`, `Tax (N%)`, or `Tax (Fixed)`.

## Category icons

Forms show an icon preview and readable label. Desktop uses a grid dialog; widths below 600 use a safe-area bottom sheet. Use `CategoryIconRegistry` everywhere and avoid emoji or duplicated mappings.

## Product images

Use `ProductImageField` in Create/Edit and `ProductVisual` in cards and lists. The visual priority is valid product image, category icon, then the generic `other` icon. Use constrained thumbnails without distortion. Picker errors are inline and cancellation is silent.
## Roles, actions, and notifications

- Use Malprax design tokens and shared panels, tables, fields, spacing, and dialogs.
- Show only destinations and actions permitted for the signed-in role; repository checks still remain mandatory.
- Hold tooltip: “Pause this cart temporarily and continue it later.”
- Save as Order helper: “Save as an open order for later processing or payment.”
- Cancellation uses **Back** and **Confirm Cancellation**. Soft delete uses **Back** and **Move to Trash**. Refund is a separate labeled action.
- Destructive icon buttons require a clear tooltip and confirmation; raw ambiguous trash icons are not allowed.
- Before cash entry, do not claim Change is permanently Rp0. The cash dialog owns received cash and change.
- Unread notifications use a highlighted surface. Read notifications use the normal surface.
- Verify 1440, 1024, 820, and 390 widths in light, dark, and auto theme modes.
