# GSD 17 — Testes

## Unit
Serialização de cada mensagem · validação de input · buffer de interpolação · reconciliação

## Integration
`test_server_client_parity.gd` — servidor e cliente com a mesma seed produzem estados idênticos
(checksum do grid a cada 60 ticks) · `test_seal_confirmation.gd` — Seal negado reverte
suavemente · `test_reconnect.gd`

## Rede simulada
```text
[ ] 60 ms / 0 % de perda
[ ] 120 ms / 2 %
[ ] 250 ms / 5 %  (com aviso ao jogador)
[ ] 400 ms / 10 % (degradação graciosa)
[ ] desconexão e reconexão dentro da janela
```

## Carga
N instâncias por vCPU · memória por instância · tempo de criação e destruição de partida

## Manual
```text
[ ] jogar contra outra pessoa é responsivo
[ ] o território nunca "pisca" nem volta atrás visivelmente
[ ] a reconexão não arruína a partida de quem ficou
```
