---
sidebar_position: 6
---

# Regras e limites

Estas são as regras fixas dos pesos automáticos. Elas valem para todos os testes e **não podem ser alteradas por teste nem por conta**.

## Quando a GoAB ajusta os pesos

| Regra | Valor | O que significa |
|---|---|---|
| Mínimo de visitantes | 100 em **cada** variante | Enquanto alguma variante tiver menos visitantes, nada muda. |
| Mínimo de conversões | 10 somadas | Enquanto o total de conversões da métrica primária for menor, nada muda. |
| Intervalo entre ajustes | 6 horas | Depois de ajustar os pesos de um teste, a GoAB espera pelo menos esse tempo para ajustar de novo. |

## Como a GoAB decide

| Regra | Valor | O que significa |
|---|---|---|
| Confiança para subir | 95% | Probabilidade mínima da variante líder de ser a melhor para contar um ciclo de confirmação. |
| Confirmações | 3 ciclos seguidos | Quantos ciclos acima de 95% são necessários para subir um degrau. |
| Confiança para descer | abaixo de 80% | Abaixo disso, a líder perde um degrau. |

## Os degraus

O peso da variante líder, depois de confirmada, é fixo em cada degrau:

| Degrau | Peso da líder |
|---|---|
| 1º | 60% |
| 2º | 80% |
| 3º | 100% |

As demais variantes dividem o restante.

## Como o peso se move

| Regra | Valor | O que significa |
|---|---|---|
| Piso por variante | 5% | Peso mínimo de cada variante enquanto não há degrau (o controle também). |
| Passo máximo | 15 pontos percentuais | Quanto um peso pode mudar em um único ajuste. |

## Quanto tempo leva

Um ajuste acontece no máximo a cada 6 horas. Como a líder precisa de 3 confirmações para cada degrau, o caminho de 50% e 50% até 100% e 0% leva ao menos **10 ajustes**, ou seja, **no mínimo cerca de 2 dias e meio**, mesmo quando os dados são favoráveis.

:::info Testes novos e pouco tráfego
Em um teste com pouco tráfego, o mínimo de visitantes e de conversões pode levar dias para ser atingido. Até lá os pesos ficam como você os definiu.
:::
