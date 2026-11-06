---
sidebar_position: 5
---

# API Reference

Documentação da **API pública** do GoAB Survey SDK React Native.

---

## SurveySdkFactory

Factory para criar instâncias do SDK.

### `create`

```ts
import type { SurveyStorage } from '@goab_ltda/survey-sdk-react-native';

function create(options: {
  accountId: number;
  apiToken: string;
  timeoutMillis?: number;
  storage?: SurveyStorage;
}): SurveySdk;
```

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `accountId` | number | ID da conta GoAB |
| `apiToken` | string | Token de API |
| `timeoutMillis` | number | Timeout HTTP (milissegundos; padrão: 30 000) |
| `storage` | `SurveyStorage` | Armazenamento chave/valor; padrão: `AsyncStorage` (peer dependency) |

**Retorna:** instância de [SurveySdk](#surveysdk) (não inicializada até [initialize](#initialize)).

**Exemplo:**

```tsx
import { SurveySdkFactory } from '@goab_ltda/survey-sdk-react-native';

const surveySdk = SurveySdkFactory.create({
  accountId: 2,
  apiToken: 'your-api-token',
  timeoutMillis: 30_000,
});
```

---

## SurveyStorage

Formato de armazenamento chave/valor assíncrono que o `create` aceita em `storage`. Qualquer objeto com estes três métodos serve — por exemplo, um adaptador de MMKV.

```ts
interface SurveyStorage {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
}
```

---

## SurveyHost

Componente React que apresenta a pesquisa na tela — equivalente ao `setPresentationHost` dos SDKs nativos. Monte-o **uma vez**, como último filho da raiz do app.

```tsx
function SurveyHost(props: {
  sdk: SurveySdk;
  bottomInset?: number;
}): JSX.Element;
```

| Prop | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| `sdk` | `SurveySdk` | Sim | A instância criada por [`SurveySdkFactory.create`](#create) |
| `bottomInset` | number | Não | Espaço extra abaixo da barra minimizada (ex.: a área segura inferior do aparelho) |

**Exemplo:**

```tsx
<SurveyHost sdk={surveySdk} bottomInset={insets.bottom} />
```

---

## OnSurveyEventListener

Tipo de callback para os eventos da pesquisa — impressão, resposta,
minimizar, envio, fecho, etc.

```ts
type OnSurveyEventListener = (event: SurveyAnalyticsEvent) => void;
```

A tipagem de `SurveyAnalyticsEvent`, a lista de [tipos de evento](./events#tipos-de-evento)
e exemplos de uso estão em **[Eventos de Survey](./events)**.

**Exemplo:**

```tsx
const listener: OnSurveyEventListener = (event) => {
  console.log(`event=${event.eventType} surveyId=${event.surveyId}`);
};

surveySdk.addOnSurveyEventListener(listener);

// ao desmontar / logout:
surveySdk.removeOnSurveyEventListener(listener);
```

---

## SurveySdk

Classe principal do SDK.

### `initialize`

```ts
initialize(): Promise<void>
```

Prepara o SDK para uso. Chame uma vez depois de criar a instância.

**Exemplo:**

```tsx
useEffect(() => {
  surveySdk.initialize();
}, []);
```

---

### `isInitialized`

```ts
isInitialized(): boolean
```

**Retorna:** `true` se [initialize](#initialize) concluiu.

---

### `sendEvent`

```ts
sendEvent(eventName: string, props?: Record<string, unknown>): void
```

Informa ao SDK que algo aconteceu na app (ex.: o usuário abriu uma tela ou concluiu uma ação). O SDK avalia se deve exibir uma pesquisa.

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `eventName` | string | Nome do evento (ex.: `"screen_view"`, `"purchase"`) |
| `props` | `Record<string, unknown>` | Propriedades do evento. Para telas: `screen_name`, `screen_class` |

**Comportamento:**

- Se o SDK ainda não terminou o [initialize](#initialize), o evento fica guardado e é enviado assim que o SDK ficar pronto (até 20 eventos, descartando o mais antigo, e só se tiverem menos de 30 segundos). Trocar o usuário com [setUserId](#setuserid) ou chamar [disposeSurvey](#disposesurvey) descarta os eventos guardados.
- Ignorado se já houver uma pesquisa aberta na tela.
- Ignorado (silenciosamente, com aviso no log) se não houver um [`<SurveyHost>`](#surveyhost) montado quando o SDK decidir exibir uma pesquisa.

**Exemplo:**

```tsx
surveySdk.sendEvent('screen_view', {
  screen_name: 'ProductDetail',
  screen_class: 'ProductDetailScreen',
});

surveySdk.sendEvent('checkout_started', { cart_value: 150.0 });
```

---

### `setUserId`

```ts
setUserId(userId: string | null): void
```

Define o ID do usuário logado.

- `null` ou string em branco remove o usuário.
- Ao mudar o ID, pesquisas abertas são fechadas e uma nova sessão analítica é iniciada.
- Sem um usuário definido, o SDK usa um identificador anônimo próprio (gerado e guardado no aparelho) nas chamadas ao servidor; quando você define o usuário, ele passa a valer no lugar do anônimo.

---

### `setUserAttributes`

```ts
setUserAttributes(attributes: Record<string, string> | null): void
```

Define atributos do usuário (ex.: plano, segmento, país).

```tsx
surveySdk.setUserAttributes({ plan: 'enterprise', locale: 'pt-BR' });

surveySdk.setUserAttributes(null); // limpar
```

---

### `disposeSurvey`

```ts
disposeSurvey(): void
```

Fecha qualquer pesquisa visível na tela.

Pode ser chamado mesmo antes de [initialize](#initialize).

```tsx
surveySdk.disposeSurvey();
```

---

### `addOnSurveyEventListener`

```ts
addOnSurveyEventListener(listener: OnSurveyEventListener): void
```

Registra um observador de eventos da pesquisa.

- Vários listeners podem coexistir.
- O **mesmo** objeto função não é registrado duas vezes (comparação por referência).

---

### `removeOnSurveyEventListener`

```ts
removeOnSurveyEventListener(listener: OnSurveyEventListener): void
```

Remove um listener previamente registrado com [addOnSurveyEventListener](#addonsurveyeventlistener).

---

## Exemplo completo

```tsx
import { useEffect } from 'react';
import { SurveySdkFactory, SurveyHost } from '@goab_ltda/survey-sdk-react-native';
import type { SurveyAnalyticsEvent } from '@goab_ltda/survey-sdk-react-native';

const surveySdk = SurveySdkFactory.create({
  accountId: 2,
  apiToken: 'your-api-token',
  timeoutMillis: 30_000,
});

export default function App() {
  useEffect(() => {
    surveySdk.setUserId(getLoggedInUserId());
    surveySdk.initialize();

    const listener = (event: SurveyAnalyticsEvent) => {
      console.log('survey event', event.eventType);
    };
    surveySdk.addOnSurveyEventListener(listener);
    return () => surveySdk.removeOnSurveyEventListener(listener);
  }, []);

  return (
    <>
      <Navegacao />
      <SurveyHost sdk={surveySdk} />
    </>
  );
}

function onCheckoutOpened() {
  surveySdk.sendEvent('screen_view', { screen_name: 'Checkout' });
}

function onLogout() {
  surveySdk.disposeSurvey();
  surveySdk.setUserId(null);
  surveySdk.setUserAttributes(null);
}
```

## Próximos passos

- [Guia de Início Rápido](./getting-started) — setup básico
