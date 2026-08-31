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
