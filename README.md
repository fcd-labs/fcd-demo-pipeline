# fcd-demo-pipeline

Deelproduct **Pipeline** van [fcd-demo](https://github.com/fcd-labs/fcd-demo), de way of working van de showcase Demo.

Het bash-script `fcd` is de enige weg om te bouwen, te testen, te controleren, uit te rollen en te releasen. De agent haalt wijzigingen op uit git (alleen `main` en release-tags), draait het script, rolt uit met docker compose en stuurt na elke stap en gate een logregel naar het Dashboard.

Meer over deze showcase: https://fcd-labs.github.io/fcd/showcases/demo/

Licentie: [MIT](LICENSE).
