---
sidebar_position: 7
---

# Editar HTML

Quando o ajuste que você precisa vai além de texto e estilo — trocar um trecho inteiro, incluir um ícone, reorganizar o que está dentro de um bloco —, edite o HTML do elemento diretamente.

O editor oferece três caminhos, conforme o que você quer fazer.

## Editor de HTML externo

O **HTML externo** é o elemento completo: a etiqueta, os atributos e o conteúdo dele.

1. [Selecione o elemento](./selecionar-elementos) e abra o painel de edição pelo **lápis**.
2. Na aba **Estilo**, no grupo **Conteúdo**, clique em **Abrir editor HTML Externo**.

   ![Botão Abrir editor HTML Externo no painel](/img/editor-visual/editar-html/01-abrir-html-externo.png)

3. O **Editor HTML** abre sobre a página, mostrando o código do elemento.

   ![Editor HTML aberto com o código do elemento](/img/editor-visual/editar-html/02-editor-html.png)

   1. O **código** do elemento. Altere o que precisar.
   2. **Descartar**: fecha sem aplicar as mudanças.
   3. **Salvar**: aplica o código editado ao elemento na página.

:::tip Elementos com outros elementos dentro
Quando o elemento contém outros elementos (um bloco com título, texto e botão, por exemplo), o grupo **Conteúdo** mostra também **Abrir editor HTML Interno**, que edita apenas o que está dentro do elemento, sem mexer na etiqueta e nos atributos dele.
:::

## Editar código pelo menu do elemento

O menu do elemento (⋯ na [barra rápida](./selecionar-elementos#menu-do-elemento)) tem a opção **Editar código**, que abre o código do elemento em uma gaveta na lateral direita da tela:

![Gaveta de código com o HTML do elemento](/img/editor-visual/editar-html/03-editar-codigo.png)

1. O **código** do elemento, com destaque de sintaxe. A barra inferior da gaveta avisa se há erro de sintaxe.
2. O botão de **aplicar** as alterações ao elemento. Ele indica **Aplicado** quando não há nada pendente.

## Cuidados

- Alterações de HTML valem para o **elemento selecionado**; confira o resultado na página antes de salvar.
- Prefira os campos de [texto](./editar-texto) e [estilos](./estilos) quando eles resolvem: são mais simples de manter.

## Resultado

Depois de [salvar](./salvar-e-desfazer) e [publicar](./publicar-no-painel), abra a variante pelo [link de prévia](./publicar-no-painel#conferir-o-resultado-pelo-link-de-prévia). Neste exemplo, o HTML do parágrafo foi trocado por uma versão com uma parte em negrito.

**Controle (antes):**

![Controle com o parágrafo original](/img/editor-visual/editar-html/resultado-antes.png)

**Variante (depois):**

![Variante com o HTML alterado](/img/editor-visual/editar-html/resultado-depois.png)

1. O parágrafo com o novo HTML (o trecho em negrito).
