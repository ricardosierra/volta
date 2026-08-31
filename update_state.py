import re

state_path = "/Users/sierra/Dev/Jogos/volta/.planning/STATE.md"

with open(state_path, 'r') as f:
    content = f.read()

phases_info = [
    (26, "Google Play Discovery - Auditoria de Gamificação e Sidekick"),
    (27, "Gamification Foundation - Eventos de Dominio e Integracao"),
    (28, "Play Games Services v2 e Autenticacao"),
    (29, "Sistema de Conquistas e Progression Loop"),
    (30, "Game Stats e Integracao Analytics"),
    (31, "Gamificacao Avancada - XP Quests e Rewards"),
    (32, "Leaderboards e Social Engagement"),
    (33, "LiveOps - Seasons e Quests Dinamicas"),
    (34, "Google Play Games Sidekick - Integracao Completa"),
    (35, "Seguranca Anti-cheat e Play Integrity"),
    (36, "QA Gamificacao e Sidekick"),
    (37, "Performance Gamificacao e Otimizacao"),
    (38, "Release - Rollout Google Play Games")
]

# Find Roadmap Evolution
evolution_idx = content.find("### Roadmap Evolution")
if evolution_idx != -1:
    lines = []
    for num, name in phases_info:
        lines.append(f"- Phase {num} added: {name}")
    new_evolution = "### Roadmap Evolution\n" + "\n".join(lines) + "\n"
    content = content.replace("### Roadmap Evolution\n", new_evolution)
else:
    # insert before Pending Todos
    todo_idx = content.find("### Pending Todos")
    lines = []
    for num, name in phases_info:
        lines.append(f"- Phase {num} added: {name}")
    new_evolution = "### Roadmap Evolution\n" + "\n".join(lines) + "\n\n"
    content = content[:todo_idx] + new_evolution + content[todo_idx:]

with open(state_path, 'w') as f:
    f.write(content)

