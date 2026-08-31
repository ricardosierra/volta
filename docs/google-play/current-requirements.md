# Requisitos Oficiais Vigentes — Google Play Games (VOLTA)

> Cada seção cita a fonte oficial e a data de consulta. Nada aqui foi escrito de memória —
> se um requisito não pôde ser confirmado ao vivo, isso está dito explicitamente na seção.
>
> Pesquisa feita por WebFetch/curl direto contra developer.android.com, developers.google.com
> e play.google.com em 2026-08-31 (`date +%Y-%m-%d` confirmado no ambiente de execução).
> Este documento é insumo do Plano 03 (arquitetura de integração) desta mesma fase — não
> implementa nada, apenas registra requisitos e disponibilidade.

## 1. Play Games Services v2 — Sign-In

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/overview — Consultado em: 2026-08-31 (página com carimbo "Last updated 2026-08-03 UTC")
- https://developer.android.com/games/pgs/android/android-signin — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-16 UTC")
- https://developer.android.com/games/pgs/deprecation — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-19 UTC")

### Requisitos Vigentes
- Dependency Gradle: `implementation "com.google.android.gms:play-services-games-v2:+"`.
- `AndroidManifest.xml` precisa do `<meta-data android:name="com.google.android.gms.games.APP_ID" android:value="@string/game_services_project_id"/>`, com o Game Services Project ID vindo da página "Configuration" do Google Play Console.
- Inicialização obrigatória em `Application.onCreate()`: `PlayGamesSdk.initialize(this)`.
- O login é automático ao abrir o jogo — não existe mais fluxo de sign-in manual obrigatório; o app verifica `GamesSignInClient.isAuthenticated()` e reage ao resultado. Play Games Services tenta reautenticar sozinho em caso de falha inicial.
- O Player ID retornado pelo SDK Android **não deve** ser guardado no backend do jogo (dispositivo não confiável pode adulterá-lo); para uso em servidor, o requisito oficial é habilitar acesso via API server-side e buscar o Player ID diretamente do backend do jogo.
- Existe suporte para suprimir a criação automática de perfil PGS via meta-data `com.google.android.gms.games.SUPPRESS_GAME_PROFILE_CREATION`, mas isso exige `play-services-games-v2:21.0.0` ou superior e desabilita a obtenção de tokens `PROFILELESS_RECALL_ENABLED` em dispositivos novos.
- **Cronograma de depreciação do v1 (fonte: deprecation schedule), oficial e com datas fixas**:
  - Desde setembro/2025: Play Console já bloqueia publicação de **títulos novos** com SDK v1.
  - Q3 2026 (GSI API Removal): jogos v1 que também dependem de Google Sign-In (GSI) podem quebrar em compilação se atualizarem outros SDKs de auth.
  - Junho/2026: `play-services-games:25.0.0` remove as APIs v1 do SDK — quem não migrou para v2 sofre erro de compilação.
  - Maio/2027: desligamento total do tráfego de Play Games Services v1 em produção.

### Disponibilidade / Elegibilidade
GA (Generally Available). O SDK v2 é a via oficial atual e obrigatória para títulos novos — não há gate de convite para o sign-in básico; qualquer app com um Game Services Project configurado no Play Console pode integrar.

### Impacto para VOLTA
- VOLTA (`com.sierratecnologia.volta`, minSdk 24/Android 7.0 conforme `docs/mobile/android.md`) não tem restrição de versão documentada para o SDK v2 de sign-in em si (a doc não define um `minSdkVersion` explícito para essa API, diferente da Play Integrity, que exige API 23 — ver seção 4).
- O export Android atual do VOLTA usa `gradle_build/use_gradle_build=false` (`apps/mobile/export_presets.cfg` linha 23) — ou seja, hoje **não existe** um `build.gradle` customizado da app onde adicionar a dependency `play-services-games-v2`. Habilitar o Gradle build customizado no export do Godot (ou usar uma solução de plugin/GDExtension) é pré-requisito técnico antes de qualquer integração de PGS v2, Recall, Play Integrity ou Sidekick SDK — decisão de arquitetura que cabe ao Plano 03 desta fase / Fase 28, não implementada aqui.
- Como VOLTA ainda não tem NENHUMA integração PGS existente, o caminho correto é implementar direto em v2 — não há v1 legado para migrar.

## 2. Recall API

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/recall — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-16 UTC")
- https://developer.android.com/games/pgs/android/android-signin — Consultado em: 2026-08-31 (cita o Recall como passo adicional ao sign-in)

### Requisitos Vigentes
- Recall API vincula a identidade PGS do jogador a uma conta própria do jogo (in-game account/IGA), por meio de um par `(persona, recall token)` armazenado nos servidores do Google e associado ao perfil PGS do jogador.
- `persona`: identificador estável da conta in-game. `recall token`: chave de acesso, pode mudar ao longo do tempo. Ambos **não podem conter PII** (nome, e-mail, dado demográfico) e o token deve ser gerado com algoritmo de criptografia robusto. Nenhum dos dois pode ser reutilizado entre projetos PGS diferentes.
- Fluxo técnico: (1) autenticar com PGS e obter um `session ID` do SDK cliente + token OAuth 2.0; (2) consultar (via backend do jogo) se já existe recall token para aquele perfil PGS; (3a) se existir, decriptar e restaurar o progresso do IGA vinculado; (3b) se não existir, autenticar/criar conta no sistema de identidade próprio do jogo e então armazenar um novo par persona/token no Google.
- Existe um **"modo profileless"** para armazenar tokens de jogadores que ainda não têm perfil PGS. Duas ressalvas obrigatórias: não é possível recuperar tokens de um usuário sem perfil PGS (só ocorre quando ele cria o perfil, tipicamente ao abrir o jogo em um segundo dispositivo), e é exigido aviso de consentimento explícito descrevendo o compartilhamento de dados com o Google, a existência de configurações para gerenciar esse compartilhamento e o tratamento desses dados pela Google Privacy Policy.

