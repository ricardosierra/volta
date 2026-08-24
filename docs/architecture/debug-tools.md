# Ferramentas de debug

> Tudo aqui é essencial durante o desenvolvimento e **inaceitável** em release. A separação é
> por build flag, não por "esconder o botão".

## Acesso

- Build de debug: toque triplo no canto superior direito, ou tecla `F1`.
- Build de release: **não existe**. O código é removido por `if Build.is_debug()` com
  compilação condicional e o CI verifica que nenhuma cena de debug entra no export
  (`tools/ci/check_release_build.sh`).

## Menu

| Grupo | Ferramentas |
|---|---|
| **Runner** | Invencível · Velocidade livre · Teletransportar para o toque · Forçar Backwash · Zerar Surge · Setar Surge |
| **Território** | Mostrar grid · Mostrar IDs de dono · Mostrar células de Arc · Capturar região sob o toque · Dar X % ao jogador · Zerar território |
| **Bots** | Mostrar intenção (ação escolhida + score) · Mostrar percepção (raio) · Mostrar rota estimada · Spawnar bot (arquétipo/nível) · Matar todos · Congelar IA |
| **Partida** | Forçar vitória · Forçar derrota · Pular para Final Push · Setar tempo restante · Reiniciar instantâneo · Trocar de modo/arena a quente |
| **Performance** | FPS + frame time · Memória · Draw calls · Tempo do tick de simulação por módulo · Tempo do último Seal · Gráfico de 120 frames |
| **Qualidade** | Forçar preset low/medium/high · Ligar/desligar glow, partículas, pós-processamento |
| **Save** | Mostrar JSON · Forçar save · Corromper save (teste de recuperação) · Resetar perfil · Injetar save de versão antiga |
| **Logs** | Ligar/desligar por categoria · Overlay na tela · Exportar arquivo |
| **Analytics** | Espelhar eventos na tela · Exportar sessão |

## Overlay de intenção de bot

O mais valioso de todos: sobre cada bot aparece a ação escolhida, o score dela e o segundo
colocado. É assim que se descobre que "o bot está burro" na verdade é "a ação `flee_home`
está com peso alto demais".

## Regras

1. Nenhuma ferramenta de debug altera o balanceamento fora do menu de debug.
2. Ativar qualquer ferramenta marca a sessão como `debug_tainted` — score e recorde daquela
   sessão **não** são submetidos a leaderboard nem a analytics de balanceamento.
3. Toda ferramenta nova entra nesta lista no mesmo PR.
4. O menu de debug não pode depender de sistema de UI de produção (para continuar funcionando
   quando a UI estiver quebrada — que é justamente quando ele é mais necessário).
