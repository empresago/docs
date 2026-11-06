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

```tsx
import type { SurveyAnalyticsEvent } from '@goab_ltda/survey-sdk-react-native';
import { SurveyEventType } from '@goab_ltda/survey-sdk-react-native';

const listener = (event: SurveyAnalyticsEvent) => {
  switch (event.eventType) {
    case SurveyEventType.SURVEY_IMPRESSION:
      analytics.track('survey_shown', { survey_id: event.surveyId });
      break;
    case SurveyEventType.SURVEY_SUBMIT:
      analytics.track('survey_completed', { survey_id: event.surveyId });
      break;
    case SurveyEventType.QUESTION_ANSWER:
      analytics.track('survey_question_answered', {
        survey_id: event.surveyId,
        question_id: event.questionId,
        question_type: event.questionType,
        answer: (event.answer as string[] | null)?.join('|'),
      });
      break;
    default:
      break;
  }
};

surveySdk.addOnSurveyEventListener(listener);

// ao desmontar / no logout:
surveySdk.removeOnSurveyEventListener(listener);
```

- Vários listeners podem coexistir.
- O **mesmo** objeto função não é registrado duas vezes (compare por referência — uma arrow function nova a cada render conta como um listener novo).
- Uma exceção lançada dentro do seu callback é capturada pelo SDK — não derruba a
  pesquisa nem os outros listeners.
- **Remova o listener** no fim do ciclo de vida (logout, `useEffect` cleanup) para não
  vazar referência de componente:

```tsx
useEffect(() => {
  const listener = (event: SurveyAnalyticsEvent) => {
    /* ... */
  };
  surveySdk.addOnSurveyEventListener(listener);
  return () => surveySdk.removeOnSurveyEventListener(listener);
}, []);
```

## `OnSurveyEventListener`

```ts
type OnSurveyEventListener = (event: SurveyAnalyticsEvent) => void;
```

Aceita qualquer função com essa assinatura. O único parâmetro é sempre um
[`SurveyAnalyticsEvent`](#surveyanalyticsevent).

## `SurveyAnalyticsEvent`

Um evento da pesquisa. Nem todo campo é preenchido em todo evento — veja a
coluna correspondente na [tabela de tipos](#tipos-de-evento).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `eventType` | `SurveyEventType` | O tipo do evento (ver abaixo). Sempre presente. |
| `surveyId` | `number \| null` | ID da pesquisa. Presente em todos os eventos normais. |
| `userId` | `string \| null` | ID do usuário definido via `setUserId`, ou `null` se anônimo. Preenchido pelo SDK. |
| `sessionId` | `string \| null` | ID da sessão atual. Muda no `initialize()` e a cada troca de `userId`. Preenchido pelo SDK. |
| `timestampIso` | `string \| null` | Instante do evento em ISO-8601 (UTC). É o campo de timestamp que de fato chega preenchido. |
| `timestampMillis` | `number \| null` | Existe por paridade de contrato com os SDKs nativos, mas na prática não é preenchido pelos eventos da WebView — use `timestampIso`. |
| `questionId` | `number \| null` | ID da pergunta. Presente só em eventos de pergunta. |
| `questionType` | `string \| null` | Tipo da pergunta (ver [tipos de pergunta](#tipos-de-pergunta)). Presente só em eventos de pergunta. |
| `answer` | `string[] \| null` | Resposta do usuário, sempre como lista de strings. Presente em `question_interact` / `question_answer` / `survey_answer`. Escala/NPS chega como string numérica (ex.: `["9"]`); múltipla escolha traz vários itens. |
| `freeTextAnswer` | `string \| null` | Texto digitado em campos de texto aberto, quando aplicável. |

Trabalhe sempre com os campos opcionais de forma defensiva (`?.`,
`switch (event.eventType)`), lendo apenas o que a tabela de tipos garante para
aquele evento.

## Tipos de evento

`SurveyEventType` — objeto exportado pelo pacote. Cada valor é uma string
estável, útil para logar ou encaminhar o tipo ao seu analytics.

| Constante | Valor (`wireValue`) | Quando ocorre | Campos preenchidos além de `eventType` / `surveyId` |
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

Valores possíveis de `questionType` (vêm da mesma WebView usada pelos SDKs Android/iOS):

| `questionType` | Significado | Conteúdo de `answer` |
|----------------|-------------|----------------------|
| `radio` | Escolha única | 1 item — o texto da opção |
| `select` | Dropdown de escolha única | 1 item |
| `checkbox` | Múltipla escolha | 1+ itens |
| `nps` | Nota NPS (0–10) | 1 item — a nota como string (`["10"]`) |
| `rating` / `scale` / `star` / `emoji` | Nota / escala | 1 item — a nota como string |
| `text` | Texto livre | o texto digitado (em `answer` e/ou `freeTextAnswer`) |

## Exemplo: acompanhar o funil da pesquisa

```tsx
import type { SurveyAnalyticsEvent } from '@goab_ltda/survey-sdk-react-native';
import { SurveyEventType } from '@goab_ltda/survey-sdk-react-native';

function criarFunnelTracker(analytics: Analytics) {
  return (event: SurveyAnalyticsEvent) => {
    const base = { survey_id: event.surveyId, session_id: event.sessionId };
    switch (event.eventType) {
      case SurveyEventType.SURVEY_IMPRESSION:
        analytics.track('survey_impression', base);
        break;

      case SurveyEventType.QUESTION_ANSWER:
        analytics.track('survey_question_answered', {
          ...base,
          question_id: event.questionId,
          question_type: event.questionType,
          answer: (event.answer as string[] | null)?.join('|'),
        });
        break;

      case SurveyEventType.SURVEY_SUBMIT:
        analytics.track('survey_completed', base);
        break;

      case SurveyEventType.SURVEY_CLOSE:
        analytics.track('survey_abandoned', base);
        break;

      default:
        break;
    }
  };
}

const funnelTracker = criarFunnelTracker(analytics);
surveySdk.addOnSurveyEventListener(funnelTracker);
```

## Próximos passos

- [API Reference](./api-reference) — todos os métodos públicos
- [Inicialização](./initialization) — ciclo de vida e sessão
