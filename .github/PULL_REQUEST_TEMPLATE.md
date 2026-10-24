<!--
Please read CONTRIBUTING.md before opening a pull request.
Pull requests that do not follow it may be closed regardless of their content.
-->

## Related issue

Closes #

## What this changes

<!-- One purpose per pull request. Describe the single problem this solves and how. -->

## How it was tested

<!-- Only describe what you actually ran yourself, and on which platforms. -->

## Checklist

- [ ] The related issue is linked above, or this is a bug fix, typo fix, or minor suggestion that needs no prior discussion
- [ ] The change has a single, focused purpose
- [ ] The branch is rebased on the latest `main`
- [ ] Every added declaration exists in Apple's `simd` with the same name, signature, and behavior
- [ ] Every added declaration is `@inlinable`
- [ ] Added declarations are compared against Apple's `simd` in `Tests/SIMDCompatPortableTests`
- [ ] `swift test` passes on macOS, and the package builds on Linux
- [ ] No new compiler warnings are introduced
- [ ] No unrelated files are included (`.gitignore`, formatting-only diffs, generated files, and so on)
- [ ] The README is updated if the supported API changed
- [ ] If an AI tool was used, it is mentioned in the description above or in a commit trailer