### Disponibilidade / Elegibilidade
GA e explicitamente opcional: a própria doc recomenda Recall API "if you don't have your own robust identity backend" — ou seja, é uma alternativa para quem não tem backend de identidade, não um requisito universal. Nenhum indício de gate de invite-only nas fontes consultadas.

### Impacto para VOLTA
- VOLTA já tem backend próprio (Laravel — Fases 15/16 do ROADMAP) com autenticação e sincronização de progresso. Recall API é **opcional** para o VOLTA: útil apenas como via adicional de restauração automática de conta ao trocar de dispositivo/reinstalar, mas não substitui o backend existente.
- Requer o mesmo pré-requisito de Gradle build customizado citado na seção 1 (SDK cliente Java/Kotlin), além de endpoints novos no backend próprio para armazenar/consultar o par persona/token com o Google.
- A decisão de adotar (ou não) Recall API fica para o Plano 03 desta fase / Fase 28 — este plano apenas registra que a opção existe e quais são seus requisitos e trade-offs oficiais.

## 3. Saved Games / Cloud Save

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/savedgames — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-19 UTC")

### Requisitos Vigentes
- "Saved Games" é o serviço de cloud save nativo da PGS: guarda um blob binário não estruturado (o jogo decide o formato) + metadados estruturados (`ID`, `Name`, `Description`, `Last modified`, `Played time`, `Cover image`).
- Limites de tamanho: **3 MB** por arquivo de save binário e **800 KB** para a imagem de capa (cover image). Não há cobrança por armazenamento de saved games no Google Cloud.
- É preciso habilitar o recurso previamente no Google Play Console antes de usar.
- Suporta múltiplos saves por jogador (sem limite fixo documentado além do tamanho de arquivo), leitura/escrita offline (sincroniza quando a rede volta), e **exige política de resolução de conflito** própria do jogo — a resolução de conflito **não é automática**: o jogo precisa lidar com múltiplas contas por usuário e com discrepâncias entre estado local e estado salvo na nuvem.
- Contas "guest" têm progresso preso a um único dispositivo (não sincronizado). Ao linkar uma guest account a um Player ID com progresso existente na nuvem, o jogo **não deve sobrescrever automaticamente** — a doc recomenda explicitamente avisar o jogador e deixá-lo escolher entre manter o progresso guest local ou o progresso da nuvem vinculado ao PGS.
- Cloud save (de **qualquer** solução, não necessariamente Saved Games do Google) é requisito do programa Level Up — ver seção 11 (guideline `LU-CS-GAA`).

### Disponibilidade / Elegibilidade
GA. A própria doc deixa explícito: "Play Games Services Saved Games provides a service for this, but you can use any cloud save solution of your choice" — Saved Games da PGS é uma opção pronta, não uma obrigação.

### Impacto para VOLTA
- VOLTA já tem cloud save próprio via backend Laravel (`SaveService` + repositórios remotos, Fases 15/16 conforme `ROADMAP.md`/`STATE.md`). Isso **já satisfaz** o requisito de cloud save do Level Up (`LU-CS-GAA`, seção 11) sem precisar adotar Saved Games da PGS.
- Não há necessidade técnica de migrar o `SaveService` do VOLTA para o serviço Saved Games da Google; a decisão de arquitetura (usar os dois em paralelo, ou só o próprio) fica para o Plano 03, mas o requisito oficial confirma que a porta de "manter o próprio backend" está aberta e é explicitamente sancionada pelo Google.

## 4. Play Integrity API

### Fontes Oficiais Consultadas
- https://developer.android.com/google/play/integrity/overview — Consultado em: 2026-08-31 (carimbo "Last updated 2026-04-20 UTC")

### Requisitos Vigentes
- Play Integrity API retorna vereditos (`accountDetails`, `appIntegrity`, `deviceIntegrity`) que confirmam se a ação do usuário vem de um app genuíno, instalado pela Play Store, rodando em dispositivo Android certificado (ou instância genuína do Google Play Games for PC).
- Dois tipos de requisição: **Standard** (baixa latência — poucas centenas de ms —, cache on-device, mitigação automática de replay pelo Google) e **Classic** (latência de segundos, exige campo `nonce` e lógica própria contra replay/tampering; recomendado só para ações de altíssimo valor, feitas com pouca frequência).
- `minSdkVersion`: **Android 6.0 (API 23)** ou superior para os dois tipos de requisição, a partir da versão de biblioteca **1.4.0+**. Para versões de biblioteca 1.3.0 ou anteriores, o mínimo é API 21 (Standard) e API 19 (Classic).
- Cota padrão: até **10.000 requisições/dia** no total, somando todas as instalações do app (é possível pedir aumento).
- Boas práticas descritas na própria doc: não usar Play Integrity como único mecanismo anti-abuso; coletar telemetria antes de aplicar qualquer enforcement; **não cachear veredictos** (aumenta o risco de "proxy attack" — reuso do veredito de um device genuíno em outro ambiente); ter estratégia de enforcement em camadas (tiered enforcement) checando primeiro `requestHash`/`nonce`, depois `appRecognitionVerdict == PLAY_RECOGNIZED` e `appLicensingVerdict == LICENSED`, só então avaliando `deviceIntegrity`.
- Veredictos adicionais, opt-in via Play Console: `MEETS_STRONG_INTEGRITY` (dispositivo com patch de segurança recente, exige Android 13+), `appAccessRiskVerdict` (apps de overlay/acessibilidade suspeitos), `playProtectVerdict`, `recentDeviceActivity` (volume anômalo de requisições) e `deviceRecall` — este último **marcado como beta** na própria doc oficial.

### Disponibilidade / Elegibilidade
GA para os veredictos principais (`accountDetails`, `appIntegrity`, `deviceIntegrity`). O sinal `deviceRecall` está explicitamente rotulado **beta** na doc consultada — não presumir GA para ele.

