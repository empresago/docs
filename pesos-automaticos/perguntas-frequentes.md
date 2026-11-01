---
sidebar_position: 7
---

# Perguntas frequentes

## Ligar os pesos automáticos muda os pesos na hora?

Não. Os pesos continuam como estão até o teste atingir o [mínimo de visitantes e conversões](./parametros) e o primeiro ciclo de decisão acontecer.

## Posso ajustar os pesos manualmente com os pesos automáticos ligados?

Não. Com os pesos automáticos ligados, os controles de peso ficam bloqueados. Para definir pesos à mão, desligue os pesos automáticos. A opção **Distribuir igualmente** também é exclusiva dos pesos automáticos: não dá para usar as duas ao mesmo tempo.

## O controle também perde tráfego?

Sim. O controle é tratado como qualquer outra variante: se uma variante for claramente melhor, o controle recebe menos tráfego, podendo chegar a 0% no último degrau.

## Por que o peso de uma variante às vezes recua?

Dois motivos: a candidata perdeu confiança (probabilidade abaixo de 80%), ou ela acabou de confirmar o primeiro degrau, cujo alvo (60%) pode ser menor que o peso que ela já tinha no regime proporcional. Veja o [exemplo](./como-funciona#exemplo).

## O teste termina quando uma variante chega a 100%?

Não. O teste segue ativo até você pausá-lo ou arquivá-lo. Com 100%, a variante vencedora recebe todo o tráfego novo, e as demais deixam de coletar dados.

## Qual métrica decide os pesos?

Apenas a **métrica primária** do teste. As métricas secundárias aparecem nos resultados, mas não influenciam os pesos.

## Minha métrica é do tipo "quanto menor, melhor". E agora?

Desligue **Maior é melhor** na métrica primária. A conta de probabilidade passa a considerar vencedora a variante com o menor valor. Veja [A estatística](./a-estatistica#quando-menor-é-melhor).

## Funciona em testes mobile?

Os pesos automáticos funcionam em testes **A/B** e **Split** da web.

## Quantas variantes posso ter?

Duas ou mais, contando o controle.

## Por que nada acontece no meu teste?

As causas mais comuns:

- O teste ainda não atingiu o [mínimo de visitantes](./parametros) em cada variante, ou o mínimo de conversões somadas.
- Passaram menos de 6 horas desde o último ajuste.
- O teste não está ativo.
- O recurso de peso por variante não está habilitado na conta.
- A métrica primária não registra conversões.

## Isso substitui a leitura dos resultados?

Não. Os pesos automáticos reduzem o custo de manter uma variante pior no ar, mas a decisão final de qual variante adotar deve se apoiar na tela de resultados e nas métricas secundárias.
