---
sidebar_position: 2
---

# Guia de Início Rápido

Configure o GoAB Survey SDK na sua aplicação React Native.

## Pré-requisitos

- `react` >= 18.2.0
- `react-native` >= 0.77.0
- `react-native-webview` >= 13.0.0
- `@react-native-async-storage/async-storage` >= 1.17.0 (ou outro adaptador de armazenamento — veja [`storage`](./api-reference#create))

## 1. Instalar

```bash
npm install @goab_ltda/survey-sdk-react-native react-native-webview @react-native-async-storage/async-storage
```

## 2. Instalar o bridge nativo

O SDK inclui um **módulo nativo mínimo** (`GoabSurveyNative`) — só modelo do aparelho, bundle id e versão do app — que se conecta via autolinking padrão do React Native (Turbo Native Module).

- **Android**: nada a fazer além do passo 1. O autolinking do RN já inclui o módulo no próximo build nativo.
- **iOS**: rode o `pod install` para linkar o módulo e gerar o código do Turbo Module:

  ```bash
  cd ios && pod install
  ```

- Depois de instalar (ou atualizar) o pacote, **rebuilde o app nativo** (`npx react-native run-android` / `run-ios`, ou gere o build novo no Xcode/Android Studio) — recarregar só o bundle JS não é suficiente para pegar um módulo nativo novo.

:::note
O bridge nativo é **opcional**: requer a New Architecture do React Native (padrão desde a 0.76). Se não estiver disponível — Expo Go, app ainda na Old Architecture, ou o `pod install`/build nativo não foi feito — o SDK **degrada automaticamente**, sem erro: `getDeviceInfo` cai para valores genéricos (`deviceModel: "ios-device"`/`"android-device"`, `packageName`/`versionName` vazios) e tudo o resto do SDK funciona normalmente.
:::

## 3. Criar a instância

```tsx
import { SurveySdkFactory } from '@goab_ltda/survey-sdk-react-native';

const surveySdk = SurveySdkFactory.create({
  accountId: 2,
  apiToken: 'your-api-token',
});
```

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `accountId` | number | Sim | ID da conta GoAB |
| `apiToken` | string | Sim | Token de API da aplicação |
| `timeoutMillis` | number | Não | Timeout HTTP em milissegundos (padrão: 30 000) |
| `storage` | `{ getItem, setItem, removeItem }` | Não | Armazenamento chave/valor; padrão: `AsyncStorage` (ex.: para usar MMKV, passe um adaptador com essa forma) |

## 4. Montar o `<SurveyHost>`

O SDK precisa de um [`<SurveyHost>`](api-reference#surveyhost) montado na árvore para apresentar pesquisas — é o equivalente ao `setPresentationHost` dos SDKs nativos:

```tsx
import { useEffect } from 'react';
import { SurveySdkFactory, SurveyHost } from '@goab_ltda/survey-sdk-react-native';

const surveySdk = SurveySdkFactory.create({
  accountId: 2,
  apiToken: 'your-api-token',
});

export default function App() {
  useEffect(() => {
    surveySdk.initialize();
  }, []);

  return (
    <>
      <Navegacao />
      <SurveyHost sdk={surveySdk} />
      {/* UMA vez, como último filho da raiz do app — é onde a pesquisa aparece */}
    </>
  );
}
```

Sem o `<SurveyHost>` montado, o SDK decide que há uma pesquisa elegível mas não tem onde exibi-la — nada aparece na tela (e um aviso é registrado no log).

## 5. Enviar eventos de ativação

```tsx
// Tela visitada
surveySdk.sendEvent('screen_view', {
  screen_name: 'Checkout',
  screen_class: 'CheckoutScreen',
});

// Evento customizado
surveySdk.sendEvent('purchase_completed', {
  plan: 'premium',
  revenue: 99.9,
});
```

Enquanto houver uma pesquisa ativa na tela, novos `sendEvent` são ignorados — a pesquisa corrente não é substituída.

## 6. Usuário e atributos

```tsx
surveySdk.setUserId('user_123');

surveySdk.setUserAttributes({
  segment: 'premium',
  country: 'BR',
});
```

Ao mudar o `userId`, pesquisas visíveis são fechadas e uma nova sessão analítica é iniciada.

## 7. Observar eventos de pesquisa (opcional)

```tsx
import type { SurveyAnalyticsEvent } from '@goab_ltda/survey-sdk-react-native';

const listener = (event: SurveyAnalyticsEvent) => {
  console.log('survey event', event.eventType);
};
surveySdk.addOnSurveyEventListener(listener);

// remover quando não precisar mais:
surveySdk.removeOnSurveyEventListener(listener);
```

Veja [Eventos de Survey](./events) para a tipagem de `SurveyAnalyticsEvent`, a lista de tipos de evento e exemplos de uso.

## 8. Fechar pesquisa visível

```tsx
surveySdk.disposeSurvey();
```

Útil em logout, troca de conta ou navegação que deve dispensar a UI da pesquisa.

## Próximos passos

- [Inicialização](./initialization) — configuração detalhada e ciclo de vida
- [API Reference](./api-reference) — todos os métodos públicos
