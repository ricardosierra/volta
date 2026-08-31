# Context: Google Play Discovery - Auditoria de Gamificação e Sidekick

## Princípio Fundamental
Antes de modificar qualquer código:
1. Leia todo o repositório.
2. Entenda sua arquitetura e descubra automaticamente detalhes do framework, build, sistema atual de usuários, save, progressão, moedas, ranking, etc.
3. Identifique o que já existe e o que pode ser reaproveitado.
4. Identifique conflitos e débito técnico.

Somente depois comece a implementação. NÃO crie sistemas paralelos desnecessariamente.

## Verificação da Documentação
Antes de implementar:
* Consultar a documentação oficial atual do Play Games Services, Sidekick, Level Up, Game Stats, Achievements, Cloud Save, Recall, Rewards, Quests, Play Points, Play Pass.
* Registrar tudo em `docs/google-play/current-requirements.md`.

## Fases de Execução: Fase 0 — Discovery
* Mapear projeto, arquitetura, gameplay, gamificação existente, backend, Android, Google Play atual e riscos.
* Entregável: `compatibility-audit.md`
