---
sidebar_position: 2
---

# Guia de Início Rápido

Configure o GoAB Survey SDK na sua aplicação iOS.

## Pré-requisitos

- Xcode 14+
- iOS 14+
- Swift 5.9+

## 1. Adicionar o SDK

O pacote iOS do GoAB Survey SDK está disponível no GitHub: [empresago/goab-survey-sdk-ios](https://github.com/empresago/goab-survey-sdk-ios).

### Swift Package Manager (recomendado)

1. No Xcode: **File → Add Package Dependencies...**
2. Cole a URL do repositório:
   ```
   https://github.com/empresago/goab-survey-sdk-ios
   ```
3. Selecione a regra de dependência (ex.: **Up to Next Major Version**) e a versão desejada.
4. Adicione o produto **GoABSurveySDK** ao target do seu app.

Se o seu projeto usa `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/empresago/goab-survey-sdk-ios", from: "1.0.1")
]
```

O pacote distribui um XCFramework pré-compilado (`binaryTarget`) — não há build a partir do fonte.

## 2. Criar instância

```swift
import GoABSurveySDK

let surveySdk: SurveySdk = SurveySdkFactory.shared.create(
    context: SurveyPlatformContext(),
    accountId: 2,
    apiToken: "your-api-token",
    timeoutMillis: 30_000
)
```

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `context` | SurveyPlatformContext | Sim | Marcador de plataforma, sem propriedades no iOS — passe sempre `SurveyPlatformContext()` |
| `accountId` | Int32 | Sim | ID da conta GoAB |
| `apiToken` | String | Sim | Token de API da aplicação |
| `timeoutMillis` | Int64 | Não | Timeout HTTP em milissegundos (padrão: 30 000) |

`SurveySdkFactory` é um `object` Kotlin exposto no Swift como singleton — por isso o acesso é sempre via `SurveySdkFactory.shared`.

## 3. Inicializar e registar o host de apresentação

O SDK precisa de um [SurveyUiHost](api-reference#surveyuihost), que envolve o `UIViewController` onde a pesquisa será apresentada:

```swift
import GoABSurveySDK
import UIKit

class SurveyManager {
    let surveySdk: SurveySdk = SurveySdkFactory.shared.create(
        context: SurveyPlatformContext(),
        accountId: 2,
        apiToken: "your-api-token",
        timeoutMillis: 30_000
    )

    func start(presentingFrom viewController: UIViewController) async {
        surveySdk.setPresentationHost(host: SurveyUiHost(viewController: viewController))

        do {
            try await surveySdk.initialize()
        } catch {
            print("Falha ao inicializar o Survey SDK: \(error)")
        }
    }
}
```

`initialize()` é uma função `suspend` do Kotlin — no Swift ela chega como `async throws`. Chame-a a partir de uma `Task` ou de um contexto `async`.

Sempre que a `UIViewController` que apresenta a pesquisa mudar (ex.: nova tela em primeiro plano), atualize o host:

```swift
surveySdk.setPresentationHost(host: SurveyUiHost(viewController: currentViewController))
```

## 4. Enviar eventos de ativação

```swift
// Tela visitada
surveySdk.sendEvent(eventName: "screen_view", props: [
    "screen_name": "Checkout",
    "screen_class": "CheckoutViewController"
])

// Evento customizado
surveySdk.sendEvent(eventName: "purchase_completed", props: [
    "plan": "premium",
    "revenue": 99.90
])
```

Enquanto houver uma survey ativa na tela, novos `sendEvent` são ignorados — a survey corrente não é substituída.

## 5. Utilizador e atributos

```swift
surveySdk.setUserId(userId: "user_123")

surveySdk.setUserAttributes(attributes: [
    "segment": "premium",
    "country": "BR"
])
```

Ao mudar o `userId`, surveys visíveis são fechadas e uma nova sessão analítica é iniciada.

## 6. Observar eventos de survey (opcional)

`OnSurveyEventListener` é um `fun interface` do Kotlin, exposto no Swift como um closure:

```swift
let listener = surveySdk.addOnSurveyEventListener { event in
    print("telemetria: \(event.eventType)")
}
```

## 7. Fechar survey visível

```swift
surveySdk.disposeSurvey()
```

Útil em logout, troca de conta ou navegação que deve dispensar a UI da survey.

## Próximos passos

- [Inicialização](./initialization) — configuração detalhada e ciclo de vida
- [API Reference](./api-reference) — todos os métodos públicos
