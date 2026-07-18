# Local Product Image Guide

Product images are optional and fully offline. The Create/Edit form uses `image_picker` for Android gallery and Flutter Web selection. The temporary `XFile` is read once and never persisted.

`ProductImageService` accepts JPEG, PNG, and WebP input up to 5 MB, validates file signatures and MIME metadata, decodes and corrects orientation, limits dimensions to 800 × 800, and normalizes output to an optimized JPEG no larger than 500 KB. Hive stores Base64, MIME type, and a display file name. Web stores the Hive map in IndexedDB; Android stores it in the local Hive box.

Never store absolute paths, temporary Blob URLs, `XFile`, or `BuildContext`. Large catalogs with many images grow the local Hive database, so keep thumbnails compact. Demo reset removes user demo image values together with the rest of the demo box.

`ProductVisual` centralizes decoding and memoization. A missing or corrupt image falls back to the associated category icon through `CategoryIconRegistry`; a missing category uses the generic `other` product icon.
