# Changelog

Alle wijzigingen per versie. Formaat: [Keep a Changelog](https://keepachangelog.com/nl/1.1.0/), versies: [semantic versioning](https://semver.org/lang/nl/).

## [Unreleased]

## [0.3.2] - 2026-11-20

### Opgelost
- `fcd bump` haalt eerst de release-tags op. Zonder die tags vergeleek hij met een oudere release en verhoogde hij de versie van het deelproduct niet (de codegate ving het).

## [0.3.1] - 2026-11-20 - Noodpatch

### Opgelost
- Contracttest (stap 3): van de vorige release werd alleen het losse contractbestand opgehaald, waardoor verwijzingen naar andere bestanden (`$ref`) niet werkten en de codegate onterecht dichtviel. Nu wordt de hele repository van de vorige release uitgepakt.
- Ook vóór een push worden de release-tags opgehaald, zodat de versie- en contractcontrole lokaal hetzelfde ziet als de Pipeline.

## [0.3.0] - 2026-11-20

### Toegevoegd
- `fcd report`: bewaart het statusrapport van het Dashboard in `fcd-demo/reports/`.
- De uitgerolde containers krijgen experiment en omgeving mee (`FCD_EXPERIMENT`, `FCD_ENVIRONMENT`), voor de meting van het key result.

### Gewijzigd
- GitOps ook voor de Pipeline zelf: de agent draait de `fcd` die op `main` staat (zijn eigen checkout, als eerste bijgewerkt), nooit een werkkopie.

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
