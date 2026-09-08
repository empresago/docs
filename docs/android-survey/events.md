---
sidebar_position: 4
---

# Eventos de Survey

O SDK expõe a telemetria da pesquisa através de um **listener** opcional. Use-o
para espelhar impressões, respostas e conclusões no seu próprio analytics ou para
reagir no app (ex.: dar um brinde depois que o usuário responde um NPS).

:::info Estado atual (v1.1.0)
`addOnSurveyEventListener` já faz parte da API pública e os tipos abaixo
(`SurveyAnalyticsEvent`, `SurveyEventType`) são estáveis. **Nesta versão o SDK
ainda não entrega eventos aos listeners registrados** — a telemetria da pesquisa
vai direto da WebView para a fila de envio ao backend GoAB. Registre o listener
já se quiser, mas não construa lógica de produto que dependa do callback disparar
antes da entrega ser habilitada.
:::

## Como funciona

1. A pesquisa é renderizada dentro de uma `WebView` gerida pelo SDK.
2. Cada interação relevante (impressão, resposta, minimizar, enviar…) é emitida
   pela camada web via a bridge JavaScript `GoABSurvey`.
3. O SDK **persiste** cada evento numa fila local (SQLDelight) e faz *flush* em
   lote para `POST /:accountId/survey-app/event`. O intervalo do lote vem da
   configuração da conta.
4. Quando a entrega ao listener estiver habilitada, o mesmo evento — já
   enriquecido com `userId` e `sessionId` — será repassado de forma síncrona a
   todos os listeners registrados, na thread em que o SDK o processa.

O envio ao backend **não depende** do listener: registrar (ou não) um listener
não altera a coleta de dados da GoAB.

## Registrar e remover

```kotlin
import io.goab.survey.sdk.OnSurveyEventListener
import io.goab.survey.domain.event.SurveyEventType

val listener = OnSurveyEventListener { event ->
    when (event.eventType) {
        SurveyEventType.SURVEY_IMPRESSION ->
            analytics.track("survey_shown", mapOf("survey_id" to event.surveyId))
        SurveyEventType.SURVEY_SUBMIT ->
            analytics.track("survey_completed", mapOf("survey_id" to event.surveyId))
        SurveyEventType.QUESTION_ANSWER ->
            analytics.track("survey_question_answered", mapOf(
                "survey_id" to event.surveyId,
                "question_id" to event.questionId,
                "question_type" to event.questionType
            ))
        else -> Unit
    }
}

surveySdk.addOnSurveyEventListener(listener)

// ao destruir a Activity / no logout:
surveySdk.removeOnSurveyEventListener(listener)
```

- Vários listeners podem coexistir.
- O **mesmo** objeto listener não é registrado duas vezes (dedupe por
  identidade).
- Exceções lançadas dentro do callback são capturadas e logadas pelo SDK — não
  derrubam a pesquisa nem os outros listeners.
- Não há garantia de thread: trate o callback como potencialmente fora da main
  thread e faça o *hop* para a UI se precisar.

## `OnSurveyEventListener`

```kotlin
fun interface OnSurveyEventListener {
    fun onSurveyEvent(event: SurveyAnalyticsEvent)
}
```

