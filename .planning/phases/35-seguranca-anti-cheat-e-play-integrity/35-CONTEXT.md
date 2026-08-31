# Context: Segurança, Anti-cheat e Play Integrity

## Anti-cheat e Resolução de Conflitos
Tudo que afeta leaderboards, moedas ou recompensas raras vindo do cliente é não confiável.
Implementar limites, nonces, timestamps, replay protection e idempotência (Server Authority).
Cloud Save: resolver conflitos explicitamente e tratar versionamento, merge e offline saves adequadamente, sem sobrescrever cegamente o progresso mais recente.
