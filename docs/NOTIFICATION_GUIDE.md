# Local Notification Guide

Notifications are persisted in Hive through `NotificationRepository`. Fields include ID, type, title, message, entity metadata, route, timestamp, read state, actor snapshot, and severity.

Only successful repository operations create notifications. Cart quantity clicks and text edits do not. Notification persistence is secondary: failure is caught and never rolls back a successful primary mutation.

The bell badge is derived from the reactive unread collection. Its menu shows the newest five, highlights unread items, marks a clicked item read, and follows its stored route. **View all notifications** opens the newest-first page with All/Unread filters, per-item read toggles, mark-all-read, and an empty state. The local repository caps retained events at 200.
