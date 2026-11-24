---
slug: /
sidebar_position: 1
---

# Conectar o MCP da GoAB

O **MCP** (Model Context Protocol) é o jeito de um agente de IA, como o **Claude Code**, usar a GoAB por você: listar experimentos, ver resultados, consultar heatmaps e pesquisas, e, se você permitir, também criar e editar.

Este guia mostra como conectar o agente por **OAuth**: você informa só o endereço do servidor, faz login no painel pelo navegador e escolhe **quais contas** e **quais permissões** o agente terá. Não é preciso copiar nem guardar nenhum token.

## O endereço do servidor

```text
https://mcp.goab.io/mcp
```

## O que você ganha

- **Login simples.** Um comando para registrar o servidor e um clique em **Authenticate**.
- **Você escolhe o alcance.** O agente só enxerga as contas que você marcar e só faz o que as permissões liberadas permitirem.
- **O seu papel no painel é o limite.** Se você é **Leitor** numa conta, o agente só lê, mesmo que peça mais.
- **Revogação a qualquer hora.** Cada conexão aparece no painel e pode ser removida quando você quiser.

## O que você precisa ter

1. O **Claude Code** instalado no computador.
2. Um usuário no painel da GoAB com acesso a pelo menos uma conta.
3. O item **Conexão com IA (MCP)** no menu **Conta** do painel. Se ele não aparecer, o recurso pode não estar habilitado na sua conta: fale com o suporte.

:::info Este guia usa o Claude Code
Os prints mostram o Claude Code no terminal, conectado a uma conta em que o usuário é **Leitor**. O painel também traz, em **Como conectar o seu cliente de IA**, o passo a passo por token e para outros clientes.
:::

Pronto para começar? Siga o [passo a passo](./como-conectar).
