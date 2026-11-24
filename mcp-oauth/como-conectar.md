---
sidebar_position: 2
---

# Passo a passo

Você registra o servidor no Claude Code, faz login pelo navegador e confirma no painel quais contas e permissões o agente terá. Leva poucos minutos.

## Antes de começar

- Tenha o **Claude Code** instalado e abra um terminal na pasta onde você vai trabalhar.
- Entre no painel da GoAB (`app.goab.io`) no navegador padrão do computador. É nele que o login vai abrir.

## 1. Registre o servidor

No terminal, rode:

```bash
claude mcp add --transport http goab-mcp https://mcp.goab.io/mcp
```

![Comando para registrar o servidor e a confirmação](/img/mcp-oauth/como-conectar/01-adicionar-servidor.png)

1. **Digite o comando e pressione Enter.** `goab-mcp` é só o nome local do servidor: você pode escolher outro.
2. **A confirmação.** O servidor foi adicionado.

:::tip Quer usar em qualquer pasta?
Por padrão, o servidor fica registrado só no projeto (a pasta) em que você rodou o comando. Para usá-lo em todos os projetos, acrescente `--scope user` ao comando.
:::

## 2. Abra o Claude Code

Na mesma pasta, rode `claude`.

![Claude Code aberto, avisando que o servidor precisa de login](/img/mcp-oauth/como-conectar/02-claude-aberto.png)

1. **O aviso.** O Claude Code informa que um servidor MCP precisa de autenticação e sugere rodar `/mcp`. Digite `/mcp` e pressione Enter.

## 3. Abra a lista de servidores

Digite `/mcp` e pressione Enter. O `goab-mcp` aparece como **needs sign-in** (precisa de login). Selecione-o e pressione Enter.

![Lista de servidores MCP com o goab-mcp aguardando login](/img/mcp-oauth/como-conectar/03-lista-mcp.png)

1. **Selecione `goab-mcp` e pressione Enter.** Ele aparece ainda sem login (**needs sign-in**).

## 4. Clique em Authenticate

Na tela do servidor, deixe **Authenticate** selecionado e pressione Enter.

![Tela do servidor com a opção Authenticate](/img/mcp-oauth/como-conectar/04-tela-do-servidor.png)

1. **Clique em Authenticate** (ou pressione Enter). O navegador abre na tela de autorização do painel.

## 5. Escolha as contas

No navegador, a tela **Autorizar Claude Code** lista as contas a que você tem acesso. **Marque só as contas** que o agente poderá usar.

![Tela de autorização com a lista de contas](/img/mcp-oauth/como-conectar/05-consentimento-contas.png)

1. **Clique na caixa da conta** para marcá-la. O agente só enxerga as que você marcar: marque o mínimo de que precisa.
2. **Seu papel na conta** aparece ao lado do nome (Leitor, Administrador, Proprietário). É ele que limita o que o agente pode fazer.

## 6. Confira as permissões

Logo abaixo, em **Permissões pedidas pelo aplicativo**, ficam as permissões que o agente quer. Todas vêm marcadas, e você pode **desmarcar** as que não quiser dar.

![Permissões pedidas pelo aplicativo](/img/mcp-oauth/como-conectar/06-consentimento-permissoes.png)

1. **O que a conta não permite não é concedido.** O aviso azul lista o que o agente pediu e o seu papel não permite, como criar, editar ou publicar. Essas permissões não são liberadas, mesmo com o Autorizar.
2. **A lista de permissões.** Clique para desmarcar as que não quiser dar. Neste exemplo, só leitura e comentários no histórico.

## 7. Autorize

Role até o fim da página e clique em **Autorizar**.

![Botão Autorizar ao fim da lista de permissões](/img/mcp-oauth/como-conectar/07-consentimento-autorizar.png)

1. **Clique em Autorizar** para concluir o login. Para desistir, use **Cancelar**.

O navegador mostra uma página com **Authentication successful**. Pode fechá-la e voltar ao Claude Code.

## 8. Confirme a conexão

De volta ao terminal, o Claude Code avisa que o login foi concluído.

![Claude Code informando que entrou e conectou ao goab-mcp](/img/mcp-oauth/como-conectar/08-conectado.png)

1. **Login concluído.** A partir daqui o Claude já usa o servidor da GoAB.

## 9. Faça um pedido

Peça algo que use a GoAB, por exemplo: **liste todas as contas da GoAB**. O Claude chama o servidor e responde.

![Pedido ao Claude e a lista das contas autorizadas](/img/mcp-oauth/como-conectar/09-prompt-real.png)

1. **Digite seu pedido e pressione Enter.** Fale com o Claude normalmente.
2. **A resposta mostra só a conta autorizada**, o seu papel nela e que o acesso é somente leitura.

:::note Contas e produtos
Cada conta traz os produtos contratados (por exemplo Heatmap, Survey Web, Mobile e Survey App). O agente só enxerga os que a conta tem.
:::

Para ver a conexão no painel e removê-la depois, veja [Gerenciar e revogar](./gerenciar-e-revogar).
