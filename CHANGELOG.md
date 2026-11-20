# Changelog

Alle wijzigingen per versie. Formaat: [Keep a Changelog](https://keepachangelog.com/nl/1.1.0/), versies: [semantic versioning](https://semver.org/lang/nl/).

## [Unreleased]

## [0.2.0] - 2026-11-20

### Toegevoegd
- De gate-logregel bevat de details van gebruikte afwijkingen (`explainDetails`: regel, reden, goedkeurder, einddatum).
- `fcd_secret`: een gegenereerd geheim per machine in `~/.fcd/secrets`, nooit in git.
- Stap 4 haalt ook de images op die niet zelf gebouwd worden.

### Opgelost
- Bij twee redenen tegelijk verdween het scheidingsteken in de reden van een gate.
- De trigger van een merge op `main` is de persoon die mergede, niet de AI die de commits schreef; ook de goedkeurder in de mensgate.
- De agent slaat repositories zonder `versions.env` over, zonder foutmelding.

## [0.1.0] - 2026-11-20

### Toegevoegd
- `fcd`: het bash-script dat de enige weg is. `check`, `ci` (CI-stappen 1–10 met code-, bouw-, security-, uitrol- en mensgate), `bump`, `hooks` (pre-push), `agent`, `up`, `down`, `status`, `logs`.
- Na elke stap en gate een logregel (CDEvents) naar het Dashboard; zonder Dashboard in een outbox die later wordt verstuurd.
- Tools in containers met vaste versie en digest (`tools.env`); licentiebeleid in `trivy/trivy-license.yaml`.
- Unittests met bats, lint met ShellCheck.
