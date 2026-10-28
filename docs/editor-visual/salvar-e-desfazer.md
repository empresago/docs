---
sidebar_position: 16
---

# Salvar e desfazer

Suas alterações só passam a valer na variante quando você **salva**. Até lá, elas aparecem só no editor, e você pode desfazer e refazer à vontade.

## Desfazer e refazer

1. Faça uma alteração (por exemplo, [troque um texto](./editar-texto)).
2. Na barra do editor, clique em **Desfazer** (ou use `Ctrl+Z`) para voltar a última alteração.

   ![Texto original de volta depois de desfazer](/img/editor-visual/salvar-e-desfazer/02-desfeito.png)

   1. O elemento com o conteúdo de antes da alteração.
   2. **Refazer** (`Ctrl+Shift+Z`): aplica de novo a alteração desfeita.

Você pode desfazer várias alterações em sequência. O número ao lado de **Ver código** mostra quantos elementos estão alterados.

## Salvar

Com pelo menos uma alteração, o botão **Salvar** fica ativo.

![Botões Auto e Salvar na barra](/img/editor-visual/salvar-e-desfazer/01-barra-salvar.png)

1. **Auto**: liga e desliga o salvamento automático (veja abaixo).
2. **Salvar**: grava as alterações na variante.

Clique em **Salvar**. O editor confirma com o aviso **Variante salva**.

![Aviso Variante salva](/img/editor-visual/salvar-e-desfazer/03-variante-salva.png)

1. O aviso de que a variante foi salva.

Sem alterações pendentes, o botão **Salvar** fica desabilitado (cinza).

### Salvamento automático

Com o **Auto** ligado, o editor salva a variante sozinho depois de cada alteração, sem você precisar clicar em **Salvar**. Com ele desligado, você decide quando salvar. Clique em **Auto** para alternar.

## Depois de salvar

A variante salva já está pronta para o experimento, mas o teste só passa a mostrá-la aos visitantes depois que você [publica no painel](./publicar-no-painel).

:::tip Reabrir depois
Ao reabrir o editor em uma variante com alterações salvas, o editor restaura seu trabalho e você continua de onde parou.
:::
