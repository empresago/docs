---
sidebar_position: 3
---

# Como funciona

Com os pesos automáticos ligados, a GoAB repete um **ciclo** para cada teste ativo. Em cada ciclo ela decide se o tráfego deve mudar e, se for o caso, muda.

## O ciclo, passo a passo

1. **Lê os dados da métrica primária.** Visitantes e conversões de cada variante.
2. **Confere a amostra mínima.** Se alguma variante tem poucos visitantes, ou se há poucas conversões no total, o ciclo termina sem mudar nada. Veja [Parâmetros](./parametros).
3. **Respeita o intervalo entre ajustes.** Se o último ajuste foi recente, o ciclo espera.
4. **Calcula a probabilidade de cada variante ser a melhor.** Veja [A estatística](./a-estatistica).
5. **Atualiza a candidata a vencedora.** A variante com maior probabilidade é a candidata. Cada vez que ela se mantém acima de 95% em ciclos seguidos, ela sobe um **degrau**.
6. **Define os pesos-alvo.** Para onde o tráfego quer ir.
7. **Limita o passo.** Nenhuma variante muda mais que 15 pontos percentuais por ciclo.
8. **Arredonda para números inteiros que somam 100.**
9. **Grava os novos pesos** no teste e registra o ajuste.

## Os dois regimes

| Regime | Quando | O que acontece com os pesos |
|---|---|---|
| **Proporcional** | Ainda não há candidata confirmada | Cada variante recebe pelo menos 5%, e o restante é dividido na proporção da probabilidade de ser a melhor. |
| **Degraus** | A candidata passou a ser confirmada | A candidata fica com o peso do degrau: **60%**, depois **80%** e, por fim, **100%**. As demais dividem o restante. |

## Subir e descer degraus

- A candidata sobe um degrau quando a probabilidade dela ser a melhor fica **igual ou acima de 95% por 3 ciclos seguidos**.
- Se a probabilidade cair **abaixo de 80%**, ela **desce um degrau**. No primeiro degrau, volta ao regime proporcional.
- Entre 80% e 95%, nada sobe nem desce, mas a contagem de ciclos seguidos recomeça do zero.
- Se outra variante passar a ser a mais provável acima de 95%, ela vira a nova candidata e começa de novo.

## Exemplo

Teste com duas variantes, começando em 50% e 50%. A variante B é claramente melhor (probabilidade de ser a melhor de 97%). Estes são os pesos reais calculados ciclo a ciclo:

| Ciclo | Controle | Variante B | O que aconteceu |
|---|---|---|---|
| início | 50% | 50% | Pesos definidos por você. |
| 1 | 35% | 65% | Regime proporcional. O passo máximo de 15 pontos limita a mudança. |
| 2 | 20% | 80% | B confirmada pela 2ª vez. |
| 3 | 35% | 65% | B confirmada pela 3ª vez e sobe ao **degrau de 60%**. O alvo passa a ser 60%, e o peso recua de 80% para 65%. |
| 4 a 5 | 40% | 60% | Confirmando para o próximo degrau. |
| 6 | 25% | 75% | Sobe ao degrau de **80%**. |
| 7 a 8 | 20% | 80% | Confirmando. |
| 9 | 5% | 95% | Sobe ao degrau de **100%**, limitado pelo passo máximo. |
| 10 | 0% | 100% | Vencedora em tempo integral. |

![Trajetória dos pesos ciclo a ciclo](/img/pesos-automaticos/trajetoria.svg)

:::note Nota
O peso da B recua no ciclo 3. Isso acontece porque, ao confirmar a candidata, o alvo deixa de ser a proporção de probabilidade (92%, neste caso) e passa a ser o do primeiro degrau (60%).
:::

## O que os pesos automáticos não fazem

- **Não encerram o teste.** Mesmo com 100% para uma variante, o teste continua ativo até você pará-lo.
- **Não alteram os resultados exibidos.** A probabilidade e o ganho que você vê na tela de resultados seguem a mesma conta de sempre. A direção "maior é melhor" só afeta os pesos.
- **Não olham as métricas secundárias.**
