# assets/

| Pasta | Conteúdo |
|---|---|
| `source/` | arquivos de autoria (SVG, projetos de áudio) |
| `brand/` | logo, wordmark, ícone do app |
| `fonts/` | fontes com licença registrada em `CREDITS.md` |
| `audio/` | música e SFX |
| `sprites/` | ícones e sprites exportados |
| `shaders/` | shaders escritos à mão, comentados |
| `exported/` | saídas geradas (não versionadas) |

Esta é a **única** pasta de assets do repositório. O projeto Godot a alcança por
`res://assets/`, que é um symlink `apps/mobile/assets -> ../../assets` — não crie uma
segunda cópia dentro de `apps/mobile/`.

Os assets originais daqui são cobertos pela mesma licença MIT do código — ver `LICENSE`.
Todo asset de **terceiros** mantém a licença própria e entra em [`CREDITS.md`](CREDITS.md).
Arte é vetorial ou procedural; nenhuma textura acima de 1024×1024.

Arquivos `.import` e `.uid` são gerados pelo Godot e ficam versionados ao lado do asset.
