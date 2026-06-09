# Contributing to Grimoji 

First off, thank you for considering contributing to Grimoji! Ghetto Coders thrives on community collaboration, and we appreciate your time and effort.

## Git Workflow (Important!)
To protect our live players and our CI/CD pipelines, we use a strict branching strategy. 
* `main`: Production code. (Do **NOT** open Pull Requests against this branch).
* `staging`: Our active integration and preview branch. 
* `features/*`: Where active development happens.

## How Can I Contribute?

### Reporting Bugs
If you find a bug, please open an issue on GitHub. Include:
* Your operating system (Windows, Linux, Android, iOS, etc.)
* Steps to reproduce the bug
* What you expected to happen vs. what actually happened
* Any error logs from the console

### Suggesting Enhancements
Have an idea for a new gothic emoji combination, a saboteur, or a gameplay mechanic? Open an issue and tag it as an `enhancement`. Describe how it works and why it fits the dark alchemy vibe.

### Submitting Pull Requests
1. **Fork** the repository.
2. **Clone** your fork locally.
3. **Create a feature branch** based off our `staging` branch (`git checkout -b features/new-emoji-recipe`).
4. **Make your changes** (ensure you follow the setup guide in `docs/SETUP.md`).
5. **Run tests and format** your code (`flutter analyze` and `flutter test`).
6. **Write tests** to prevent shipping bugs :)
7. **Commit** your changes with clear, descriptive commit messages.
8. **Push** to your fork and open a **Pull Request against our `staging` branch**. 

*(Note: PRs opened directly against `main` will be respectfully closed and asked to target `staging` so our cloud robots can generate an Appetize.io preview link for review!)*

## Code Style
* Please adhere to standard Dart and Flutter formatting (`dart format .`).
* Keep your commits concise and focused on a single change.