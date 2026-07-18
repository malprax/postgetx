# Backup Guide

Run `bash tools/backup_project.sh` to create a timestamped source archive in `backups/`. Build outputs, tool caches, Git internals, and existing backups are excluded. This archives project source and seeded definitions, not runtime Hive records stored by the operating system.

Inspect an archive with `tar -tzf backups/<file>.tar.gz`. Restore into a clean directory with `bash tools/restore_backup.sh <archive> <destination>`. Never restore over an active working tree without reviewing the archive first.
