---
sidebar_position: 5
---

# Editar texto

Troque o texto de títulos, parágrafos, botões e links, e aplique negrito, itálico, sublinhado, alinhamento e cor sem sair da página.

## Trocar o texto de um elemento

1. [Selecione o elemento](./selecionar-elementos) e clique no **lápis** da barra rápida para abrir o painel de edição.
2. Na aba **Estilo**, o grupo **Conteúdo** já vem aberto. O campo **Texto** mostra o texto atual do elemento.

   ![Painel de edição com a aba Estilo e o campo Texto](/img/editor-visual/editar-texto/01-painel-conteudo.png)

   1. Aba **Estilo**: conteúdo e aparência do elemento.
   2. Campo **Texto**: o texto atual do elemento.

3. Digite o novo texto. A página mostra a mudança enquanto você escreve, e um número azul no grupo **Conteúdo** indica que ele tem alterações.
4. Clique em **Aplicar ao DOM** para confirmar a alteração. Se preferir voltar atrás, clique em **Descartar**.

   ![Texto digitado e botão Aplicar ao DOM](/img/editor-visual/editar-texto/02-texto-digitado.png)

   1. O novo texto no campo.
   2. **Aplicar ao DOM**: confirma a alteração.

5. O painel fecha e o elemento aparece com a etiqueta **Editado**. O botão **Salvar** da barra fica ativo, e o contador no botão **Ver código** mostra quantos elementos já foram alterados.

   ![Elemento editado na página](/img/editor-visual/editar-texto/03-texto-aplicado.png)

   1. O elemento alterado, marcado como **Editado**.
   2. **Desfazer** e **Refazer**: voltam e avançam as alterações.
   3. **Salvar**: grava a variante.

:::info Se o elemento tem outros elementos dentro
Quando o elemento contém outros elementos (por exemplo, um título com uma palavra em destaque), o campo **Texto** não aparece e você edita o conteúdo pelo [editor de HTML](./editar-html).
:::

## Estilos rápidos: negrito, itálico, alinhamento e cor

Com um elemento selecionado, clique em **Estilos** na barra do editor para abrir os atalhos de formatação:

![Menu de estilos rápidos](/img/editor-visual/editar-texto/04-estilos-rapidos.png)

1. **Negrito**, **itálico** e **sublinhado**.
2. **Alinhamento** do texto: esquerda, centralizado, direita ou justificado.
3. **Cor do texto**: clique no círculo para escolher a cor.
4. **Editar tudo**: abre os grupos de estilo completos (tipografia, espaçamento, dimensões, layout e visual), descritos em [Estilos](./estilos).

Clique em um atalho para aplicar na hora. Por exemplo, ao clicar em **negrito**, o texto selecionado fica em negrito:

![Texto em negrito depois de clicar no atalho](/img/editor-visual/editar-texto/05-negrito-aplicado.png)

1. O texto, agora em negrito.
2. O atalho **Negrito**, que fica destacado enquanto o estilo está ativo.

Para fechar o menu, clique outra vez em **Estilos**. Se não gostar do resultado, use **Desfazer** na barra do editor.

## Resultado

Depois de [salvar](./salvar-e-desfazer) e [publicar](./publicar-no-painel), abra a variante pelo [link de prévia](./publicar-no-painel#conferir-o-resultado-pelo-link-de-prévia). O **Controle** mostra a página original; a variante mostra o texto novo.

**Controle (antes):**

![Controle com o texto original](/img/editor-visual/editar-texto/resultado-antes.png)

**Variante (depois):**

![Variante com o texto alterado](/img/editor-visual/editar-texto/resultado-depois.png)

1. O texto alterado, e a caixa **GoAB Prévia** confirmando **Variante aplicada (prévia)**.

## Próximo passo

Para mudar tamanho, cor, espaçamento e outros detalhes visuais, veja [Estilos](./estilos).
