# Contributing to swift-simd-compat

Thank you for your interest in swift-simd-compat. This project is maintained by a single person with limited time for review. The rules below exist so that contributions can be reviewed and merged reliably within that time. Pull requests that do not follow them may be closed regardless of their content.

## What belongs in this package

This package provides a part of Apple's `simd` module on platforms that do not have it. It is not a math library of its own:

- Add only declarations that exist in Apple's `simd`, with the same names, signatures, and behavior. Code written against `simd` should build and behave the same with `SIMDCompat`
- Do not add helpers, extensions, or types that `simd` does not have
- Declarations are added as code that depends on this package needs them. A pull request that adds a declaration should say what uses it

## Discuss large changes in an issue first

Unless your change is a bug fix, a typo fix in the documentation, or a small addition of `simd` declarations, open an issue and agree on the approach before writing a pull request. The following always require prior discussion:

- Support for a new platform, or for a new scalar type (such as `Double` or `Half`)
- Changes to dependencies, supported OS versions, or the Swift version
- Changes to the directory layout or build configuration

## One pull request, one purpose

- Solve exactly one problem per pull request. Put "while I was at it" changes in separate pull requests
- Keep the change under 300 lines as a guideline, and under 500 lines at most. If it has to be larger, propose how to split it in an issue first
- Keep refactoring separate from additions

## Checklist before opening a pull request

- [ ] The description links the related issue (for example `Closes #123`)
- [ ] The change has a single, focused purpose
- [ ] The branch is rebased on the latest `main`
- [ ] Every added declaration exists in Apple's `simd` with the same name, signature, and behavior
- [ ] Every added declaration is `@inlinable`
- [ ] Added declarations are compared against Apple's `simd` in `Tests/SIMDCompatPortableTests`
- [ ] `swift test` passes on macOS, and the package builds on Linux
- [ ] No new compiler warnings are introduced
- [ ] No unrelated files are included (`.gitignore`, formatting-only diffs, generated files, and so on)
- [ ] The README is updated if the supported API changed

## Code

- Match the style, naming, and comment density of the surrounding code
- Mark every public declaration `@inlinable`. Generic functions called across modules are not specialized otherwise, and vector math becomes far slower than with Apple's `simd`
- Write comments only where they explain why something is done. Comments that describe what the code does, or what was changed, are not needed
- Do not leave commented-out code behind

## Testing

- `Tests/SIMDCompatPortableTests` compare the portable implementation with Apple's `simd` on random inputs. They run on Apple platforms only: `swift test` on macOS
- `Tests/SIMDCompatTests` check what `SIMDCompat` provides against values worked out by hand. They run on every platform, and exercise the portable implementation on Linux and Android

CI runs the tests on macOS and Linux once the maintainer approves the workflow run. Pull requests with failing CI will not be reviewed.

## Changes made with AI tools

Using AI tools is not prohibited, but the following applies:

- Before submitting, read, understand, and verify every line of the change yourself. Do not submit changes you cannot explain
- Do not submit large AI-generated changes as they are. The size and scope limits above apply unchanged
- Claims such as "tested" or "verified" in the pull request description must describe what you actually did yourself
- If you used an AI tool, mention it in the pull request description or in a commit trailer. This is not required, but it helps the review

## Review

- Review can take time. Please refrain from posting reminders while waiting for a reply
- A change may be declined because it does not fit the direction of the project, or because its maintenance cost outweighs its benefit
- Pull requests that receive no reply or update for an extended period will be closed

## License

By contributing, you agree that your contribution is released under the project's [license](./LICENSE).
