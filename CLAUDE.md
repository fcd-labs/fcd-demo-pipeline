# fcd-pipeline

Deelproduct Pipeline van het product FCD: één keer gebouwd, voor alle showcases. Wat voor alle repositories geldt staat in `../CLAUDE.md`.

- Geen showcase-specifieke code. Wat per showcase verschilt (stappen, volgorde, gates, drempels, uitrollen, releasen, afwijkingen, omgeving, vastgelegde versies) staat in de configuratie van de showcase: `fcd-<showcase>/fcd/*.fcd.yaml`, in het FCD-model.
- Kan iets niet als configuratie: een issue in `fcd` (het model is dan nog niet rijk genoeg), niet in de code oplossen.
- Een product zegt in `ci/steps.sh` hoe het gelint, getest en gebouwd wordt (feiten, geen drempels).
- Het contract van de logregel staat in `fcd-dashboard` (de aanbieder). Wijzig het daar eerst.
- Versies staan op één plek: `versions.env`. Tools met vaste versie en digest: `tools.env`.
