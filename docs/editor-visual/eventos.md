---
sidebar_position: 10
---

# Eventos

Com os **eventos**, um elemento reage a uma ação do visitante — um clique, por exemplo — mostrando outro elemento, trocando uma classe ou levando para outro lugar da página. Tudo é configurado em campos, sem escrever código.

Cada evento combina um **gatilho** (o que o visitante faz) e uma **ação** (o que acontece em resposta).

## Adicionar um evento

1. [Selecione o elemento](./selecionar-elementos) que vai receber o gatilho (por exemplo, um botão) e abra o painel de edição pelo **lápis**.
2. Na aba **Configurações**, abra o grupo **Eventos** e clique em **+ Adicionar evento**.

   ![Linha de evento com gatilho, ação e alvo](/img/editor-visual/eventos/01-novo-evento.png)

   1. **Gatilho**: o que o visitante faz. As opções são **Clique**, **Duplo clique**, **Mouse entra**, **Mouse sai**, **Foco**, **Perde o foco**, **Alteração** e **Digitação**.
   2. **Ação**: o que acontece em resposta. As opções são **Adicionar classe**, **Remover classe**, **Alternar classe**, **Mostrar**, **Ocultar**, **Alternar visibilidade**, **Rolar até** e **Abrir link**.
   3. **Alvo**: o seletor do elemento que sofre a ação. Deixe vazio para agir sobre o próprio elemento.

3. Escolha o gatilho e a ação, preencha o alvo se necessário e clique em **Aplicar ao DOM**.
4. Clique em **Salvar** para gravar a variante.

Para remover um evento, clique no **X** ao lado da linha.

:::info Como testar
Os eventos funcionam na variante publicada, para os visitantes. Para conferir, publique o teste e acesse a variante pelo link de visualização.
:::

## Resultado

Depois de [salvar](./salvar-e-desfazer) e [publicar](./publicar-no-painel), abra a variante pelo [link de prévia](./publicar-no-painel#conferir-o-resultado-pelo-link-de-prévia) e clique no elemento. Neste exemplo, a etiqueta **PLATAFORMA DE EXPERIMENTAÇÃO E CRO** recebeu o evento **Clique → Ocultar**.

**Antes do clique:**

![Variante com a etiqueta visível](/img/editor-visual/eventos/resultado-antes-do-clique.png)

1. O elemento que recebeu o evento.

**Depois do clique:**

![Variante com a etiqueta oculta depois do clique](/img/editor-visual/eventos/resultado-depois-do-clique.png)

A etiqueta desapareceu e o conteúdo abaixo subiu.

## Próximo passo

Veja o código que o editor gera em [Ver código](./ver-codigo).