### Impacto para VOLTA
- `minSdk` 24 (Android 7.0) do VOLTA já é maior que o mínimo exigido pela Play Integrity API (API 23/Android 6.0) — **compatibilidade confirmada**, nenhum bloqueio de versão.
- Mesmo pré-requisito de Gradle build customizado citado na seção 1 se aplica (biblioteca distribuída via Google Play services, Java/Kotlin).
- Fase 35 (Segurança, Anti-cheat e Play Integrity) do ROADMAP é a consumidora natural deste requisito — este plano não implementa nada, só registra o requisito vigente e a compatibilidade de minSdk.

## 5. Achievements

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/achievements — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-16 UTC")
- https://developer.android.com/games/guidelines — Consultado em: 2026-08-31 (carimbo "Last updated 2026-08-26 UTC"; seção Achievements / códigos `LU-AC-*`)

### Requisitos Vigentes
- Três tipos de conquista: **Standard** (desbloqueia em um único passo), **Incremental** (progresso gradual e visível, recomendado usar tiers — ex.: "Tier 1: Defeat 1.000 enemies" → "Tier 2: 5.000" → "Tier 3: 10.000") e **Hidden** (nome/ícone/descrição ficam ocultos até o desbloqueio, útil contra spoiler).
- Elementos básicos: `ID` (gerado pelo Play Console), `Name` (até 100 caracteres), `Description` (até 500 caracteres), `Icon` (quadrado 512×512 PNG/JPEG/JPG, fundo transparente), `List order`.
- Estados possíveis: hidden, revealed (padrão inicial de uma conquista não-hidden) e unlocked (pode ser desbloqueada offline; sincroniza ao reconectar).
- Sistema de pontos/XP: `XP da conquista = 100 × valor em pontos`. Regras de pontuação: **máximo de 2.000 pontos no total** por jogo, **máximo de 200 pontos por conquista**, valores devem ser **múltiplos de 5**, e a doc recomenda reservar parte do orçamento de 2.000 pontos para conquistas futuras.
- Limite de quantidade: **máximo de 400 conquistas** na vida do jogo (mencionado na doc de achievements, associado à elegibilidade de Quests).
- Baseline obrigatório para ser "PGS-compatible" / Level Up (`LU-AC-GAA`/`GAB`): mínimo de **10 conquistas** visíveis (reveladas) espalhadas ao longo da vida do jogo, com nomes/descrições únicas e ícones únicos, todas efetivamente alcançáveis. Recomendação (best practice, não obrigatória) de **40+ conquistas**.
- Requisito específico de elegibilidade de **Quests** (`LU-AC-GAC`): pelo menos **4 conquistas** devem ser alcançáveis de forma confiável dentro da **primeira hora de jogo** por qualquer jogador — sem isso, o jogo não é elegível para a mecânica de Quests do Google Play (ver seção 12).
- Fluxo de publicação: configurar no Play Console (individualmente ou via bulk upload) → integrar as chamadas client-side ao avançar/completar a conquista → testar → publicar junto com o jogo (conquistas ficam em "Draft" até então).

### Disponibilidade / Elegibilidade
GA. Não há gate de convite para criar achievements — qualquer app com PGS v2 configurado pode cadastrar no Play Console. Porém a **visibilidade** de conquistas bloqueadas no Sidekick para todos os jogadores depende de o jogo ter conquistado o "achievements badge" (mínimo de 100 jogadores únicos chamando a Achievements API nos últimos 30 dias) — ver seção 10.

### Impacto para VOLTA
- VOLTA já tem sistema de conquistas próprio (Fase 10 — Progression: "perfil, XP, ranks, estatísticas, conquistas, desafios", conforme `ROADMAP.md`). A Fase 29 (Sistema de Conquistas e Progression Loop) precisa mapear essas conquistas existentes para IDs de achievements da PGS respeitando: mínimo de 10 (idealmente 40+), teto de 2.000 pontos totais / 200 por conquista / múltiplos de 5, e teto de 400 conquistas na vida do jogo.
- Pelo menos 4 dessas conquistas precisam ser alcançáveis em até 1h de jogo para manter elegibilidade de Quests (`LU-AC-GAC`) — informação direta para o desenho das Fases 29 e 31.

## 6. Leaderboards

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/leaderboards — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-16 UTC")

### Requisitos Vigentes
- Até **70 leaderboards** por jogo. Cada leaderboard já vem, automaticamente, em **3 janelas de tempo nativas**: diária, semanal e "all-time" — não é preciso criar leaderboard separado por janela.
- Reset diário à meia-noite Pacific Daylight Time (**UTC-7, o ano todo**); reset semanal entre sábado e domingo, no mesmo fuso.
- Ordenação: "Larger is better" (padrão) ou "Smaller is better" (ex.: tempo de corrida) — **fixa depois de publicado**, não pode ser trocada (a ordem de listagem/`List order`, por outro lado, pode mudar a qualquer momento).
- Formatos de exibição suportados nativamente: **Numeric** (inteiro ou decimal fixo, com unidades customizadas e regras de plural i18n), **Time** (submetido em milissegundos, exibido em h/m/s/centésimos), **Currency** (submetido em milionésimos da unidade principal, ex.: 19.950.000 = $19,95).
- **Social leaderboard** (círculo de amigos que compartilharam atividade com o app) e **Public leaderboard** (jogadores que compartilharam atividade publicamente) são exibidos separadamente pelo SDK; o social leaderboard fica vazio até o leaderboard ser publicado via Play Console.
- `Limits` opcionais (mínimo/máximo de score aceito, para descartar submissões fraudulentas) e `Players.hide` para ocultar jogadores suspeitos de fraude de todos os leaderboards do app.
- A API **não documenta** nenhuma janela de tempo nativa além de diário/semanal/all-time (não há "mensal" nem "por temporada custom" nativo) — isso confirma que qualquer leaderboard de temporada precisa ser implementado no backend próprio do jogo, não pela PGS.

### Disponibilidade / Elegibilidade
GA. Sem gate de convite para o recurso básico de leaderboards.

