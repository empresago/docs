---
sidebar_position: 5
---

# Acompanhando

Com os pesos automáticos ligados, você acompanha a mudança no mesmo card **Peso das variantes**, no passo **Audiência**. Recarregue a página para ver os pesos atuais.

## Antes dos primeiros ajustes

Logo depois de ligar, os pesos são os que você tinha definido.

![Pesos automáticos ligados, antes do tráfego](/img/pesos-automaticos/acompanhando/01-antes-do-trafego.png)

1. **Pesos automáticos ligados e salvos.**
2. **Ponto de partida.** Neste teste de exemplo os pesos eram praticamente iguais (34%, 33% e 33%), e a pré-visualização mostra essa divisão.

## Depois dos ajustes

Conforme chegam visitantes e conversões, a GoAB move o tráfego. No exemplo, uma variante convertia muito mais que as outras e acabou com todo o tráfego.

![Pesos depois de a variante líder chegar a 100%](/img/pesos-automaticos/acompanhando/02-depois-do-cem.png)

1. **A variante líder recebe 100% do tráfego.** A pré-visualização mostra só ela.
2. **O controle foi a 0%.** O controle também pode perder todo o tráfego.
3. **Aviso do painel.** Com o controle em 0%, o teste não tem base de comparação nos resultados.

:::note Os prints vêm da homologação
Neste exemplo a homologação usa ciclos de ajuste de poucos minutos, para o teste caber em alguns minutos. Em produção os ajustes acontecem no máximo a cada 6 horas e a subida até 100% leva ao menos cerca de 2 dias e meio. Veja [Regras e limites](./regras-e-limites).
:::

## O que olhar

- **Os pesos nos sliders.** Estão travados: servem só para leitura enquanto os pesos automáticos estão ligados.
- **O aviso do controle.** Se o controle chegar a 0%, as comparações com o controle deixam de ter base nos resultados. Para voltar a comparar, desligue os pesos automáticos e defina os pesos à mão.
- **Os resultados do teste.** Os pesos automáticos reduzem o custo de manter uma variante pior no ar, mas a decisão final se apoia na tela de resultados. Veja [A estatística](./a-estatistica).

Se nada estiver mudando, veja as causas comuns em [Perguntas frequentes](./perguntas-frequentes#por-que-nada-acontece-no-meu-teste).
