---
sidebar_position: 4
---

# Eventos de Survey

O SDK notifica seu app a cada evento da pesquisa — impressão, resposta,
minimizar, envio, fecho — através de um **listener** opcional. Use-o para
espelhar o funil no seu próprio analytics ou para reagir no app (ex.: dar um
brinde depois que o usuário responde um NPS).

Registrar (ou não) um listener **não afeta** a coleta de dados da GoAB — o
listener é só uma cópia dos eventos para o seu app.

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
                "question_type" to event.questionType,
                "answer" to (event.answer as? List<String>)?.joinToString("|")
            ))
        else -> Unit
    }
}

surveySdk.addOnSurveyEventListener(listener)

// ao destruir a Activity / no logout:
surveySdk.removeOnSurveyEventListener(listener)
```

- Vários listeners podem coexistir.
- O **mesmo** objeto listener não é registrado duas vezes.
- Uma exceção lançada dentro do seu callback é capturada pelo SDK — não derruba a
  pesquisa nem os outros listeners.
- Não assuma a *main thread* dentro do callback; faça o *hop* para a UI se
  precisar tocar em views.
- Faça só trabalho leve no callback (ex.: enfileirar); mande processamento pesado
  para uma coroutine sua.
- **Remova o listener** no fim do ciclo de vida (logout, `onDestroy`) para não
  vazar referência da Activity.

## `OnSurveyEventListener`

```kotlin
fun interface OnSurveyEventListener {
    fun onSurveyEvent(event: SurveyAnalyticsEvent)
}
```

`fun interface` — aceita lambda. O único parâmetro é sempre um
[`SurveyAnalyticsEvent`](#surveyanalyticsevent).

## `SurveyAnalyticsEvent`

Um evento da pesquisa. Nem todo campo é preenchido em todo evento — veja a
coluna correspondente na [tabela de tipos](#tipos-de-evento).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `eventType` | `SurveyEventType` | O tipo do evento (enum, ver abaixo). Sempre presente. |
| `surveyId` | `Long?` | ID da pesquisa. Presente em todos os eventos normais. |
| `userId` | `String?` | ID do usuário definido via `setUserId`, ou `null` se anônimo. Preenchido pelo SDK. |
| `sessionId` | `String?` | ID da sessão atual. Muda no `initialize()` e a cada troca de `userId`. Preenchido pelo SDK. |
| `timestampIso` | `String?` | Instante do evento em ISO-8601 (UTC). |
| `timestampMillis` | `Long?` | Instante do evento em epoch millis. Alternativa a `timestampIso`. |
| `questionId` | `Long?` | ID da pergunta. Presente só em eventos de pergunta. |
| `questionType` | `String?` | Tipo da pergunta (ver [tipos de pergunta](#tipos-de-pergunta)). Presente só em eventos de pergunta. |
| `answer` | `Any?` | Resposta do usuário. Em tempo de execução é sempre `List<String>` — leia com `event.answer as? List<String>`. Presente em `question_interact` / `question_answer` / `survey_answer`. Escala/NPS chega como string numérica (ex.: `["9"]`); múltipla escolha traz vários itens. |
| `freeTextAnswer` | `String?` | Texto digitado em campos de texto aberto, quando aplicável. |

Trabalhe sempre com os campos opcionais de forma defensiva (`?.`,
`when (event.eventType)`), lendo apenas o que a tabela de tipos garante para
aquele evento.

## Tipos de evento

`enum class SurveyEventType` — pacote `io.goab.survey.domain.event`. Cada
constante tem um `wireValue` (string estável, útil para logar ou encaminhar o
tipo ao seu analytics).

| Constante | `wireValue` | Quando ocorre | Campos preenchidos além de `eventType` / `surveyId` |
|-----------|-------------|---------------|-----------|
| `SURVEY_IMPRESSION` | `survey_impression` | A pesquisa apareceu na tela. | `sessionId`, timestamp |
| `SURVEY_INTERACT` | `survey_interact` | Interação genérica com a pesquisa. | timestamp |
| `SURVEY_MINIMIZE` | `survey_minimize` | Usuário minimizou a pesquisa. | timestamp |
| `SURVEY_MAXIMIZE` | `survey_maximize` | Usuário restaurou a pesquisa minimizada. | timestamp |
| `SURVEY_CLOSE` | `survey_close` | Pesquisa fechada/dispensada sem envio. | timestamp |
| `QUESTION_IMPRESSION` | `question_impression` | Uma pergunta ficou visível. | `questionId`, `questionType` |
| `QUESTION_INTERACT` | `question_interact` | Usuário mexeu num controle da pergunta (ainda sem confirmar). | `questionId`, `questionType`, `answer` parcial |
| `QUESTION_ANSWER` | `question_answer` | Usuário respondeu uma pergunta. | `questionId`, `questionType`, `answer` e/ou `freeTextAnswer` |
| `QUESTION_SKIP` | `question_skip` | Pergunta pulada. | `questionId`, `questionType` |
| `SURVEY_ANSWER` | `survey_answer` | Resposta consolidada da pesquisa. | `answer` |
| `SURVEY_SUBMIT` | `survey_submit` | Usuário concluiu e enviou a pesquisa. | `sessionId`, timestamp |

## Tipos de pergunta

Valores possíveis de `questionType`:

| `questionType` | Significado | Conteúdo de `answer` |
|----------------|-------------|----------------------|
| `radio` | Escolha única | 1 item — o texto da opção |
| `select` | Dropdown de escolha única | 1 item |
| `checkbox` | Múltipla escolha | 1+ itens |
| `nps` | Nota NPS (0–10) | 1 item — a nota como string (`["10"]`) |
| `rating` / `scale` / `star` / `emoji` | Nota / escala | 1 item — a nota como string |
| `text` | Texto livre | o texto digitado (em `answer` e/ou `freeTextAnswer`) |

## Exemplo: acompanhar o funil da pesquisa

```kotlin
class SurveyFunnelTracker(private val analytics: Analytics) : OnSurveyEventListener {

    override fun onSurveyEvent(event: SurveyAnalyticsEvent) {
        val base = mapOf(
            "survey_id" to event.surveyId,
            "session_id" to event.sessionId,
        )
        when (event.eventType) {
            SurveyEventType.SURVEY_IMPRESSION ->
                analytics.track("survey_impression", base)

            SurveyEventType.QUESTION_ANSWER ->
                analytics.track("survey_question_answered", base + mapOf(
                    "question_id" to event.questionId,
                    "question_type" to event.questionType,
                    "answer" to (event.answer as? List<String>)?.joinToString("|"),
                ))

            SurveyEventType.SURVEY_SUBMIT ->
                analytics.track("survey_completed", base)

            SurveyEventType.SURVEY_CLOSE ->
                analytics.track("survey_abandoned", base)

            else -> Unit
        }
    }
}

// registro
surveySdk.addOnSurveyEventListener(funnelTracker)
```

## Próximos passos

- [API Reference](./api-reference) — todos os métodos públicos
- [Inicialização](./initialization) — ciclo de vida e sessão