### Impacto para VOLTA
- VOLTA já tem leaderboard próprio via `packages/backend` (Fases 15/16) com múltiplas janelas de tempo, incluindo temporadas via season service (Fase 25, recém-concluída — commit "feat(phase-25): implement season service for live ops"). A PGS Leaderboards API cobre só diário/semanal/all-time nativamente — **qualquer leaderboard de temporada custom do VOLTA continua exigindo o backend próprio**; a PGS funcionaria como leaderboard adicional/espelhado para a superfície social do Google (Sidekick, You tab, Leagues), não como substituto.
- Como os dois sistemas de leaderboard (backend próprio + PGS) vão conviver é decisão de arquitetura explícita para o Plano 03, não implementada aqui — mas o requisito oficial confirma que não é possível descartar o backend próprio de leaderboard do VOLTA.

## 7. Game Stats

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/gamestats — Consultado em: 2026-08-31 (carimbo "Last updated 2026-08-28 UTC" — 3 dias antes desta consulta)
- https://developer.android.com/games/pgs/integrate-gamestats — Consultado em: 2026-08-31

### Requisitos Vigentes
- Game Stats são estatísticas cumulativas exibidas no Gamer Profile (aba "You") do jogador; alimentam Quests, Social Challenges e Leagues (mecânicas orquestradas pelo Google — ver seção 12).
- **Máximo de 50 stats** configuráveis por jogo.
- Dois tipos de dado enviados via Game Stats API: (1) **Player Events** — eventos arbitrários com propriedades de contexto, usados para "repetitive stats" calculadas por agregação `SUM`/`MAX`/`MIN`/`COUNT` sobre uma propriedade do evento, com filtro opcional; e (2) o evento predefinido **`progressUpdate`** (propriedade `currentProgress`, tipo `INT` ou `STRING`), usado para a "player progression stat" — a stat de progressão principal do jogo, que deve ser enviada no início de cada sessão e a cada atualização.
- Regras do que **pode** ser um Game Stat: não pode exigir compra (IAP) nem propaganda assistida para ser atualizado; não pode ser uso genérico do jogo (abrir o app, mudar configuração); não pode conter dado pessoal/sensível (ID de usuário, localização precisa, dado de saúde, conteúdo ofensivo); deve estar disponível para **todos** os jogadores (não pode ser stat exclusiva de um time, de um nível específico ou de liveops limitada no tempo).
- Integração: CSV de eventos (`PlayerGameEvent.csv`) + arquivo ZIP com CSVs de repetitive stats, de progression stat e de localizações + ícones, tudo enviado via Play Console (`Grow users > Play Games Services > Setup and management > Game Stats`).
- Requisito Level Up (`LU-GS-GAA`/`GAB`): mínimo de **5 repetitive stats** (com pelo menos 1 usável para "competitive player engagement features" como Leagues) **+ 1 progression stat**, se o jogo tiver mecânica de progressão principal.
- **Achado crítico de data**: a UI de Game Stats na aba "You" do Gamer Profile está disponível hoje (2026-08-31) **apenas para fins de teste**; a doc afirma textualmente: *"The Game Stats UI will be available in September 2026"* — ou seja, a superfície pública de Game Stats para jogadores comuns ainda **não está lançada** na data desta consulta, entra em produção no mês seguinte.

### Disponibilidade / Elegibilidade
**Beta/pré-lançamento da UI pública**: a API e a configuração via Play Console já existem e podem ser integradas e testadas hoje, mas a superfície visível ao jogador final (Gamer Profile "You tab") só se torna GA em setembro de 2026, segundo a própria doc consultada em 2026-08-31.

### Impacto para VOLTA
- Fase 30 (Game Stats e Integração Analytics) pode iniciar integração/testes imediatamente, mas deve considerar que a UI pública só aparece para jogadores a partir de setembro/2026 — não é bloqueador técnico, mas afeta a expectativa de "quando o jogador vai ver isso na prática".
- VOLTA precisa desenhar pelo menos 5 eventos repetíveis + 1 evento de progresso a partir de dados de partida que já existem (ex.: capturas de território, tempo de sobrevivência, causa de morte, power-ups usados) — nenhum desses pode depender de IAP nem ser genérico, restrição direta para o desenho da Fase 30.
- Teto de 50 stats a respeitar no desenho de eventos.

## 8. Play Points

### Fontes Oficiais Consultadas
- https://play.google.com/console/about/programs/googleplaypoints/ — Consultado em: 2026-08-31
- https://developer.android.com/games/pgs/play-games-sidekick — Consultado em: 2026-08-31 (menciona "Play Points boosters and coupons: Available to enrolled Play Points developers")

### Requisitos Vigentes
- Play Points é um programa de fidelidade do Google Play (220M+ membros) com níveis Bronze→Platinum; jogadores ganham pontos comprando no Play (incluindo IAP) e resgatam por itens in-app oferecidos por desenvolvedores ou por Google Play Credit.
- Participação do desenvolvedor é **por convite**: *"Selected developers are invited to provide app specific Play Points promotions"*. Depois de **"allowlisted"** (colocado em lista de permissão) para o programa, o Google fornece um guia completo de integração.
- Duas formas de oferta: **coupons** (desconto em produto gerenciado, tipicamente 40%–99% off; **sem** necessidade de trabalho de desenvolvimento — entra em vigor em até 24h após cadastro no Play Console) e **in-app items** (exigem "some technical development" após o cadastro da promoção — a fonte não detalha o SDK cliente específico de Points além disso; registro isso como **não plenamente detalhado tecnicamente** na fonte consultada).
- Mercados ativos hoje (lista literal da FAQ, 36 países): Japão, Coreia, EUA, Hong Kong, Taiwan, França, Alemanha, Reino Unido, Austrália, Noruega, Finlândia, Dinamarca, Suécia, Espanha, Itália, Grécia, Arábia Saudita, EAU, Irlanda, África do Sul, Holanda, Suíça, Nova Zelândia, Áustria, Bélgica, Portugal, Israel, Indonésia, Índia, México, Polônia, Tchéquia, Chile, Tailândia, Turquia e **Brasil**.

