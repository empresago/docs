---
sidebar_position: 4
---

# A estatística

Esta página explica a conta por trás dos pesos automáticos, sem exigir conhecimento prévio de estatística. A ideia central é responder, a cada ciclo, uma pergunta: **qual é a chance de cada variante ser, de verdade, a melhor?**

## 1. O problema: a taxa que você vê é só uma amostra

Imagine duas variantes:

| Variante | Visitantes | Conversões | Taxa observada |
|---|---|---|---|
| Controle | 1.000 | 50 | 5,0% |
| B | 1.000 | 70 | 7,0% |

A B parece melhor. Mas essa taxa é calculada sobre uma **amostra** de visitantes. Com outros 1.000 visitantes, os números seriam um pouco diferentes. Quanto menos dados, maior a incerteza; quanto mais dados, menor.

Por isso a GoAB não compara só as duas taxas. Ela mede **quanta confiança** temos em cada uma.

## 2. A incerteza vira uma curva: a distribuição Beta

Para cada variante, a GoAB monta uma curva que descreve quais taxas de conversão reais são plausíveis, dado o que foi observado. Essa curva é uma **distribuição Beta**:

```text
Beta(1 + conversões, 1 + visitantes que não converteram)
```

O "1 +" parte de um palpite neutro: antes de ver qualquer dado, todas as taxas de conversão são igualmente plausíveis.

Propriedades que importam:

- O **centro** da curva fica perto da taxa observada.
- A curva **estreita** conforme chegam dados. Mais visitantes significam menos incerteza.
- Duas curvas que se **sobrepõem muito** indicam que ainda não dá para dizer qual variante é melhor.

No exemplo, as curvas são `Beta(51, 951)` para o controle e `Beta(71, 931)` para a B. Elas se sobrepõem pouco.

:::note A mesma base dos resultados
Essas são as mesmas curvas usadas na tela de resultados do teste. Os pesos automáticos reaproveitam a conta, mas usam só a **métrica primária**.
:::

## 3. Probabilidade de ser a melhor (Monte Carlo)

Com as curvas prontas, a GoAB faz uma simulação:

1. Sorteia **uma taxa de conversão para cada variante**, seguindo a curva dela.
2. Anota **qual variante teve a maior taxa** nesse sorteio.
3. Repete **10.000 vezes**.

A fração de sorteios que cada variante venceu é a **probabilidade de ser a melhor**.

Exemplos de resultado (aproximados, pois dependem do sorteio):

| Cenário | Probabilidade de ser a melhor |
|---|---|
| Controle 50/1.000 e B 70/1.000 | Controle 3%, B 97% |
| Controle 50/1.000 e B 55/1.000 | Controle 31%, B 69% |
| Controle 150/3.000 e B 210/3.000 (mesma taxa de 5% e 7%, com mais dados) | Controle ≈ 0%, B ≈ 100% |
| Controle 50/1.000, B 70/1.000 e C 52/1.000 | Controle 3%, B 93%, C 4% |

Repare em dois pontos:

- **Mesma taxa, mais dados, mais certeza.** O terceiro cenário tem as mesmas taxas do primeiro, mas com o triplo de visitantes.
- **Diferença pequena não é certeza.** No segundo cenário a B tem taxa maior, mas só 69% de chance de ser a melhor.

### Quando menor é melhor

Em algumas métricas, quanto **menor**, melhor (taxa de rejeição, tempo até concluir uma compra, custo). Para isso existe a opção **Maior é melhor** na métrica. Com ela desligada, a simulação considera vencedora a variante com o **menor** valor sorteado.

Essa direção vale **apenas para os pesos automáticos** por enquanto. Os resultados exibidos na tela do teste não mudam.

## 4. Das probabilidades aos pesos

Agora o ciclo precisa converter probabilidades em pesos de tráfego, em dois regimes.

### Regime proporcional (sem vencedora confirmada)

Cada variante recebe um **piso de 5%**. O restante, 100% menos os pisos, é dividido **na proporção da probabilidade** de cada uma:

```text
peso_alvo = 5% + (probabilidade da variante / soma das probabilidades) × (100% − nº de variantes × 5%)
```

Com Controle 3% e B 97%, em duas variantes:

```text
Controle = 5% + 0,03 × 90% = 7,7%
B        = 5% + 0,97 × 90% = 92,3%
```

O piso garante que nenhuma variante saia do jogo por causa de um começo ruim: ela continua recebendo dados e pode se recuperar.

### Regime de degraus (vencedora confirmada)

Quando a candidata fica acima de **95%** de probabilidade em **3 ciclos seguidos**, ela sobe um degrau. O peso dela passa a ser fixo no degrau:

| Degrau | Peso da vencedora |
|---|---|
| 1 | 60% |
| 2 | 80% |
| 3 | 100% |

O que sobra é dividido entre as demais, na proporção da probabilidade delas. No degrau de 100%, as outras variantes recebem 0%.

Se a probabilidade da candidata **cair abaixo de 80%**, ela desce um degrau. Isso protege contra uma vitória que foi, no fim, sorte.

Os limiares de 95% e 80% são diferentes de propósito: subir exige muita confiança, e descer só exige que a confiança se perca de forma clara. Entre os dois, nada muda.

## 5. Mudança suave

O peso-alvo nunca é aplicado de uma vez. Dois freios agem sobre ele:

- **Passo máximo.** Nenhuma variante muda mais que **15 pontos percentuais** por ciclo. Se o alvo estiver mais longe, o ciclo anda parte do caminho.
- **Arredondamento.** Os pesos viram números inteiros que somam exatamente 100, pelo método do maior resto.

## 6. Exemplo completo

Controle e B partem de 50%/50%, e a B tem 97% de probabilidade de ser a melhor em todos os ciclos:

| Ciclo | Candidata | Ciclos confirmados | Degrau | Controle | B |
|---|---|---|---|---|---|
| 1 | B | 1 | nenhum | 35% | 65% |
| 2 | B | 2 | nenhum | 20% | 80% |
| 3 | B | 3, sobe | 60% | 35% | 65% |
| 4 | B | 1 | 60% | 40% | 60% |
| 5 | B | 2 | 60% | 40% | 60% |
| 6 | B | 3, sobe | 80% | 25% | 75% |
| 7 a 8 | B | 1 e 2 | 80% | 20% | 80% |
| 9 | B | 3, sobe | 100% | 5% | 95% |
| 10 | B | 1 | 100% | 0% | 100% |

Cada linha é uma decisão do ciclo: o alvo vem do regime, e o passo máximo de 15 pontos limita o quanto se anda.

## 7. Cuidados ao interpretar

- **É um método adaptativo, não um teste de hipótese.** Ele existe para **reduzir o custo** de mostrar uma variante pior, e não para declarar um vencedor com um nível de significância definido. Para a decisão final, use a tela de resultados.
- **Só a métrica primária decide.** Uma variante pode ganhar na primária e perder em outra métrica. Os pesos automáticos não enxergam isso.
- **A amostra mínima vale.** Antes de [atingir o mínimo](./parametros), a GoAB não mexe nos pesos. Com poucos dados, a probabilidade oscila muito.
- **A qualidade da métrica importa.** Se a conversão da métrica primária estiver mal configurada, os pesos seguem o erro.
