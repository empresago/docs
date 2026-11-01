---
sidebar_position: 6
---

# Parâmetros e limites

Valores padrão aplicados aos pesos automáticos em produção.

## Quando a GoAB decide

| Parâmetro | Valor padrão | O que significa |
|---|---|---|
| Frequência de verificação | a cada 10 minutos | De quanto em quanto tempo a GoAB confere os testes com pesos automáticos ligados. |
| Intervalo entre ajustes | 6 horas | Depois de ajustar os pesos de um teste, a GoAB espera pelo menos esse tempo para ajustar de novo. |
| Mínimo de visitantes | 100 em **cada** variante | Enquanto alguma variante tiver menos visitantes, nada muda. |
| Mínimo de conversões | 10 somadas | Enquanto o total de conversões da métrica primária for menor, nada muda. |

## Como a GoAB decide

| Parâmetro | Valor padrão | O que significa |
|---|---|---|
| Simulações | 10.000 | Quantas vezes a simulação sorteia as taxas para estimar a probabilidade de ser a melhor. |
| Confiança para subir | 95% | Probabilidade mínima da candidata para contar um ciclo de confirmação. |
| Ciclos de confirmação | 3 seguidos | Quantos ciclos acima de 95% são necessários para subir um degrau. |
| Confiança para descer | abaixo de 80% | Abaixo disso, a candidata perde um degrau. |
| Degraus | 60%, 80% e 100% | Peso da vencedora em cada degrau. |

## Como o peso se move

| Parâmetro | Valor padrão | O que significa |
|---|---|---|
| Piso por variante | 5% | Peso mínimo de cada variante enquanto não há degrau (o controle também). |
| Passo máximo | 15 pontos percentuais | Quanto um peso pode mudar em um único ajuste. |

## Quanto tempo leva

Com os valores padrão, **um ajuste acontece no máximo a cada 6 horas**. Como a vencedora precisa de 3 confirmações para cada degrau, o caminho de 50% e 50% até 100% e 0% leva ao menos **10 ajustes**, ou seja, **no mínimo cerca de 2 dias e meio** mesmo quando os dados são favoráveis.

Isso é proposital: a mudança de tráfego é gradual, e há várias oportunidades para a evidência se desfazer antes de a variante chegar a 100%.

:::info Testes novos e pouco tráfego
Em um teste com pouco tráfego, o mínimo de visitantes e de conversões pode levar dias para ser atingido. Até lá os pesos ficam como você os definiu.
:::