### Disponibilidade / Elegibilidade
**Invite-only / allowlist** — *"Selected developers are invited"* e *"After becoming allowlisted for the program, you will receive a full integration guide"*. Não é um programa de auto-inscrição aberta como o Level Up (seção 11). Geograficamente disponível no Brasil (mercado de referência do VOLTA), o que remove a barreira regional, mas a barreira de convite permanece.

### Impacto para VOLTA
- VOLTA (jogo em português do Brasil) atende o requisito geográfico (Brasil está na lista de mercados ativos), mas depende de ser convidado/allowlisted pelo Google — isso é um **risco de disponibilidade explícito** para a Fase 31 (Gamificação Avançada — XP, Quests e Rewards), que não pode assumir acesso automático a Play Points.
- O Sidekick só expõe "Play Points credit exchange" e "boosters/coupons" para devs "enrolled" (ver seção 10) — reforça que o acesso é condicional a convite, não apenas técnico.

## 9. Play Pass

### Fontes Oficiais Consultadas
- https://play.google.com/console/about/googleplaypass — Consultado em: 2026-08-31

### Requisitos Vigentes
- Play Pass é uma assinatura de catálogo curado: apps pagos ficam grátis para assinantes, anúncios in-app são removidos automaticamente para assinantes, e IAP/assinaturas ficam desbloqueadas para membros Play Pass.
- Integração técnica: usar o serviço de **licenciamento do Google Play** para restringir acesso a usuários pagantes (caso de apps pagos); definir um produto in-app que remove anúncios (caso haja ads); detectar compras novas/removidas ao voltar ao foreground via **Google Play Billing API** (caso de IAP/assinaturas) — não exige um SDK dedicado "Play Pass", reaproveita Play Billing Library e o serviço de licenciamento já usados para monetização normal.
- Monetização: royalty calculado por modelo algorítmico que combina sinais de valor entregue ao usuário (não é só tempo de uso).

### Disponibilidade / Elegibilidade
**Curated/invite**: *"All developers are welcome to **express interest** in the program and new titles are added regularly"* — ou seja, não é integração livre, é submissão de interesse seguida de curadoria do Google.
**Inconsistência encontrada na própria fonte, registrada explicitamente**: a FAQ consultada em 2026-08-31 ainda afirma *"Play Pass is initially only available in the US. We plan to add more markets over time"* — texto que soa desatualizado frente à expansão histórica conhecida do Play Pass para dezenas de países. Registrado aqui literalmente como publicado na página oficial nesta data e marcado como **Não confirmado / possível cópia de marketing desatualizada** — não deve ser tratado como fato definitivo de disponibilidade regional sem uma re-checagem direta com o Play Console Help antes da Fase 31/33.

### Impacto para VOLTA
- Play Pass depende de curadoria do Google (não é auto-serviço); a Fase 31 não deve planejar integração de Play Pass como certa — na melhor das hipóteses, submeter "expressão de interesse" e tratar como oportunidade oportunista, não como requisito de escopo.
- Tecnicamente, se aceito, a integração é de baixo esforço (reaproveita Play Billing Library, já necessário para o IAP do VOLTA) — o bloqueador não é técnico, é de elegibilidade/curadoria.

## 10. Google Play Games Sidekick

### Fontes Oficiais Consultadas
- https://developer.android.com/games/pgs/play-games-sidekick — Consultado em: 2026-08-31 (carimbo "Last updated 2026-08-20 UTC")
- https://developer.android.com/games/pgs/play-games-sidekick-sdk — Consultado em: 2026-08-31 (carimbo "Last updated 2026-06-16 UTC")
- https://developer.android.com/games/guidelines — Consultado em: 2026-08-31 (carimbo "Last updated 2026-08-26 UTC"; seção `LU-SK-*`)

### Requisitos Vigentes
- Sidekick é um **overlay de sistema/launcher do Google Play** — não é, na maioria dos casos, um SDK que o próprio jogo chama em runtime. Entrega utilitários (screenshot, screen record, YouTube Livestream, Do Not Disturb), Gemini Live e dicas em tempo real, troca de Play Points, ofertas Play Pass, achievements, streaks e Quests, tudo renderizado por cima do jogo.
- Requisitos de hardware/software do **jogador** (não do app): Android 13 ou superior, **3 GB de RAM** ou mais, um Gamer profile ativo, jogo instalado via Play Store.
- Ativação: para apps publicados como **Android App Bundle (AAB)**, basta marcar "Sidekick is on by default" no Play Console — **nenhuma dependência de código é necessária**. Para apps publicados como **APK legado** ou com solução de anti-tampering incompatível, é preciso compilar a **Sidekick SDK** (`com.google.android.play:sidekick`) diretamente no app, com `minSdkVersion` **23**, e passar por um formulário de registro prévio (aprovação leva 1–2 semanas).
- Rollout recomendado pelo Google: staged rollout de **5%** em produção antes de ir para 100%, comparando crash/ANR/engajamento/receita entre o grupo com e sem Sidekick.
- Quais features aparecem no Sidekick dependem do **status de integração** do jogo com PGS e da **inscrição em Play Points**: *"Available features on Sidekick will vary by game, depending on your Google Play Games Services integration status and Play Points enrollment."* Quests aparecem só para **"enrolled Quest developers"** (ver seção 12).
- Achievements só aparecem no Sidekick se: (a) não estiverem em "Draft" no Play Console, e (b) o jogo tiver ganhado o **"achievements badge"** (mínimo de **100 jogadores únicos** chamando a Achievements API nos últimos **30 dias**) — sem o badge, só as conquistas já desbloqueadas pelo próprio jogador aparecem.
- Configuração de posição/snooze do ponto de entrada via meta-data `com.google.android.finsky.deku.OVERLAY_CONFIG` e um XML de config (`snooze duration_seconds`, com teto de **30 minutos**).

