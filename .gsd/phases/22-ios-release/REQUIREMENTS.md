# GSD 22 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R22-01 | IPA assinado gerado por script | build |
| R22-02 | iOS mínimo 14.0; arm64; renderer Metal | configuração |
| R22-03 | Nenhuma ferramenta de debug na build | script |
| R22-04 | Conjunto **completo** de ícones (o iOS não perdoa faltando um) | validação do Xcode |
| R22-05 | Launch screen em storyboard | dispositivo |
| R22-06 | Privacy Nutrition Label coerente com a coleta | revisão cruzada |
| R22-07 | Entitlements mínimos; sem ATT no v0.1.0 | inspeção |
| R22-08 | Safe area correta com notch, Dynamic Island e home indicator | dispositivo |
| R22-09 | Háptico via Core Haptics com fallback | dispositivo |
| R22-10 | Áudio se comporta com ligação, alarme e botão de silencioso | dispositivo |
| R22-11 | 120 Hz (ProMotion) funcionando | dispositivo |
| R22-12 | Assets de loja completos (en + pt-BR) | checklist |
| R22-13 | TestFlight validado por ≥ 3 pessoas | relatório |
