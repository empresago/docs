---
sidebar_position: 3
---

# Como funciona

Com os pesos automáticos ligados, a GoAB repete um **ciclo** para cada teste ativo. Em cada ciclo ela decide se o tráfego deve mudar e, se for o caso, muda.

## O ciclo, passo a passo

1. **Lê os dados da métrica primária.** Visitantes e conversões de cada variante.
2. **Confere a amostra mínima.** Se alguma variante tem poucos visitantes, ou se há poucas conversões no total, o ciclo termina sem mudar nada. Veja [Regras e limites](./regras-e-limites).
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
| **Proporcional** | Ainda não há candidata confirmada | Cada variante recebe pelo menos 5%, e o restante é dividido na proporção da probabilidade de ser a melhor. Nenhuma variante passa de **60%** nesse regime. |
| **Degraus** | A candidata passou a ser confirmada | A candidata fica com o peso do degrau: **60%**, depois **80%** e, por fim, **100%**. As demais dividem o restante. |

## O que são os degraus

Os degraus são uma **escada de confiança**. A GoAB não manda mais tráfego para uma variante só porque ela está na frente hoje: primeiro a variante precisa provar, ciclo após ciclo, que está claramente melhor.

Cada degrau é um patamar de peso para a variante líder:

| Degrau | Peso da líder | Para chegar aqui |
|---|---|---|
| 1º | 60% | A líder confirma 3 ciclos seguidos com mais de 95% de chance de ser a melhor. |
| 2º | 80% | Mais 3 ciclos seguidos, ainda com mais de 95%. |
| 3º | 100% | Mais 3 ciclos seguidos, ainda com mais de 95%. |

Por que assim:

- **Protege contra sorte.** Uma variante pode estar na frente por acaso em um dia. Exigir confirmações repetidas evita que o tráfego migre por um resultado passageiro.
- **A decisão é reversível enquanto há dados.** Se a confiança cair, a líder desce um degrau, e o tráfego volta a ser dividido.
- **100% é o último passo.** Como as demais variantes deixam de receber visitantes, a GoAB só chega lá depois de muita evidência.

Os degraus são fixos para todos os testes: 60%, 80% e 100%. Antes de confirmar o primeiro, nenhuma variante passa de 60%.

## Subir e descer degraus

- A candidata sobe um degrau quando a probabilidade dela ser a melhor fica **igual ou acima de 95% por 3 ciclos seguidos**.
- Se a probabilidade cair **abaixo de 80%**, ela **desce um degrau**. No primeiro degrau, volta ao regime proporcional.
- Entre 80% e 95%, nada sobe nem desce, mas a contagem de ciclos seguidos recomeça do zero.
- Se outra variante passar a ser a mais provável acima de 95%, ela vira a nova candidata e começa de novo.

## Antes do primeiro degrau: o que pode acontecer

Antes de confirmar o primeiro degrau, o peso acompanha a evidência, com o teto de 60%. Por isso, em muitos testes, o peso fica **parado** por um tempo: isso é o esperado, e não uma falha. Estes são os pesos reais de cada situação, para a variante B partindo de 50%:

| Chance da B de ser a melhor | O que acontece | Peso da B nos ciclos seguintes |
|---|---|---|
| 55% (quase empate) | Os pesos ficam quase iguais. | 55% |
| 75% a 90% (B na frente, sem certeza) | A proporção sozinha daria 73% a 86%, mas o teto de 60% segura. | 60% |
| 97% (forte) | Fica em 60% enquanto confirma, e depois sobe a escada. | 60% nos ciclos 1 a 5, depois 75%, 80%, 95% e 100% |
| 97%, e depois cai para 70% | Sobe até o 2º degrau (80%), perde a confiança e volta a 60%. | 60%, 75%, 80%, 80%, 65%, 60% |
| 30% (o Controle é quem está na frente) | O mesmo vale para o Controle: ele vai a 60% e a B fica com 40%. | 40% |

![Peso da variante B conforme a evidência](/img/pesos-automaticos/cenarios.svg)

As duas linhas de evidência forte (azul e vermelha) coincidem até o ciclo 8. A linha vermelha se separa quando a confiança cai.

Para passar de 60%, a líder precisa de **6 ciclos seguidos** acima de 95%: 3 para confirmar o primeiro degrau e 3 para o segundo. Com o intervalo de 6 horas entre ajustes, isso leva cerca de um dia e meio.

## Exemplo

O caso forte, em detalhe: duas variantes, começando em 50% e 50%, e a variante B claramente melhor (97% de chance de ser a melhor em todos os ciclos). Estes são os pesos reais calculados ciclo a ciclo:

| Ciclo | Controle | Variante B | O que aconteceu |
|---|---|---|---|
| início | 50% | 50% | Pesos definidos por você. |
| 1 | 40% | 60% | A B é a candidata, mas ainda não confirmada: nenhuma variante passa de 60%. |
| 2 | 40% | 60% | B confirmada pela 2ª vez. |
| 3 | 40% | 60% | B confirmada pela 3ª vez e sobe ao **degrau de 60%**. |
| 4 a 5 | 40% | 60% | Confirmando para o próximo degrau. |
| 6 | 25% | 75% | Sobe ao degrau de **80%**. O passo máximo de 15 pontos limita a mudança. |
| 7 a 8 | 20% | 80% | Confirmando. |
| 9 | 5% | 95% | Sobe ao degrau de **100%**, limitado pelo passo máximo. |
| 10 | 0% | 100% | Vencedora em tempo integral. |

![Trajetória dos pesos ciclo a ciclo](/img/pesos-automaticos/trajetoria.svg)

As linhas tracejadas marcam o ciclo em que a líder **confirma** o degrau. O peso chega ao valor do degrau no mesmo ciclo ou no seguinte, porque nenhuma variante muda mais que 15 pontos por ciclo: por isso a B está em 75% no ciclo 6 (confirmação do degrau de 80%) e chega a 80% no ciclo 7.

Enquanto a evidência se mantém, o peso da líder só sobe: ela não passa de 60% antes de confirmar o primeiro degrau, e não passa de 80% antes de confirmar o segundo.

## O que os pesos automáticos não fazem

- **Não encerram o teste.** Mesmo com 100% para uma variante, o teste continua ativo até você pará-lo.
- **Não alteram os resultados exibidos.** A probabilidade e o ganho que você vê na tela de resultados seguem a mesma conta de sempre. A direção "maior é melhor" só afeta os pesos.
- **Não olham as métricas secundárias.**