### Disponibilidade / Elegibilidade
GA como mecanismo (ativável via Play Console para qualquer app publicado em AAB), mas com **gates internos por feature**: o achievements badge exige tração real (100 jogadores/30 dias); Play Points boosters/coupons exigem enrollment em Play Points (invite-only, seção 8); Quests exige ser "enrolled Quest developer" (sem processo de auto-serviço documentado, ver seção 12). Gemini Live dentro do Sidekick está em **Early Access Program (EAP) opcional**, sem lançamento em escala planejado para 2026 (confirmado na FAQ do Level Up, seção 11).

### Impacto para VOLTA
- Como VOLTA publica em **AAB** (`docs/mobile/android.md`: "Formato: AAB para o Play"), a ativação básica do Sidekick é apenas um toggle no Play Console — **não precisa** da Sidekick SDK separada nem do formulário de registro de 1–2 semanas (isso só se aplica a publicação via APK legado ou anti-tampering incompatível, que não é o caso do VOLTA).
- O requisito de hardware (Android 13+, 3 GB RAM) é do **aparelho do jogador**, não do minSdk do VOLTA (24/Android 7.0) — jogadores em devices mais antigos (Android 7–12) simplesmente não verão o Sidekick, sem quebrar o app.
- Fase 34 (Sidekick — Integração Completa) depende diretamente das Fases 29 (Achievements) e 30 (Game Stats) já estarem entregando dados reais, e do "achievements badge" (100 jogadores/30 dias) para aparecer para todos os jogadores — isso é uma dependência de **tração de usuários**, não só de código, relevante para o planejamento de rollout da Fase 38.

## 11. Level Up (Programa de Qualidade do Google Play)

### Fontes Oficiais Consultadas
- https://play.google.com/console/about/levelup — Consultado em: 2026-08-31
- https://developer.android.com/games/guidelines — Consultado em: 2026-08-31 (carimbo "Last updated 2026-08-26 UTC") — documento oficial "Google Play Games | Revamped Level Up guidelines", com IDs de requisito (`LU-PA`, `LU-SK`, `LU-AC`, `LU-GS`, `LU-RE`, `LU-CS`, `LU-LS`, `LU-PC`, `LU-FF`, entre outros)
- https://developer.android.com/games/pgs/quality — Consultado em: 2026-08-31 (carimbo "Last updated 2026-07-17 UTC") — "Quality checklist for Google Play Games Services" (checklist anterior/complementar, também organizado por Required/Best practice)

### Requisitos Vigentes
- Level Up é um programa (**não mandatório**: *"Is enrollment in the program mandatory? No"*) que recompensa jogos que seguem um conjunto de diretrizes de UX com uma **taxa de serviço (revenue share) menor**, além de acesso a mecânicas de engajamento (Leagues, Quests, You tab, Sidekick).
- **Rate card** com taxas reduzidas quando qualificado: 10% (assinaturas), 15% (outras transações em instalações novas), 20% (transações em instalações existentes) — contra as taxas padrão fora do programa. O rollout do rate card é **por mercado do usuário final**, não do desenvolvedor: **30/set/2026** em Austrália, EEA, Japão, Reino Unido e EUA; **31/dez/2026** na Coreia; **30/set/2027** no resto do mundo.
- Guidelines organizadas em 3 eixos, cada um com requisitos codificados (`LU-xx-GAy`) e exceções (`LU-xx-EAy`):
  1. **Experiência de gamer consistente**: Platform authentication (PGS v2 inicializado no startup), Sidekick (ligado por padrão), Achievements (mín. 10, únicas, atingíveis), Game Stats (mín. 5 repetitive + 1 progression), Rewards (mín. 2 ofertas single-use até **30/set/2026**; mín. 1 reward repetível até **1/mar/2027**), Cloud save (qualquer solução aceita).
  2. **Alcance em todas as telas**: otimização para telas grandes, disponibilidade no Google Play Games on PC, controles de precisão (controller/teclado/mouse), distribuição por form factor (Mobile/Foldables/Tablets a partir de set/2026; Chromebook a partir de 1/mar/2027; Android XR/TV/Auto a partir de set/2027 — **diretrizes dessas 3 últimas ainda não publicadas**, o próprio Google avisa que "cannot review exemption requests" até lá), disponibilidade de título equivalente entre formas.
  3. **Sessões estáveis e fluidas**: estabilidade (crash/ANR medidos contra devices de referência), performance (60 FPS, memória dentro do limite do Android 17), uso de Vulkan.
- Exceções documentadas: jogos voltados majoritariamente a menores de 13 anos são isentos de Achievements/Sidekick/Game Stats/Rewards (`LU-PA-EAA`, `LU-SK-EAA`, `LU-AC-EAA`, `LU-GS-EAA`, `LU-RE-EAA`); jogos pagos são isentos de Rewards (`LU-RE-EAB`).
- Validação: a partir de **setembro/2026**, submissão via Play Console verifica o título contra todas as diretrizes de uma vez para liberar o rate card. Participantes antigos do Level Up **não herdam automaticamente** o novo rate card — precisam cumprir as novas diretrizes anunciadas em **24/jun/2026**.

### Disponibilidade / Elegibilidade
Programa opt-in, aberto a qualquer desenvolvedor (não é invite-only para participar), mas o **benefício comercial** (rate card reduzido) tem rollout geográfico faseado (datas acima) e exige cumprir a lista completa de diretrizes revisadas em 24/jun/2026.

