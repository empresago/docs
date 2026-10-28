---
sidebar_position: 9
---

# Atributos e classes

Atributos HTML (como `title` e `data-*`) e classes CSS ficam na aba **Configurações** do painel de edição.

## Atributos

1. [Selecione o elemento](./selecionar-elementos) e abra o painel de edição pelo **lápis**.
2. Abra a aba **Configurações**. O grupo **Atributos** mostra os atributos do elemento.

   ![Aba Configurações com o grupo Atributos](/img/editor-visual/atributos-e-classes/01-atributos.png)

   1. Aba **Configurações**.
   2. **+ Adicionar atributo**: cria uma nova linha para um atributo.

   :::info
   Atributos que já têm campo próprio na aba **Estilo** — como o `href` de um link ou o `src` de uma imagem — não aparecem aqui: edite-os pelos campos de [Imagem e link](./imagem-e-link).
   :::

3. Clique em **+ Adicionar atributo**, informe o **nome** do atributo e o **valor** e clique em **Aplicar ao DOM**.

   ![Novo atributo com nome e valor preenchidos](/img/editor-visual/atributos-e-classes/02-novo-atributo.png)

   1. **Nome** do atributo (por exemplo, `title`).
   2. **Valor** do atributo.
   3. **Aplicar ao DOM**: confirma a alteração.

Marque **rm** na linha de um atributo existente para removê-lo ao aplicar. Para desistir de uma linha nova, clique no **X** ao lado dela.

## Classes

As classes controlam o visual do elemento por meio do CSS do seu site. No grupo **Classes**, você vê as classes atuais e pode acrescentar novas.

![Grupo Classes com as classes do elemento](/img/editor-visual/atributos-e-classes/03-classes.png)

1. As **classes** que o elemento já tem, em forma de etiquetas.
2. Campo para o **nome da nova classe**. Informe uma classe por vez, sem espaços.
3. **Adicionar**: inclui a classe no elemento. Depois, confirme com **Aplicar ao DOM**.

:::tip Quando usar
Use uma classe quando o seu site já tem um estilo pronto para ela (por exemplo, uma classe de destaque). Para ajustes visuais pontuais, prefira os grupos da aba [Estilo](./estilos).
:::

## Próximo passo

Veja como [reagir a cliques e outros eventos](./eventos) em um elemento.
