---
sidebar_position: 17
---

# Publicar no painel

Depois de [salvar a variante](./salvar-e-desfazer) no editor, volte ao painel da GoAB para publicar. É a publicação que faz o teste passar a exibir a variante para os visitantes.

## Passo a passo

1. Volte para a aba do painel e recarregue a página do teste. O teste A/B mostra o botão **Publicar** no topo da página.

   ![Botão Publicar na barra superior do teste](/img/editor-visual/publicar-no-painel/01-barra-publicar.png)

   1. **Publicar**: aparece quando há alterações salvas que ainda não foram publicadas.

   Em um teste que já está rodando, o painel também mostra um aviso de que alterar um teste em andamento pode afetar a qualidade dos dados coletados. Leia a recomendação antes de continuar.

2. Clique em **Publicar**. Uma janela pede a confirmação.

   ![Janela de confirmação Publicar Experimento](/img/editor-visual/publicar-no-painel/02-janela-publicar.png)

   1. **Publicar**: confirma. Use **Cancelar** para desistir.

3. O painel confirma com o aviso **Experimento publicado com sucesso**, e o botão **Publicar** desaparece.

   ![Aviso de experimento publicado com sucesso](/img/editor-visual/publicar-no-painel/03-publicado-bruto.png)

## Conferir o resultado pelo link de prévia

Antes de divulgar, veja a variante publicada exatamente como o visitante verá. Nas outras páginas desta documentação, a seção **Resultado** usa esse mesmo caminho.

1. Na etapa **Variantes** do teste, clique nas **três bolinhas (⋮)** da variante e em **Link de compartilhamento**. O link é copiado.
2. Cole o link no navegador. Abre a tela de **Prévia** do teste, com a lista de variantes.
3. Confira a **URL do teste** (a página do seu site onde a variante deve aparecer) e clique em **Abrir variante** na variante que quer ver. Use **Abrir variante** no Controle para comparar com a página original.

O site abre em uma nova janela, com a caixa **GoAB Prévia** no canto. Ela indica a variante em exibição e avisa **Variante aplicada (prévia)** quando as alterações estão ativas.

:::warning Só aparece o que foi publicado
A prévia mostra a variante **publicada**. Se a caixa disser «Variante aplicada (prévia): nenhuma modificação na página», as suas alterações foram salvas no editor, mas ainda não publicadas: [publique](#passo-a-passo) e abra a variante de novo.
:::

## Conferir no site

Depois de publicar, os visitantes sorteados para a variante passam a ver as suas alterações.

:::info Quanto tempo leva
A publicação pode levar alguns instantes para chegar ao site. Se não vir a alteração de imediato, recarregue a página.
:::
