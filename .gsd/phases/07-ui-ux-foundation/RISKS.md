# GSD 07 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F07-01 | UI "funcional mas feia" ser aceita como pronta | 3 | 3 | o gate visual é explícito; a GSD 08 vem logo depois e depende desta estrutura estar correta |
| F07-02 | Componentes crescerem demais (um `VButton` com 20 opções) | 3 | 2 | showcase expõe o inchaço; variantes limitadas a 3 |
| F07-03 | Safe area errada em aparelho específico | 3 | 3 | leitura dinâmica + captura na matriz + teste em 2 aparelhos reais |
| F07-04 | Onboarding atrapalhar quem já sabe jogar | 2 | 3 | dicas somem ao serem demonstradas; nunca aparecem em momento de tensão; opção de rejogar |
| F07-05 | i18n adiado "para depois" | 3 | 3 | chave desde o primeiro texto; verificação no CI a partir desta fase |
| F07-06 | Escala de UI 1,25 quebrar layouts | 3 | 2 | capturas automáticas em 1,25 desde o começo |
| F07-07 | Tela nova ser criada sem `SafeAreaContainer` | 3 | 2 | verificação no `validate-repo.sh` |

## Riscos globais tocados
- **RISK-016** (parecer protótipo): a estrutura correta aqui é pré-requisito para a arte funcionar.
- **RISK-005**: o playtest de onboarding mede a primeira sessão de verdade.
