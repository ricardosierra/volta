# GSD 22 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F22-01 | Conta Apple Developer não pronta (H-02) | 3 | 4 | mapeada com antecedência; build fica pronta mesmo sem conta |
| F22-02 | Assinatura e provisioning consumirem muito tempo | 3 | 2 | processo documentado passo a passo em `docs/mobile/ios.md` |
| F22-03 | Rejeição na revisão da App Store | 2 | 4 | checklist; sem placeholder, sem debug, sem link quebrado; Privacy Label coerente |
| F22-04 | Comportamento divergente do Android | 3 | 3 | mesma base de código; diferenças isoladas em `platform/`; comparação explícita |
| F22-05 | Ícone ou asset faltando bloquear o upload | 3 | 2 | validação do Xcode antes de subir |
| F22-06 | Core Haptics indisponível em aparelho antigo | 2 | 2 | fallback já previsto; degradação silenciosa |
