---
sidebar_position: 11
---

# Ver código

Tudo o que você altera no editor é traduzido em código, que é o que vai rodar no site dos visitantes. A gaveta **Ver código** mostra esse código, para você conferir o que será aplicado ou copiá-lo.

## Abrir a gaveta

1. Faça pelo menos uma alteração (por exemplo, [troque um texto](./editar-texto)).
2. Na barra do editor, clique em **Ver código**. O número ao lado do botão mostra quantas alterações já foram feitas.

   ![Gaveta Ver código com o código gerado](/img/editor-visual/ver-codigo/01-ver-codigo.png)

   1. **Ver código**: abre e fecha a gaveta.
   2. **Abas** de código: `editor-visual.js` traz o código gerado automaticamente pelas suas alterações (somente leitura); `estilos.css` e `script.js` permitem consultar o CSS e o JavaScript da variante.
   3. O **código** da aba selecionada, com aviso de erros de sintaxe na parte de baixo.

## Para que serve

- **Conferir** exatamente o que o editor vai aplicar antes de salvar.
- **Copiar** o código para compartilhar com quem cuida do site.

:::info Código gerado
O conteúdo da aba `editor-visual.js` é gerado pelo editor a partir das suas alterações. Para mudar o resultado, altere o elemento no editor, e o código é atualizado em seguida.
:::