É uma `fun interface`, então aceita lambda. O único parâmetro é sempre um
[`SurveyAnalyticsEvent`](#surveyanalyticsevent).

## `SurveyAnalyticsEvent`

`data class` no pacote `io.goab.survey.domain.event`. Representa **uma** linha de
telemetria. Nem todo campo é preenchido em todo evento — veja a tabela de
[tipos de evento](#tipos-de-evento).

| Campo | Tipo | Sempre presente? | Descrição |
|-------|------|:---:|-----------|
| `eventType` | `SurveyEventType` | Sim | O tipo do evento (enum, ver abaixo). |
| `surveyId` | `Long?` | Sim* | ID da pesquisa. Nulo apenas em eventos que o SDK não conseguiu associar a uma pesquisa ativa. |
| `userId` | `String?` | Enriquecido | ID do usuário definido via `setUserId`. Nulo se anônimo. |
| `sessionId` | `String?` | Enriquecido | ID da sessão analítica atual. Rotaciona no `initialize()` e a cada troca de `userId`. |
| `timestampIso` | `String?` | — | Instante do evento em ISO-8601 (UTC). Preferido sobre `timestampMillis` quando ambos existem. |
| `timestampMillis` | `Long?` | — | Instante do evento em epoch millis. |
| `questionId` | `Long?` | Só em eventos de pergunta | ID da pergunta relacionada. |
| `questionType` | `String?` | Só em eventos de pergunta | Tipo da pergunta no formato *wire* (ver [tipos de pergunta](#tipos-de-pergunta)). |
| `answer` | `Any?` | Só em eventos de resposta | Resposta do usuário. `String`, `Number`, `Boolean` ou `Collection<*>` (múltipla escolha). |
| `freeTextAnswer` | `String?` | Só em texto livre | Conteúdo digitado em campos de texto aberto. |

\* Ver a coluna correspondente na tabela de tipos.

### Enriquecimento

Antes de chegar ao listener (e à fila de envio), o SDK preenche `userId` e
`sessionId` a partir do estado atual, caso o evento de origem não os tenha
trazido. Os demais campos vêm da camada web como emitidos.

## Tipos de evento

`enum class SurveyEventType(val wireValue: String)` — pacote
`io.goab.survey.domain.event`. O `wireValue` é o que trafega no campo `et` do
payload enviado ao backend.

| Constante | `wireValue` | Quando ocorre | Campos típicos além de `eventType`/`surveyId` |
|-----------|-------------|---------------|-----------|
| `SURVEY_IMPRESSION` | `survey_impression` | A pesquisa foi exibida na tela. | `sessionId`, timestamp |
| `SURVEY_INTERACT` | `survey_interact` | Interação genérica com o container da pesquisa. | timestamp |
| `SURVEY_MINIMIZE` | `survey_minimize` | Usuário minimizou a pesquisa para a barra. | timestamp |
| `SURVEY_MAXIMIZE` | `survey_maximize` | Usuário restaurou a pesquisa a partir da barra minimizada. | timestamp |
| `SURVEY_CLOSE` | `survey_close` | Pesquisa fechada/dispensada sem envio. | timestamp |
| `QUESTION_IMPRESSION` | `question_impression` | Uma pergunta ficou visível. | `questionId`, `questionType` |
| `QUESTION_INTERACT` | `question_interact` | Usuário interagiu com um controle da pergunta (sem confirmar). | `questionId`, `questionType` |
| `QUESTION_ANSWER` | `question_answer` | Usuário respondeu uma pergunta específica. | `questionId`, `questionType`, `answer` e/ou `freeTextAnswer` |
| `QUESTION_SKIP` | `question_skip` | Pergunta pulada (quando permitido). | `questionId`, `questionType` |
| `SURVEY_ANSWER` | `survey_answer` | Resposta consolidada da pesquisa. | `answer` |
| `SURVEY_SUBMIT` | `survey_submit` | Usuário concluiu e enviou a pesquisa. | `sessionId`, timestamp |

Para tratar um `wireValue` recebido de outra fonte:

```kotlin
val type = SurveyEventType.fromWire("survey_submit") // -> SurveyEventType.SURVEY_SUBMIT? (nulo se desconhecido)
```

## Tipos de pergunta

Valores possíveis de `questionType` (campo *wire* `qt`). Determinam como `answer`
é normalizado no envio:

| `questionType` | Significado | Forma de `answer` |
|----------------|-------------|-------------------|
| `radio` | Escolha única | `String` (uma opção) |
| `checkbox` | Múltipla escolha | `Collection<String>` (ou `String` com valores separados por vírgula) |
| `select` | Dropdown de escolha única | `String` |
| `nps` | Nota NPS (0–10) | `Number` |
| `rating` / `scale` | Nota / escala | `Number` |
| `text` | Texto livre | vai em `freeTextAnswer` |

Apenas `checkbox` preserva múltiplos valores no envio; os demais tipos colapsam
para o primeiro valor.

## Boas práticas

- **Idempotência no seu lado:** o mesmo evento lógico pode, em cenários de
  retry/reprocessamento, chegar mais de uma vez. Deduplique por
  `surveyId` + `eventType` + `questionId` + timestamp se precisar de contagem
  exata.
- **Não bloqueie o callback:** faça só um enfileiramento rápido; trabalho pesado
  vai para uma coroutine sua.
- **Remova o listener** no fim do ciclo de vida (logout, `onDestroy`) para não
  vazar referência da Activity.

## Próximos passos

- [API Reference](./api-reference) — todos os métodos públicos
- [Inicialização](./initialization) — ciclo de vida e sessão
