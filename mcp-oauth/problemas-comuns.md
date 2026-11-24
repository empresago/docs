---
sidebar_position: 4
---

# Problemas comuns

## O Claude Code diz «1 MCP server needs authentication»

O servidor está registrado, mas ainda sem login. Rode `/mcp`, selecione o `goab-mcp` e escolha **Authenticate**. Veja os passos [3 e 4](./como-conectar#3-abra-a-lista-de-servidores).

## A tela de autorização não lista a conta que eu quero

A lista traz só as contas em que o seu usuário tem acesso. Confira com quem administra a conta se o seu usuário foi convidado para ela.

## O painel diz que uma permissão «não será concedida»

O seu **papel** na conta (por exemplo, Leitor) não permite aquela ação. O agente nunca recebe mais do que o seu papel permite. Para liberar escrita, peça a alguém da conta que altere o seu papel e refaça a conexão.

## A conexão parou de funcionar depois de trocar a senha

Conexões criadas **antes da última troca de senha** da conta deixam de valer. O servidor responde que a conexão não vale mais. Entre em **Conta → Conexão com IA (MCP)**, revogue a antiga e refaça o login com `/mcp` → **Authenticate**.

## Aparece «Dynamic Client Registration rejected»

O servidor recusou o registro do cliente durante o login. Tente de novo com `/mcp` → **Authenticate**. Se o erro continuar, avise o suporte (`suporte@goab.io`) com a mensagem completa.

## O navegador abre, mas pede login

A tela de autorização exige que você esteja logado no painel. Entre com o seu usuário e, se o painel levar você a outra página, volte ao Claude Code e rode **Authenticate** de novo.

## O Claude ainda enxerga contas que eu não quis

Abra **Conta → Conexão com IA (MCP)** e confira a coluna **Contas** da conexão. Para mudar o alcance, revogue a conexão e refaça o login marcando só as contas desejadas.
