---
sidebar_position: 2
---

# Como ligar

Você liga os pesos automáticos no passo **Audiência** do teste e confere a direção da métrica no passo **Métricas**. Funciona em testes A/B e Split da web.

## Antes de começar

- O recurso de **peso por variante** precisa estar habilitado na sua conta.
- O teste precisa ter **duas ou mais variantes já salvas**. O card de pesos só aparece com elas.
- Defina uma **métrica primária**: é a única que decide os pesos.

## 1. Abra o card Peso das variantes

No passo **Audiência**, role até o card **Peso das variantes**.

![Card Peso das variantes no passo Audiência](/img/pesos-automaticos/como-ligar/01-card-de-pesos.png)

1. **Distribuir igualmente**: divide o tráfego em partes iguais, sem ajuste automático.
2. **Ajustar pesos automaticamente**: a opção deste guia, no fim da linha.
3. **Pesos manuais**: arraste os sliders ou digite os valores. Eles somam sempre 100%.

## 2. Ligue «Ajustar pesos automaticamente» e salve

Ligue a opção e clique em **Salvar**, na barra do topo.

![Pesos automáticos ligados, com sliders travados](/img/pesos-automaticos/como-ligar/02-automatico-ligado.png)

1. **Pesos automáticos ligados.** As opções **Distribuir igualmente** e **Ajustar pesos automaticamente** não funcionam juntas: ligar uma desliga a outra.
2. **Sliders e campos travados.** A partir daqui quem ajusta os pesos é a GoAB.
3. **Os pesos ficam como estavam** até o teste atingir o [mínimo de visitantes e conversões](./regras-e-limites) e o primeiro ajuste acontecer.

## 3. Confira «Maior é melhor» na métrica

No passo **Métricas**, ao lado do **Tipo da Métrica**, fica a opção **Maior é melhor**. Ela vem **marcada por padrão**.

![Opção Maior é melhor ao lado do tipo da métrica](/img/pesos-automaticos/como-ligar/03-maior-e-melhor.png)

1. **Seletor do tipo da métrica.**
2. **Maior é melhor**, marcada: quanto maior o valor da métrica, melhor. Desmarque para métricas em que menor é melhor, como rejeição.
3. **Ícone de ajuda**: passe o mouse para ler a explicação.

:::info A direção vale só para os pesos
Por enquanto, a direção escolhida em **Maior é melhor** é usada pelos pesos automáticos. Os resultados exibidos na tela do teste seguem a mesma conta de sempre.
:::

## Para desligar

Desligue **Ajustar pesos automaticamente** e salve. Os sliders e campos voltam a ficar editáveis, e você pode definir os pesos à mão.

Para entender o que acontece depois que os pesos automáticos estão ligados, veja [Acompanhando](./acompanhando).
