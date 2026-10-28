---
sidebar_position: 6
---

# Estilos

No painel de edição, a aba **Estilo** reúne todos os ajustes visuais do elemento selecionado, organizados em grupos que você abre e fecha: **Conteúdo**, **Tipografia**, **Espaçamento**, **Dimensões**, **Layout**, **Visual** e **Personalizado**.

## Como alterar um estilo

1. [Selecione o elemento](./selecionar-elementos) e abra o painel de edição pelo **lápis**.
2. Na aba **Estilo**, clique no nome do grupo que deseja abrir.

   ![Grupos de estilo e campos de tipografia](/img/editor-visual/estilos/01-grupos-e-tipografia.png)

   1. Os **grupos** de estilo: clique em um deles para abrir ou fechar.
   2. Campo de **cor**: clique no quadrado para escolher uma cor ou digite o valor.
   3. Campo **numérico**, com a unidade ao lado (`px`, `%`, `em`...).

3. Altere o valor desejado. A página mostra o resultado enquanto você digita, e o campo alterado ganha um ponto azul ao lado.

   ![Tamanho do texto alterado para 28](/img/editor-visual/estilos/02-tamanho-digitado.png)

   1. O novo valor do campo. Um número azul no grupo indica quantas propriedades dele foram alteradas.

4. Clique em **Aplicar ao DOM** para confirmar, como na [edição de texto](./editar-texto#trocar-o-texto-de-um-elemento). O elemento fica marcado como **Editado** e o botão **Salvar** é liberado.

   ![Elemento com o novo tamanho de texto aplicado](/img/editor-visual/estilos/02b-tamanho-aplicado.png)

   1. O elemento com a alteração.
   2. **Salvar**: grava a variante.

## Os grupos

### Tipografia

Cor, tamanho, peso, família, estilo (normal ou itálico), altura da linha, espaço entre letras, alinhamento, decoração (sublinhado, riscado) e transformação (maiúsculas, minúsculas).

### Espaçamento

Controla o espaço de fora (**margem**) e o de dentro (**padding**) do elemento, com um campo para cada lado, além do **gap** entre elementos filhos.

![Grupo Espaçamento](/img/editor-visual/estilos/03-espacamento.png)

1. **Margem**: espaço entre este elemento e os vizinhos (campos de cima, esquerda, direita e baixo).
2. **Padding**: espaço entre a borda do elemento e o conteúdo dele.
3. **Gap**: espaço entre os elementos filhos (geral, entre linhas e entre colunas).

### Dimensões

Largura e altura, com os limites mínimo e máximo de cada uma.

### Layout

Como o elemento se organiza na página: `display`, direção e quebra de linha (flex), alinhamentos, posição, overflow e z-index.

### Visual

Fundo, opacidade, cantos arredondados, borda e sombra.

![Grupo Visual](/img/editor-visual/estilos/04-visual.png)

1. **Fundo**: cor de fundo.
2. **Opacidade**: de 0 (invisível) a 1 (opaco).
3. **Arredondamento** dos cantos.
4. **Borda**: largura, estilo e cor.
5. **Sombra**.

### Personalizado

Para qualquer propriedade CSS que não esteja nos outros grupos, abra **Personalizado**, clique em **+ Adicionar estilo** e preencha o nome da **propriedade** (por exemplo, `text-shadow`) e o **valor**. Para remover, clique no **X** ao lado da linha.

## Desfazer

Use **Desfazer** (`Ctrl+Z`) na barra do editor para voltar uma alteração, ou **Descartar** no painel para abandonar o que ainda não foi aplicado.

## Resultado

Depois de [salvar](./salvar-e-desfazer) e [publicar](./publicar-no-painel), abra a variante pelo [link de prévia](./publicar-no-painel#conferir-o-resultado-pelo-link-de-prévia). Aqui, o tamanho do texto foi aumentado para 28 px.

**Controle (antes):**

![Controle com o tamanho de texto original](/img/editor-visual/estilos/resultado-antes.png)

**Variante (depois):**

![Variante com o texto maior](/img/editor-visual/estilos/resultado-depois.png)

1. O mesmo parágrafo, agora com o novo tamanho.

## Próximo passo

Veja como editar o [HTML do elemento](./editar-html).
