# Changelog

Alle wijzigingen per versie. Formaat: [Keep a Changelog](https://keepachangelog.com/nl/1.1.0/), versies: [semantic versioning](https://semver.org/lang/nl/).

## [Unreleased]

## [0.1.0] - 2026-11-20

### Toegevoegd
- `fcd`: het bash-script dat de enige weg is. `check`, `ci` (CI-stappen 1–10 met code-, bouw-, security-, uitrol- en mensgate), `bump`, `hooks` (pre-push), `agent`, `up`, `down`, `status`, `logs`.
- Na elke stap en gate een logregel (CDEvents) naar het Dashboard; zonder Dashboard in een outbox die later wordt verstuurd.
- Tools in containers met vaste versie en digest (`tools.env`); licentiebeleid in `trivy/trivy-license.yaml`.
- Unittests met bats, lint met ShellCheck.
