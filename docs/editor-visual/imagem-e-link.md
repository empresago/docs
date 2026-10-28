---
sidebar_position: 8
---

# Imagem e link

Troque o texto e o destino de links e botões, e ajuste a origem, o texto alternativo e o tamanho de imagens.

## Links e botões

Elementos que levam para outra página (links e botões-link, como **Ver planos**) ganham campos próprios no painel de edição.

1. [Selecione o link](./selecionar-elementos) e abra o painel de edição pelo **lápis**.
2. Na aba **Estilo**, no grupo **Conteúdo**, edite o que precisar:

   ![Campos de edição de um link](/img/editor-visual/imagem-e-link/01-link.png)

   1. **Texto**: o que aparece escrito no link ou botão.
   2. **Href**: o endereço de destino.
   3. **Target**: onde o destino abre — na mesma aba (`_self`) ou em outra, entre as opções da lista.
   4. **Rel**: marque `noopener`, `noreferrer` ou `nofollow` conforme a necessidade.
   5. **Download**: ative para que o link baixe o arquivo em vez de abrir uma página.

3. Clique em **Aplicar ao DOM**. O link fica marcado como **Editado** e o botão **Salvar** é liberado.

   ![Botão com o texto alterado](/img/editor-visual/imagem-e-link/02-link-aplicado.png)

   1. O link com o novo texto.
   2. **Salvar**: grava a variante.

## Imagens

1. Selecione a imagem e abra o painel de edição.
2. No grupo **Conteúdo** estão os campos da imagem:

   ![Campos de edição de uma imagem](/img/editor-visual/imagem-e-link/03-imagem.png)

   1. **Src**: o endereço da imagem. Cole aqui o endereço de outra imagem para trocá-la.
   2. **Alt**: o texto alternativo, lido por leitores de tela e exibido se a imagem não carregar.
   3. **Width** e **Height**: largura e altura (por exemplo, `200` ou `100%`; `150` ou `auto`).
   4. **Loading**: quando a imagem é carregada.

3. Clique em **Aplicar ao DOM** e depois em **Salvar**.

:::tip Imagem nova
A imagem precisa estar publicada em um endereço acessível pelo seu site. O editor não envia arquivos: ele usa o endereço que você informar em **Src**.
:::

## Próximo passo

Para ajustar o visual de um elemento, veja [Estilos](./estilos). Para atributos que não têm campo próprio, veja [Atributos e classes](./atributos-e-classes).
