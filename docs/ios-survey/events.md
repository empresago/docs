---
sidebar_position: 4
---

# Eventos de Survey

O SDK expõe a telemetria da pesquisa através de um **closure listener** opcional.
Use-o para espelhar impressões, respostas e conclusões no seu próprio analytics
ou para reagir no app (ex.: dar um brinde depois que o usuário responde um NPS).

:::info Estado atual (v1.1.0)
`addOnSurveyEventListener` já faz parte da API pública e os tipos abaixo
(`SurveyAnalyticsEvent`, `SurveyEventType`) são estáveis. **Nesta versão o SDK
ainda não entrega eventos aos listeners registrados** — a telemetria da pesquisa
vai direto da WebView para a fila de envio ao backend GoAB. Registre o listener
já se quiser, mas não construa lógica de produto que dependa do callback disparar
antes da entrega ser habilitada.
:::

## Como funciona

1. A pesquisa é renderizada dentro de um `WKWebView` gerido pelo SDK.
2. Cada interação relevante (impressão, resposta, minimizar, enviar…) é emitida
   pela camada web via a bridge JavaScript `GoABSurvey`.
3. O SDK **persiste** cada evento numa fila local (SQLDelight) e faz *flush* em
   lote para `POST /:accountId/survey-app/event`. O intervalo do lote vem da
   configuração da conta.
4. Quando a entrega ao listener estiver habilitada, o mesmo evento — já
   enriquecido com `userId` e `sessionId` — será repassado de forma síncrona a
   todos os listeners registrados.

O envio ao backend **não depende** do listener: registrar (ou não) um listener
não altera a coleta de dados da GoAB.

## Registrar e remover

`addOnSurveyEventListener` recebe um closure `@escaping` e **retorna um handle**
(`OnSurveyEventListener`) que você guarda para remover depois.

```swift
import GoABSurveySDK

let handle = surveySdk.addOnSurveyEventListener { event in
    switch event.eventType {
    case .surveyImpression:
        Analytics.track("survey_shown", ["survey_id": event.surveyId ?? 0])
    case .surveySubmit:
        Analytics.track("survey_completed", ["survey_id": event.surveyId ?? 0])
    case .questionAnswer:
        Analytics.track("survey_question_answered", [
            "survey_id": event.surveyId ?? 0,
            "question_id": event.questionId ?? 0,
            "question_type": event.questionType ?? ""
        ])
    default:
        break
    }
}

// ao encerrar a tela / no logout:
surveySdk.removeOnSurveyEventListener(listener: handle)
```

- Vários listeners podem coexistir.
- Exceções/erros lançados dentro do closure são capturados pelo SDK — não
  derrubam a pesquisa nem os outros listeners.
- Não assuma a main thread dentro do closure; faça `DispatchQueue.main.async`
  se for tocar em UIKit.

## Assinatura

```swift
func addOnSurveyEventListener(
    listener: @escaping (SurveyAnalyticsEvent) -> Void
) -> OnSurveyEventListener

func removeOnSurveyEventListener(listener: OnSurveyEventListener)
```

