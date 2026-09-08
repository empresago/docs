---
sidebar_position: 5
---

# API Reference

Documentação da **API pública** do GoAB Survey SDK iOS.

---

## SurveySdkFactory

Factory para criar instâncias do SDK, acessada via `.shared`.

### `create`

```swift
func create(
    context: SurveyPlatformContext,
    accountId: Int32,
    apiToken: String,
    timeoutMillis: Int64 = 30_000
) -> SurveySdk
```

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `context` | SurveyPlatformContext | Marcador de plataforma — no iOS não carrega estado, use `SurveyPlatformContext()` |
| `accountId` | Int32 | ID da conta GoAB |
| `apiToken` | String | Token de API |
| `timeoutMillis` | Int64 | Timeout HTTP (milissegundos; padrão: 30 000) |

**Retorna:** instância de [SurveySdk](#surveysdk) (não inicializada até [initialize](#initialize)).

**Exemplo:**

```swift
import GoABSurveySDK

let surveySdk: SurveySdk = SurveySdkFactory.shared.create(
    context: SurveyPlatformContext(),
    accountId: 2,
    apiToken: "your-api-token",
    timeoutMillis: 30_000
)
```

---

## SurveyPlatformContext

Contexto mínimo exigido pela API multiplataforma. No Android envolve o `Context`; no iOS é um marcador sem propriedades.

```swift
SurveyPlatformContext()
```

---

## SurveyUiHost

Contexto mínimo que a app host fornece para apresentar surveys. No iOS, envolve diretamente o `UIViewController` responsável pela apresentação.

```swift
class SurveyUiHost {
    init(viewController: UIViewController)
}
```

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `viewController` | UIViewController | Controller a partir do qual a survey (WebView) é apresentada |

**Exemplo:**

```swift
surveySdk.setPresentationHost(host: SurveyUiHost(viewController: self))
```

---

## OnSurveyEventListener

Closure chamado a cada evento de telemetria da survey — impressão, resposta,
minimizar, envio, fecho, etc.

```swift
func addOnSurveyEventListener(
    listener: @escaping (SurveyAnalyticsEvent) -> Void
) -> OnSurveyEventListener

func removeOnSurveyEventListener(listener: OnSurveyEventListener)
```

`addOnSurveyEventListener` retorna um handle opaco (`OnSurveyEventListener`) que
você guarda para remover o listener depois. A tipagem completa do parâmetro, a
lista de [tipos de evento](./events#tipos-de-evento) e o estado atual da entrega
estão em **[Eventos de Survey](./events)**.

**Exemplo:**

```swift
let handle = surveySdk.addOnSurveyEventListener { event in
    print("event=\(event.eventType) surveyId=\(event.surveyId ?? 0)")
}

// ao encerrar a tela / logout:
surveySdk.removeOnSurveyEventListener(listener: handle)
```

---

## SurveySdk

Classe principal do SDK.

### `initialize`

```swift
func initialize() async throws
```

Prepara o SDK para uso. Chame uma vez antes de [sendEvent](#sendevent).

**Exemplo:**

```swift
Task {
    try await surveySdk.initialize()
}
```

---

### `isInitialized`

```swift
func isInitialized() -> Bool
```

**Retorna:** `true` se [initialize](#initialize) concluiu.

---

### `sendEvent`

```swift
func sendEvent(
    eventName: String,
    props: [String: Any] = [:]
)
```

Informa ao SDK que algo aconteceu na app (ex.: o usuário abriu uma tela ou concluiu uma ação). O SDK avalia se deve exibir uma pesquisa.

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `eventName` | String | Nome do evento (ex.: `"screen_view"`, `"purchase"`) |
| `props` | Dictionary | Propriedades do evento. Para telas: `screen_name`, `screen_class` |

**Comportamento:**

- Ignorado se o SDK não estiver inicializado
- Ignorado se já houver uma pesquisa aberta na tela

**Exemplo:**

```swift
surveySdk.sendEvent(eventName: "screen_view", props: [
    "screen_name": "ProductDetail",
    "screen_class": "ProductDetailViewController"
])

surveySdk.sendEvent(eventName: "checkout_started", props: [
    "cart_value": 150.0
])
```

---

### `setPresentationHost`

```swift
func setPresentationHost(host: SurveyUiHost?)
```

Define de qual `UIViewController` o SDK pode apresentar pesquisas. Passe `nil` para remover.

---

### `setUserId`

```swift
func setUserId(userId: String?)
```

Define o ID do usuário logado.

- `nil` ou string em branco remove o usuário
- Ao mudar o ID, pesquisas abertas são fechadas

---

### `setUserAttributes`

```swift
func setUserAttributes(attributes: [String: String]?)
```

Define atributos do usuário (ex.: plano, segmento, país).

```swift
surveySdk.setUserAttributes(attributes: [
    "plan": "enterprise",
    "locale": "pt-BR"
])

surveySdk.setUserAttributes(attributes: nil) // limpar
```

---

### `disposeSurvey`

```swift
func disposeSurvey()
```

Fecha qualquer pesquisa visível na tela.

Pode ser chamado mesmo antes de [initialize](#initialize).

```swift
surveySdk.disposeSurvey()
```

---

### `addOnSurveyEventListener`

```swift
func addOnSurveyEventListener(listener: @escaping (SurveyAnalyticsEvent) -> Void) -> OnSurveyEventListener
```

Regista um observador de eventos da survey. Vários listeners podem coexistir.

---

### `removeOnSurveyEventListener`

```swift
func removeOnSurveyEventListener(listener: OnSurveyEventListener)
```

Remove um listener previamente registado com [addOnSurveyEventListener](#addonsurveyeventlistener).

## Exemplo completo

```swift
import GoABSurveySDK
import UIKit

class SurveyManager {
    private let surveySdk: SurveySdk

    init() {
        surveySdk = SurveySdkFactory.shared.create(
            context: SurveyPlatformContext(),
            accountId: 2,
            apiToken: "your-api-token",
            timeoutMillis: 30_000
        )
    }

    func start(presentingFrom viewController: UIViewController, userId: String?) {
        surveySdk.setPresentationHost(host: SurveyUiHost(viewController: viewController))
        surveySdk.setUserId(userId: userId)

        Task {
            do {
                try await surveySdk.initialize()
            } catch {
                print("Falha na inicialização do Survey SDK: \(error)")
            }
        }
    }

    func onCheckoutOpened() {
        surveySdk.sendEvent(eventName: "screen_view", props: [
            "screen_name": "Checkout"
        ])
    }

    func onLogout() {
        surveySdk.disposeSurvey()
        surveySdk.setUserId(userId: nil)
        surveySdk.setUserAttributes(attributes: nil)
    }
}
```

## Próximos passos

- [Guia de Início Rápido](./getting-started) — setup básico
- [Inicialização](./initialization) — ciclo de vida e setup
