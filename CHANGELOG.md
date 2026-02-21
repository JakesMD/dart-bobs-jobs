# Changelog

## 0.1.1 - 21.02.26

- 📝 Add discontinue notice
- 🐛 Fix test version solving

## 0.1.0 - 13.06.25

- 📝 Improve documentation

## 0.0.1-dev.17 - 10.03.25

- ✨ Add `validateFailure`
- ✏️ Rename `validate` to `validateSuccess`

## 0.0.1-dev.16

- ✨ Add `BobsStream` (experimental)

## 0.0.1-dev.15

- 🔥 Remove `stackTrace` from `onError` callbacks

## 0.0.1-dev.14

- ✨ Add global and customizable `onFailure` callback

## 0.0.1-dev.13

- ✨ Add ability to construct a `BobsMaybe` from a nullable value

## 0.0.1-dev.12

- ✨ Add `asNullable` to `BobsMaybe`

## 0.0.1-dev.11

- 🐛 Fix typos in `BobsMaybe`

## 0.0.1-dev.10

- ✨ Add ability to validate the success value of a job outcome
- ✏️ Rename `evaluate` to `convert` in `BobsJob`
- ✏️ Rename `evaluate` to `resolve` in `BobsOutcome`

## 0.0.1-dev.9

- ✨ Add `isPresent` and `isAbsent` checks to `BobsMaybe`

## 0.0.1-dev.8

- ✨ Add `succeeded` and `failed` checks to `BobsOutcome`

## 0.0.1-dev.7

- ✨ Add ability to fetch the success or failure values of an outcome without
  resolving it
- 🔥 Remove `isAsync` and `delayDuration`

## 0.0.1-dev.6

- ✨ Add ability to only convert successful job

## 0.0.1-dev.5

- 🔥 Remove debug delay

## 0.0.1-dev.4

- ✨ Add ability to `chain` job instances

## 0.0.1-dev.3

- ✨ Add stack trace to `onError`
- 🐛 Fix debug delay not working with multiple jobs

## 0.0.1-dev.2

- 🐛 Fix `deriveOnPresent` typo

## 0.0.1-dev.1

- 🎉 Initial release