O tipo `OnSurveyEventListener` é opaco — serve só como handle de remoção. O
parâmetro do closure é sempre um [`SurveyAnalyticsEvent`](#surveyanalyticsevent).

## `SurveyAnalyticsEvent`

Classe exportada pelo XCFramework (origem Kotlin `data class`). Representa **uma**
linha de telemetria. Nem todo campo é preenchido em todo evento — veja a tabela
de [tipos de evento](#tipos-de-evento). Todos os campos, exceto `eventType`, são
opcionais em Swift.

| Campo | Tipo Swift | Sempre presente? | Descrição |
|-------|-----------|:---:|-----------|
| `eventType` | `SurveyEventType` | Sim | O tipo do evento (enum, ver abaixo). |
| `surveyId` | `KotlinLong?` | Sim* | ID da pesquisa. Nulo apenas quando o SDK não conseguiu associar o evento a uma pesquisa ativa. |
| `userId` | `String?` | Enriquecido | ID do usuário definido via `setUserId`. Nulo se anônimo. |
| `sessionId` | `String?` | Enriquecido | ID da sessão analítica atual. Rotaciona no `initialize()` e a cada troca de `userId`. |
| `timestampIso` | `String?` | — | Instante do evento em ISO-8601 (UTC). Preferido sobre `timestampMillis` quando ambos existem. |
| `timestampMillis` | `KotlinLong?` | — | Instante do evento em epoch millis. |
| `questionId` | `KotlinLong?` | Só em eventos de pergunta | ID da pergunta relacionada. |
| `questionType` | `String?` | Só em eventos de pergunta | Tipo da pergunta no formato *wire* (ver [tipos de pergunta](#tipos-de-pergunta)). |
| `answer` | `Any?` | Só em eventos de resposta | Resposta do usuário. `String`, `NSNumber`, `Bool` ou `NSArray` (múltipla escolha). |
| `freeTextAnswer` | `String?` | Só em texto livre | Conteúdo digitado em campos de texto aberto. |

\* Ver a coluna correspondente na tabela de tipos.

`KotlinLong?` é o boxing padrão do Kotlin/Native para `Long` opcional — leia com
`event.surveyId?.int64Value` quando precisar de um `Int64` Swift.

### Enriquecimento

Antes de chegar ao listener (e à fila de envio), o SDK preenche `userId` e
`sessionId` a partir do estado atual, caso o evento de origem não os tenha
trazido. Os demais campos vêm da camada web como emitidos.

## Tipos de evento

`SurveyEventType` — enum exportado pelo XCFramework. Cada caso tem um `wireValue`
(o que trafega no campo `et` do payload enviado ao backend). Os nomes dos casos
em Swift seguem o *camelCase* do Kotlin.

| Caso Swift | `wireValue` | Quando ocorre | Campos típicos além de `eventType`/`surveyId` |
|-----------|-------------|---------------|-----------|
| `.surveyImpression` | `survey_impression` | A pesquisa foi exibida na tela. | `sessionId`, timestamp |
| `.surveyInteract` | `survey_interact` | Interação genérica com o container da pesquisa. | timestamp |
| `.surveyMinimize` | `survey_minimize` | Usuário minimizou a pesquisa para a barra. | timestamp |
| `.surveyMaximize` | `survey_maximize` | Usuário restaurou a pesquisa a partir da barra minimizada. | timestamp |
| `.surveyClose` | `survey_close` | Pesquisa fechada/dispensada sem envio. | timestamp |
| `.questionImpression` | `question_impression` | Uma pergunta ficou visível. | `questionId`, `questionType` |
| `.questionInteract` | `question_interact` | Usuário interagiu com um controle da pergunta (sem confirmar). | `questionId`, `questionType` |
| `.questionAnswer` | `question_answer` | Usuário respondeu uma pergunta específica. | `questionId`, `questionType`, `answer` e/ou `freeTextAnswer` |
| `.questionSkip` | `question_skip` | Pergunta pulada (quando permitido). | `questionId`, `questionType` |
| `.surveyAnswer` | `survey_answer` | Resposta consolidada da pesquisa. | `answer` |
| `.surveySubmit` | `survey_submit` | Usuário concluiu e enviou a pesquisa. | `sessionId`, timestamp |

Para converter um `wireValue` recebido de outra fonte:

```swift
let type = SurveyEventType.companion.fromWire(value: "survey_submit") // -> SurveyEventType? (nil se desconhecido)
```

## Tipos de pergunta

Valores possíveis de `questionType` (campo *wire* `qt`). Determinam como `answer`
é normalizado no envio:

| `questionType` | Significado | Forma de `answer` |
|----------------|-------------|-------------------|
| `radio` | Escolha única | `String` (uma opção) |
| `checkbox` | Múltipla escolha | `NSArray` de `String` (ou `String` com valores separados por vírgula) |
| `select` | Dropdown de escolha única | `String` |
| `nps` | Nota NPS (0–10) | `NSNumber` |
| `rating` / `scale` | Nota / escala | `NSNumber` |
| `text` | Texto livre | vai em `freeTextAnswer` |

Apenas `checkbox` preserva múltiplos valores no envio; os demais tipos colapsam
para o primeiro valor.

## Boas práticas

- **Idempotência no seu lado:** o mesmo evento lógico pode, em cenários de
  retry/reprocessamento, chegar mais de uma vez. Deduplique por
  `surveyId` + `eventType` + `questionId` + timestamp se precisar de contagem
  exata.
- **Não bloqueie o closure:** faça só um enfileiramento rápido; trabalho pesado
  vai para uma fila sua.
- **Guarde o handle** retornado e chame `removeOnSurveyEventListener` no fim do
  ciclo de vida (logout, `deinit`) para não vazar referências capturadas.

## Próximos passos

- [API Reference](./api-reference) — todos os métodos públicos
- [Inicialização](./initialization) — ciclo de vida e sessão
