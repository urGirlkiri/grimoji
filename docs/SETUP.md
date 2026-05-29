# Setup & Installation

## Env Var

[See the example file](../.env.example)

> Copy that file and rename it to `.env` 
> Then enter your own values

## [Install Flutter](https://docs.flutter.dev/install)

and run 

```bash
flutter doctor
```

## Install Dependencies

```bash
flutter pub get
```

## Sanity Check

```bash
flutter analyze
```

## Run Tests

```bash
flutter test
```

## Hive

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```