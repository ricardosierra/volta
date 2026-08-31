# Context: Play Games Services v2 e Autenticação

## Google Play Games Services v2
Garantir a implementação correta do PGS v2:
* Inicialização no startup e autenticação automática.
* Tratamento assíncrono correto e fallback se indisponível.
* Reconexão, troca de conta, reinstalação, mudança de device e retomada.
* O PGS deve melhorar a experiência, não ser ponto único de falha.

## Identidade
Não substituir cegamente o sistema de contas próprio se existir.
Criar associação segura: `internal_player_id <-> play_games_player_id`.
Avaliar utilização da Recall API. Nunca usar atributos mutáveis (nickname, e-mail) como chave de identidade.
