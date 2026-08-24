# Segurança do backend

> Regra fundadora: **nunca confie em dado importante enviado pelo cliente.** O cliente é um
> aparelho na mão de um desconhecido, rodando um binário que pode ter sido modificado.

## Superfície protegida

| Recurso | Por quê |
|---|---|
| Autenticação | roubo de conta |
| Submissão de score | leaderboard é o principal alvo de fraude |
| Leaderboard | manipulação de ranking |
| Inventário | itens "de graça" |
| Progressão | XP e rank inflados |
| Compras | itens sem pagamento |
| Cloud save | sobrescrita maliciosa e perda de progresso |

## Práticas obrigatórias

1. **HTTPS sempre.** HSTS ligado. Nenhum endpoint em texto claro.
2. **Sanctum com tokens de escopo curto**, rotacionados; refresh invalida o anterior.
3. **Validação em FormRequest** para toda entrada. Nada de `$request->all()` num `create()`.
4. **Rate limit por rota e por jogador**, além do limite por IP.
5. **Idempotência** em toda escrita relevante (`Idempotency-Key` + tabela de chaves usadas).
6. **Assinatura HMAC** do payload de partida com segredo derivado por sessão — não é
   inquebrável, mas eleva o custo do ataque casual (a validação de plausibilidade é a defesa real).
7. **Nenhum segredo no cliente.** Chaves só no servidor e nos secrets do CI.
8. **Logs sem PII e sem token.** Nada de logar corpo de requisição autenticada.
9. **Migrações revisadas**; nenhuma coluna sensível sem necessidade.
10. **Backup diário** do PostgreSQL com restauração **testada** (backup não testado não é backup).
11. **Dependências auditadas** no CI (`composer audit`), atualizações de segurança priorizadas.
12. **Princípio do menor privilégio** no banco: a aplicação não roda como superusuário.

## Compras

- Recibo **sempre** validado no servidor contra Google Play / App Store.
- `receipt_hash` único: recibo já usado é rejeitado.
- Entrega do item só depois da confirmação. Nunca "otimista".
- Reembolso detectado revoga o item.

## Cloud save

- Tamanho máximo de blob e validação de schema antes de gravar.
- Versionamento com `updated_at` do servidor, não do cliente.
- Conflito nunca apaga: mantemos as últimas 3 versões por jogador.
- XP, conquistas e inventário reconciliados por regra **monotônica** — o servidor nunca aceita
  redução vinda do cliente.

## Resposta a incidentes

1. Detectar (alertas de taxa de erro, picos de score, anomalia de compra).
2. Conter (revogar token, desativar rota, ativar modo somente-leitura do leaderboard).
3. Investigar com os logs estruturados.
4. Corrigir e publicar.
5. Post-mortem sem culpados, registrado em `docs/backend/incidents/`.

Contato de segurança e política de divulgação em [`../../SECURITY.md`](../../SECURITY.md).