### Impacto para VOLTA
- Level Up conecta diretamente **todas** as demais superfícies (seções 1, 5, 7, 10, 13) num único conjunto de metas com prazos reais: Rewards precisa de pelo menos 2 ofertas single-use até 30/set/2026 e 1 repetível até 1/mar/2027; Achievements precisa de 10 mínimas (ideal 40+); Game Stats precisa de 5 repetitive + 1 progression.
- VOLTA já cumpre Cloud save (`LU-CS`) via backend próprio (seção 3) sem trabalho adicional.
- O rate card reduzido só passa a valer, na melhor hipótese, a partir de 30/set/2026 para jogadores nos EUA/UE/Reino Unido/Japão/Austrália — relevante para o planejamento financeiro das Fases 36-38, mas não é um bloqueador técnico de implementação.
- O documento de destino oficial do ROADMAP (`docs/google-play/level-up-quality.md`, referenciado pela Fase 36) fica **fora do escopo deste plano** — aqui só registro os requisitos vigentes que ele vai precisar consumir, conforme instruído pelo Plano 02.

## 12. LiveOps / Quests (conteúdo dirigido por servidor)

### Fontes Oficiais Consultadas
- https://developer.android.com/games/guidelines — Consultado em: 2026-08-31 (códigos `LU-AC-GAC`, `LU-RE-GAC`/`GAD`)
- https://developer.android.com/games/pgs/gamestats — Consultado em: 2026-08-31 (*"power Google Play features such as Quests, Social Challenges"*)
- https://developer.android.com/games/pgs/play-games-sidekick — Consultado em: 2026-08-31 (*"Quests are available to enrolled Quest developers"*)
- https://developer.android.com/games/rewards — Consultado em: 2026-08-31 (*"distributed by Google Play... after successful completion of a Quest"*)
- https://play.google.com/console/about/levelup — Consultado em: 2026-08-31 (cases de sucesso citando Quests/Leagues via Game Stats API)

### Requisitos Vigentes
- **Não existe uma "Quests API" ou "LiveOps API" dedicada e própria que o jogo integre diretamente** — em nenhuma das fontes oficiais pesquisadas há uma página de referência de API chamada Quests ou LiveOps. Quests, Leagues e Social Challenges são **mecânicas gerenciadas pelo Google Play**, construídas inteiramente sobre dados que o próprio jogo já reporta a outras APIs: Achievements API, Game Stats API e Play Games Rewards.
- Pré-requisitos técnicos indiretos para Quests, confirmados nas fontes: pelo menos **4 achievements alcançáveis na primeira hora de jogo** (`LU-AC-GAC`, seção 5); Game Stats configuradas (a própria doc de Game Stats diz que elas *"power Google Play features such as Quests, Social Challenges and more in the future"*, seção 7); pelo menos **2 ofertas de Play Games Reward single-use**, que são o mecanismo de recompensa distribuído *"after the successful completion of a Quest"* (`LU-RE-GAC`, seção 13).
- Além dos pré-requisitos técnicos, existe uma camada de **participação/enrollment**: a doc do Sidekick afirma textualmente que *"Quests are available to enrolled Quest developers"* — ou seja, mesmo cumprindo os pré-requisitos técnicos, aparecer no Sidekick com uma Quest pode depender de estar inscrito/habilitado pelo Google, de forma análoga ao Play Points (seção 8).
- **Leagues** (citada nos cases de sucesso do Level Up — SYBO/Subway Surfers com uplift de 3,3× em gasto diário de IAP; Tencent/PUBG Mobile com 20%+ de instalações de alto valor via Quests; Free Fire com 640K novos jogadores de alto valor via Leagues) também é construída *"via Game Stats API"*, reforçando o padrão: o jogo não implementa a mecânica de LiveOps em si, apenas alimenta os dados (stats, achievements, rewards) que o Google usa para orquestrar a mecânica do lado do servidor do Play.

### Disponibilidade / Elegibilidade
**Não confirmado — página não acessível/inexistente em 2026-08-31 para o processo formal de "como se tornar um enrolled Quest developer"** (URLs tentadas sem sucesso: `https://developer.android.com/games/pgs/quests`, `/games/pgs/liveops`, `/games/pgs/leagues`, `/games/pgs/android/quests` — todas retornaram HTTP 404). A arquitetura da mecânica está confirmada ("dado alimentado pelo jogo, mecânica orquestrada pelo Google"), mas o gate de participação específico de Quests não tem uma página de auto-serviço documentada nas fontes acessadas. Tratar como invite/curated até confirmação em contrário, seguindo o mesmo padrão observado em Play Points e Play Pass — recomenda-se checagem direta com o Play Console Help antes da Fase 33.

### Impacto para VOLTA
- Este é o achado mais importante para a arquitetura da Fase 33 (LiveOps — Seasons e Quests Dinâmicas): **VOLTA não pode desenhar uma integração de "Quests API" do Google**, porque ela não existe como tal. O sistema de "seasons e quests dinâmicas sem nova build" do ROADMAP da Fase 33 precisa continuar sendo **construído no backend próprio do VOLTA** (o season service já implementado na Fase 25, conforme commit "feat(phase-25): implement season service for live ops"), e a integração com o ecossistema Google Play se limita a alimentar Achievements/Game Stats/Rewards corretamente para que o Google, **se** o VOLTA for aceito como "enrolled Quest developer", possa orquestrar Quests/Leagues por cima desses dados.
- Isso evita exatamente o risco descrito no objetivo deste plano: presumir um SDK de quests do Google que não existe e desenhar a Fase 33 em cima de uma premissa errada.

## 13. Play Games Rewards

### Fontes Oficiais Consultadas
- https://developer.android.com/games/rewards — Consultado em: 2026-08-31 (carimbo "Last updated 2026-07-10 UTC")
- https://developer.android.com/games/guidelines — Consultado em: 2026-08-31 (códigos `LU-RE-*`)

