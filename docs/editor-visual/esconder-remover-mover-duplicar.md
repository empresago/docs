---
sidebar_position: 12
---

# Esconder, remover, mover e duplicar

Além de editar o conteúdo, você pode mudar a estrutura da página na variante: esconder um elemento, removê-lo, trocá-lo de lugar ou duplicá-lo. Todas as ações estão no **menu do elemento** (⋯ na [barra rápida](./selecionar-elementos#menu-do-elemento)) e podem ser desfeitas com **Desfazer** (`Ctrl+Z`).

## Mover para baixo

Troca o elemento de lugar com o irmão que vem logo depois dele (por exemplo, o parágrafo passa para depois dos botões).

1. [Selecione o elemento](./selecionar-elementos) e abra o menu do elemento (⋯).
2. Clique em **Mover para baixo**.

   ![Item Mover para baixo no menu do elemento](/img/editor-visual/esconder-remover-mover-duplicar/01-mover-para-baixo.png)

3. O elemento desce uma posição. Para voltar, use **Desfazer**.

   ![Elemento movido para depois dos botões](/img/editor-visual/esconder-remover-mover-duplicar/02-movido.png)

   1. O elemento na nova posição.
   2. **Desfazer**: volta o elemento para onde estava.

## Copiar (duplicar) um elemento

Cria uma cópia idêntica logo depois do elemento selecionado. É útil para repetir um bloco e alterar só a cópia.

1. No menu do elemento, clique em **Copiar elemento**.

   ![Item Copiar elemento no menu do elemento](/img/editor-visual/esconder-remover-mover-duplicar/03-copiar-elemento.png)

2. A cópia aparece logo abaixo do original, e o editor avisa **Elemento duplicado**.

   ![Original e cópia do elemento](/img/editor-visual/esconder-remover-mover-duplicar/04-copiado.png)

   1. O elemento **original**.
   2. A **cópia**, logo depois dele.

:::tip Guardar para usar depois
Para reutilizar um elemento em outras páginas ou variantes, use **Salvar na biblioteca**, descrito em [Biblioteca de elementos](./biblioteca-de-elementos).
:::

## Ocultar um elemento

Esconde o elemento da página sem apagá-lo.

1. No menu do elemento, clique em **Ocultar elemento**.

   ![Item Ocultar elemento no menu do elemento](/img/editor-visual/esconder-remover-mover-duplicar/05-ocultar-elemento.png)

2. O elemento some da página e o botão **Salvar** é liberado.

   ![Página com o elemento ocultado](/img/editor-visual/esconder-remover-mover-duplicar/06-ocultado.png)

   1. **Desfazer**: faz o elemento reaparecer.

## Excluir um elemento

Remove o elemento da variante. Como é uma ação mais forte, o editor pede confirmação.

1. No menu do elemento, clique em **Excluir elemento**.
2. Na janela de confirmação, clique em **Excluir elemento** para confirmar ou em **Cancelar** para desistir.

   ![Confirmação para excluir o elemento](/img/editor-visual/esconder-remover-mover-duplicar/07-excluir.png)

   1. **X** (fechar): equivale a cancelar.
   2. **Excluir elemento**: confirma a exclusão.

   A janela lembra que dá para desfazer logo em seguida com `Ctrl+Z`.

## Resultado

Depois de [salvar](./salvar-e-desfazer) e [publicar](./publicar-no-painel), abra a variante pelo [link de prévia](./publicar-no-painel#conferir-o-resultado-pelo-link-de-prévia).

### Ocultar e mover

Neste exemplo, o botão **Conhecer a plataforma** foi ocultado e o parágrafo foi movido para baixo do botão **Ver planos**.

**Controle (antes):**

![Controle com a ordem original](/img/editor-visual/esconder-remover-mover-duplicar/resultado-antes.png)

**Variante (depois):**

![Variante com o parágrafo movido e um botão oculto](/img/editor-visual/esconder-remover-mover-duplicar/resultado-depois.png)

1. O parágrafo, agora depois do botão.
2. O botão **Ver planos**, que subiu. O botão **Conhecer a plataforma** não aparece mais.

### Copiar

**Controle (antes):**

![Controle com um único parágrafo](/img/editor-visual/esconder-remover-mover-duplicar/resultado-duplicar-antes.png)

**Variante (depois):**

![Variante com o parágrafo duplicado](/img/editor-visual/esconder-remover-mover-duplicar/resultado-duplicar-depois.png)

1. O parágrafo original.
2. A cópia, logo depois dele.

## Qual usar?

| Quero… | Use |
|---|---|
| Fazer o elemento sumir, mas poder trazê-lo de volta com facilidade | **Ocultar elemento** |
| Tirar o elemento da variante de vez | **Excluir elemento** |
| Reordenar a página | **Mover para baixo** |
| Repetir um bloco | **Copiar elemento** |

## Próximo passo

Para reaproveitar elementos entre páginas, veja a [Biblioteca de elementos](./biblioteca-de-elementos).
