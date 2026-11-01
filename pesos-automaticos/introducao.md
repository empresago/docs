---
slug: /
sidebar_position: 1
---

# Pesos automáticos

Em um teste A/B ou Split, cada variante recebe uma fatia do tráfego, o **peso**. Normalmente você define os pesos à mão e eles ficam fixos até o fim do teste, mesmo quando uma variante está claramente ganhando.

Com os **pesos automáticos**, a GoAB reavalia os resultados de tempos em tempos e **move o tráfego sozinha para a variante que está convertendo melhor**. Você perde menos conversões enquanto o teste roda, sem precisar ficar de olho nos números.

## O que você ganha

- **Menos tráfego em variantes ruins.** Uma variante com desempenho claramente pior passa a receber menos visitantes.
- **Decisão guiada por estatística.** O ajuste usa a probabilidade de cada variante ser a melhor, e não só a taxa de conversão bruta. Veja [A estatística](./a-estatistica).
- **Mudança gradual e com freio.** O peso anda em passos limitados e só chega a 100% depois de confirmações repetidas.
- **Nenhuma variante é eliminada por acidente.** Enquanto não há um vencedor confirmado, toda variante mantém pelo menos 5% do tráfego.

## Como as peças se encaixam

| Peça | Papel |
|---|---|
| **Métrica primária** | É a única métrica usada para decidir os pesos. As secundárias não entram na conta. |
| **Maior é melhor** | Diz se, na métrica primária, um valor maior é melhor (por exemplo, compras) ou menor é melhor (por exemplo, tempo até a compra). |
| **Pesos automáticos** | Liga o ajuste automático no passo **Audiência** do teste. |
| **Ciclo de ajuste** | A cada rodada, a GoAB recalcula as probabilidades e, se houver motivo, move o tráfego. |

## Onde funciona

Os pesos automáticos funcionam em testes **A/B** e **Split** da web, com duas ou mais variantes, incluindo o **controle**: o controle também pode perder (ou ganhar) tráfego.

## O que você precisa ter

1. O recurso de **peso por variante** habilitado na sua conta.
2. Um teste A/B ou Split com uma **métrica primária** definida.
3. Visitantes e conversões suficientes. Antes de atingir o [mínimo de amostra](./regras-e-limites), nada muda.

:::info Pesos manuais e automáticos não se misturam
Com os pesos automáticos ligados, os controles de peso manual ficam bloqueados. Para voltar a definir os pesos à mão, desligue os pesos automáticos.
:::

## Onde ligar

No painel, ao criar ou editar o teste:

- No passo **Audiência**, ligue **Pesos automáticos**, ao lado da opção **Distribuir igualmente**. As duas opções são exclusivas.
- Na **métrica primária**, confira **Maior é melhor**: ela diz em que direção a métrica melhora.

## Próximos passos

- [Como funciona](./como-funciona): o que acontece em cada ciclo.
- [A estatística](./a-estatistica): como a probabilidade de ser a melhor é calculada, com um exemplo numérico completo.
