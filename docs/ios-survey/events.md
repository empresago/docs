---
sidebar_position: 4
---

# Eventos de Survey

O SDK notifica seu app a cada evento da pesquisa — impressão, resposta,
minimizar, envio, fecho — através de um **closure listener** opcional. Use-o para
espelhar o funil no seu próprio analytics ou para reagir no app (ex.: dar um
brinde depois que o usuário responde um NPS).

Registrar (ou não) um listener **não afeta** a coleta de dados da GoAB — o
listener é só uma cópia dos eventos para o seu app.

## Registrar e remover

`addOnSurveyEventListener` recebe um closure `@escaping` e **retorna um handle**
que você guarda para remover depois.

```swift
import GoABSurveySDK

let handle = surveySdk.addOnSurveyEventListener { event in
    switch event.eventType {
    case .surveyImpression:
        Analytics.track("survey_shown", ["survey_id": event.surveyId ?? 0])
    case .questionAnswer:
        Analytics.track("survey_question_answered", [
            "survey_id": event.surveyId ?? 0,
            "question_id": event.questionId ?? 0,
            "question_type": event.questionType ?? "",
            "answer": (event.answer as? [String])?.joined(separator: "|") ?? "",
        ])
    case .surveySubmit:
        Analytics.track("survey_completed", ["survey_id": event.surveyId ?? 0])
    default:
        break
    }
}

// ao encerrar a tela / no logout:
surveySdk.removeOnSurveyEventListener(listener: handle)
```

- Vários listeners podem coexistir.
- Um erro lançado dentro do closure é capturado pelo SDK — não derruba a pesquisa
  nem os outros listeners.
- Não assuma a main thread dentro do closure; use `DispatchQueue.main.async` se
  for tocar em UIKit.
- Faça só trabalho leve no closure; mande processamento pesado para uma fila sua.
- **Guarde o handle** e chame `removeOnSurveyEventListener` no fim do ciclo de
  vida (logout, `deinit`) para não vazar referências capturadas.

## Assinatura

```swift
func addOnSurveyEventListener(
    listener: @escaping (SurveyAnalyticsEvent) -> Void
) -> OnSurveyEventListener

func removeOnSurveyEventListener(listener: OnSurveyEventListener)
```

`OnSurveyEventListener` é um tipo opaco — serve só como handle de remoção. O
parâmetro do closure é sempre um [`SurveyAnalyticsEvent`](#surveyanalyticsevent).

## `SurveyAnalyticsEvent`

Um evento da pesquisa. Nem todo campo é preenchido em todo evento — veja a
coluna correspondente na [tabela de tipos](#tipos-de-evento). Todos os campos,
exceto `eventType`, são opcionais.

| Campo | Tipo Swift | Descrição |
|-------|-----------|-----------|
| `eventType` | `SurveyEventType` | O tipo do evento (enum, ver abaixo). Sempre presente. |
| `surveyId` | `KotlinLong?` | ID da pesquisa. Presente em todos os eventos normais. |
| `userId` | `String?` | ID do usuário definido via `setUserId`, ou `nil` se anônimo. Preenchido pelo SDK. |
| `sessionId` | `String?` | ID da sessão atual. Muda no `initialize()` e a cada troca de `userId`. Preenchido pelo SDK. |
| `timestampIso` | `String?` | Instante do evento em ISO-8601 (UTC). |
| `timestampMillis` | `KotlinLong?` | Instante do evento em epoch millis. Alternativa a `timestampIso`. |
| `questionId` | `KotlinLong?` | ID da pergunta. Presente só em eventos de pergunta. |
| `questionType` | `String?` | Tipo da pergunta (ver [tipos de pergunta](#tipos-de-pergunta)). Presente só em eventos de pergunta. |
| `answer` | `Any?` | Resposta do usuário. Em tempo de execução é sempre um array de strings — leia com `event.answer as? [String]`. Escala/NPS chega como string numérica (ex.: `["9"]`); múltipla escolha traz vários itens. |
| `freeTextAnswer` | `String?` | Texto digitado em campos de texto aberto, quando aplicável. |

`KotlinLong?` é o boxing do Kotlin/Native para inteiro opcional — leia com
`event.surveyId?.int64Value` quando precisar de um `Int64`.

Trabalhe sempre com os campos opcionais de forma defensiva (`??`,
`if let`, `switch event.eventType`), lendo apenas o que a tabela de tipos
garante para aquele evento.

## Tipos de evento

`SurveyEventType` — enum exportado pelo SDK. Os nomes dos casos em Swift seguem
*camelCase*. Cada caso tem um `wireValue` (string estável, útil para logar ou
encaminhar o tipo ao seu analytics).

| Caso Swift | `wireValue` | Quando ocorre | Campos preenchidos além de `eventType` / `surveyId` |
|-----------|-------------|---------------|-----------|
| `.surveyImpression` | `survey_impression` | A pesquisa apareceu na tela. | `sessionId`, timestamp |
| `.surveyInteract` | `survey_interact` | Interação genérica com a pesquisa. | timestamp |
| `.surveyMinimize` | `survey_minimize` | Usuário minimizou a pesquisa. | timestamp |
| `.surveyMaximize` | `survey_maximize` | Usuário restaurou a pesquisa minimizada. | timestamp |
| `.surveyClose` | `survey_close` | Pesquisa fechada/dispensada sem envio. | timestamp |
| `.questionImpression` | `question_impression` | Uma pergunta ficou visível. | `questionId`, `questionType` |
| `.questionInteract` | `question_interact` | Usuário mexeu num controle da pergunta (ainda sem confirmar). | `questionId`, `questionType`, `answer` parcial |
| `.questionAnswer` | `question_answer` | Usuário respondeu uma pergunta. | `questionId`, `questionType`, `answer` e/ou `freeTextAnswer` |
| `.questionSkip` | `question_skip` | Pergunta pulada. | `questionId`, `questionType` |
| `.surveyAnswer` | `survey_answer` | Resposta consolidada da pesquisa. | `answer` |
| `.surveySubmit` | `survey_submit` | Usuário concluiu e enviou a pesquisa. | `sessionId`, timestamp |

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

```swift
final class SurveyFunnelTracker {

    private var handle: OnSurveyEventListener?

    func attach(to surveySdk: SurveySdk) {
        handle = surveySdk.addOnSurveyEventListener { [weak self] event in
            self?.handle(event)
        }
    }

    func detach(from surveySdk: SurveySdk) {
        if let handle { surveySdk.removeOnSurveyEventListener(listener: handle) }
        handle = nil
    }

    private func handle(_ event: SurveyAnalyticsEvent) {
        let base: [String: Any] = [
            "survey_id": event.surveyId ?? 0,
            "session_id": event.sessionId ?? "",
        ]
        switch event.eventType {
        case .surveyImpression:
            Analytics.track("survey_impression", base)
        case .questionAnswer:
            Analytics.track("survey_question_answered", base.merging([
                "question_id": event.questionId ?? 0,
                "question_type": event.questionType ?? "",
                "answer": (event.answer as? [String])?.joined(separator: "|") ?? "",
            ]) { _, new in new })
        case .surveySubmit:
            Analytics.track("survey_completed", base)
        case .surveyClose:
            Analytics.track("survey_abandoned", base)
        default:
            break
        }
    }
}
```

## Próximos passos

- [API Reference](./api-reference) — todos os métodos públicos
- [Inicialização](./initialization) — ciclo de vida e sessão
