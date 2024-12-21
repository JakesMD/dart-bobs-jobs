# Changelog

## 0.0.1-dev.10
- ✨ Add ability to validate the success value of a job outcome
- ✏️ Rename `evaluate` to `convert` in `BobsJob`
- ✏️ Rename `evaluate` to `resolve` in `BobsOutcome`

## 0.0.1-dev.9
- ✨ Add `isPresent` and `isAbsent` checks to `BobsMaybe`

## 0.0.1-dev.8
- ✨ Add `succeeded` and `failed` checks to `BobsOutcome`

## 0.0.1-dev.7
- ✨ Add ability to fetch the success or failure values of an outcome without resolving it
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
