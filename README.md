# fcd-demo-pipeline

Deelproduct **Pipeline** van [fcd-demo](https://github.com/fcd-labs/fcd-demo), de way of working van de showcase Demo.

Het bash-script `fcd` is de enige weg om te bouwen, te testen, te controleren, uit te rollen en te releasen. De agent haalt wijzigingen op uit git (alleen `main` en release-tags), draait het script, rolt uit met docker compose en stuurt na elke stap en gate een logregel naar het Dashboard.

Meer over deze showcase: https://fcd-labs.github.io/fcd/showcases/demo/

## Gebruik

```bash
./fcd check                 # wat mist er?
./fcd ci ../sk-demo         # CI-stappen en gates, lokaal (omgeving werkplek)
./fcd hooks ../sk-demo      # dezelfde stappen vóór elke push
./fcd up                    # start de Pipeline-agent: haalt main op, bouwt, rolt uit, releaset
```

Elke repository heeft `versions.env` (de versies) en `ci/steps.sh` (wat specifiek is voor die repository). Tools en hun licentie: [tools.env](tools.env).

Licentie: [MIT](LICENSE).
