---
sidebar_position: 3
---

# Gerenciar e revogar

Toda conexão feita por OAuth aparece no painel, e é lá que você a acompanha, ajusta ou remove.

## Onde ver as conexões

No painel, abra o menu **Conta** e clique em **Conexão com IA (MCP)**.

![Menu Conta aberto, com o item Conexão com IA (MCP)](/img/mcp-oauth/como-conectar/11-onde-fica.png)

1. **Abra o menu Conta**, na barra lateral.
2. **Clique em Conexão com IA (MCP).**

A página lista todas as conexões da sua conta.

![Conexão criada pelo login, listada no painel](/img/mcp-oauth/como-conectar/10-conexao-no-painel.png)

1. **A conexão criada pelo login**, com o nome do cliente (aqui, `Claude Code (goab-mcp)`) e o final do identificador dela.
2. **As contas** que você autorizou.
3. **Os três pontos (⋮)**, que abrem as ações da conexão.

Cada linha mostra também as **permissões** concedidas, o **último uso** e a data em que a conexão **expira**.

## O que dá para fazer em cada conexão

Clique nos três pontos (⋮) da conexão para abrir o menu de ações.

![Menu de ações da conexão, com a opção Revogar](/img/mcp-oauth/como-conectar/12-menu-acoes.png)

1. **Clique nos três pontos** da conexão que você quer ajustar.
2. **Revogar** remove a conexão na hora. As outras opções do menu:

| Ação | Para quê |
|---|---|
| **Editar permissões** | Liberar ou tirar permissões sem refazer o login. |
| **Renomear** | Dar um nome que ajude você a reconhecer a conexão. |
| **Copiar configuração** | Copiar os dados para configurar um cliente. |
| **Revogar** | Remover a conexão. O agente perde o acesso na hora. |

Para remover todas de uma vez, use **Revogar todas**, no topo da página.

## Quando a conexão expira

A conexão **renova a cada uso**: enquanto você a usa, ela não expira. Se ficar parada por muito tempo, a data de **Expira em** chega e o acesso termina.

Para voltar, rode `/mcp` no Claude Code e escolha **Authenticate** de novo. Uma nova conexão é criada.

:::caution Revogou, perdeu o acesso
Depois de **Revogar**, o agente deixa de funcionar com aquela conexão. Se você precisar dele de novo, refaça o [passo a passo](./como-conectar).
:::