### Requisitos Vigentes
- Play Games Rewards são itens in-game distribuídos pelo Google Play como incentivo, ligados a mecânicas como Quests e Social Challenges. Dois tipos: **Single Use** (alto valor, 1 por jogador — ex.: skin, personagem, arma exclusiva; usado em Quests) e **Repeatable** (baixo valor, resgatável várias vezes — ex.: moeda in-game, boosters temporários, energia; usado em Social Challenges, **máx. 1 por jogador por semana** conforme `LU-RE-GAD`).
- Mecanismo: usa a **Google Play Billing Library (PBL)** — o desenvolvedor cria/nomeia SKUs de produto único (`one-time product`) no Play Console (`Monetize with Play > Products > One-time products`) e os associa a uma oferta "Play Games Reward". Quando o Google concede a recompensa (ex.: ao completar uma Quest), o jogo precisa checar `queryPurchasesAsync` ao abrir/voltar ao foreground, processar a compra e conceder o item — o jogador tem até **3 dias** para abrir o jogo e resgatar antes de a recompensa expirar.
- Desenvolvedores que usam billing alternativo (não PBL) ainda precisam criar SKUs no Play Console e integrar com PBL especificamente para o fluxo de granting de Rewards.
- **Achado crítico de data**: a funcionalidade de criar, remover e efetivamente testar/entregar Play Games Rewards só fica disponível *"available from September 01, 2026"* — ou seja, no momento desta consulta (2026-08-31), a feature está a **1 dia** de entrar em vigor. É possível integrar o fluxo de out-of-app-purchase antes dessa data, mas o teste completo só funciona a partir de 1/set/2026.
- Se o jogo suportar múltiplas identidades in-game, é obrigatório perguntar ao jogador para qual identidade a recompensa deve ir — o jogador só vê a recompensa se o PGS ID e a conta de Play Billing coincidirem.

### Disponibilidade / Elegibilidade
GA a partir de **01/09/2026** (praticamente imediata a partir da data desta consulta) — não é invite-only, mas tem uma data de lançamento específica e recente que precisa ser respeitada no planejamento (não presumir que já está disponível para testes completos antes dessa data).

### Impacto para VOLTA
- Fase 31 (Gamificação Avançada — XP, Quests e Rewards) pode e deve considerar Play Games Rewards no desenho, mas precisa saber que testes end-to-end só serão possíveis a partir de 1/set/2026 — um dia após esta pesquisa.
- Como VOLTA já usa (ou vai usar) a Play Billing Library para monetização própria (cosméticos — Fase 11; monetização e "live operations handbook" — Fase 25), reaproveitar a PBL para o granting de Rewards é tecnicamente direto — o esforço adicional é cadastrar as SKUs de recompensa (mín. 2 single-use até 30/set/2026 para cumprir Level Up) e implementar o polling `queryPurchasesAsync` no boot/foreground.
- Jogos majoritariamente para menores de 13 anos e jogos pagos são isentos deste requisito (`LU-RE-EAA`/`EAB`) — não é o caso do VOLTA (jogo arcade geral, não documentado como voltado para crianças nem como "paid game" nos documentos do projeto).

## 14. Resumo de Disponibilidade

| Superfície | Status (GA/Beta/Invite-only/Regional/Não confirmado) | Bloqueador para VOLTA | Fase que consome |
|---|---|---|---|
| 1. Play Games Services v2 — Sign-In | GA | Nenhum de elegibilidade; requer habilitar Gradle build customizado no export Android do VOLTA (hoje `use_gradle_build=false`) | Fase 28 |
| 2. Recall API | GA (uso opcional) | Nenhum — decisão de arquitetura, já existe backend próprio de identidade | Fase 28 |
| 3. Saved Games / Cloud Save | GA (Saved Games da PGS é opcional; qualquer cloud save conta para o Level Up) | Nenhum — VOLTA já cumpre via backend próprio (`SaveService`) | Fase 28 |
| 4. Play Integrity API | GA (`deviceRecall` em beta) | Nenhum de versão (minSdk 24 > mínimo API 23); requer Gradle build customizado | Fase 35 |
| 5. Achievements | GA | Nenhum — requer desenhar ≥10 (ideal 40+) conquistas mapeadas do sistema já existente | Fase 29 |
| 6. Leaderboards | GA | PGS só cobre diário/semanal/all-time nativamente; leaderboards de temporada continuam exigindo o backend próprio do VOLTA | Fase 32 |
| 7. Game Stats | Beta/pré-lançamento da UI pública (API disponível; UI do "You tab" GA só em set/2026) | Nenhum técnico; expectativa de visibilidade ao jogador adiada para set/2026 | Fase 30 |
| 8. Play Points | Invite-only (allowlist) | Sim — depende de convite/allowlisting do Google, fora do controle do VOLTA; Brasil está na lista de mercados ativos | Fase 31 |
| 9. Play Pass | Invite-only/curated (express interest) | Sim — depende de curadoria do Google; fonte com possível inconsistência sobre disponibilidade regional (marcado Não confirmado) | Fase 31 / Fase 33 |
| 10. Google Play Games Sidekick | GA (mecanismo); Play Points/Quests dentro dele são gated | Achievements badge exige 100 jogadores únicos/30 dias — depende de tração de usuários, não só de código | Fase 34 |
| 11. Level Up (Programa de Qualidade) | GA para participação; rate card reduzido com rollout regional faseado (30/set/2026 em diante) | Nenhum técnico direto; requer cumprir o conjunto completo de guidelines (Achievements, Game Stats, Rewards, Sidekick, Cloud save, performance) | Fase 36 |
| 12. LiveOps / Quests | Não confirmado (mecânica confirmada como orquestrada pelo Google sobre Achievements/Game Stats/Rewards; enrollment específico de Quests não documentado) | Sim — não existe "Quests API" para integrar; Fase 33 deve continuar usando o backend próprio de seasons/quests do VOLTA | Fase 33 |
| 13. Play Games Rewards | GA a partir de 01/09/2026 | Nenhum técnico; teste completo só possível a partir de 1/set/2026 (1 dia após esta pesquisa) | Fase 31 |

**Superfícies cuja disponibilidade não pôde ser confirmada por completo** (registradas explicitamente para o Plano 03 tratar como risco): Play Pass (inconsistência de mercado na FAQ oficial, seção 9) e o processo formal de enrollment de Quests dentro de LiveOps/Quests (seção 12, URLs de referência retornaram 404).

