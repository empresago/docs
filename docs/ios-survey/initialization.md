---
sidebar_position: 3
---

# Inicialização

Configure o Survey SDK na sua app iOS.

## Criar instância

```swift
import GoABSurveySDK

let surveySdk: SurveySdk = SurveySdkFactory.shared.create(
    context: SurveyPlatformContext(),
    accountId: 2,
    apiToken: "your-api-token",
    timeoutMillis: 30_000
)
```

## Ordem recomendada de setup

```swift
Task {
    // 1. Criar instância
    let surveySdk = SurveySdkFactory.shared.create(
        context: SurveyPlatformContext(),
        accountId: 2,
        apiToken: "your-api-token",
        timeoutMillis: 30_000
    )

    // 2. Onde a pesquisa pode aparecer na tela
    surveySdk.setPresentationHost(host: SurveyUiHost(viewController: rootViewController))

    // 3. Usuário (se já conhecido)
    surveySdk.setUserId(userId: currentUserId)
    surveySdk.setUserAttributes(attributes: userAttributes)

    // 4. Preparar o SDK
    do {
        try await surveySdk.initialize()
    } catch {
        print("Falha na inicialização: \(error)")
    }
}
```

## O que `initialize()` faz

Prepara o SDK para receber eventos e exibir pesquisas. Deve ser chamado **uma vez** após criar a instância.

`initialize()` é `async throws` — chame sempre de dentro de uma `Task` ou de um contexto `async`.

## Verificar estado

```swift
if surveySdk.isInitialized() {
    surveySdk.sendEvent(eventName: "app_ready", props: [:])
} else {
    print("SDK ainda não inicializado")
}
```

`sendEvent` antes de `initialize()` é ignorado (sem crash).

## Ciclo de vida da tela

Atualize o [SurveyUiHost](api-reference#surveyuihost) sempre que a `UIViewController` responsável por apresentar conteúdo mudar — por exemplo, ao trocar a tela em primeiro plano:

```swift
func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    surveySdk.setPresentationHost(host: SurveyUiHost(viewController: self))
}
```

Passar `nil` remove o host atual e impede novas apresentações até que um novo seja definido.

## Tratamento de erros

```swift
Task {
    do {
        try await surveySdk.initialize()
    } catch {
        print("Falha na inicialização do Survey SDK: \(error)")
    }
}
```

Se a inicialização falhar, trate o erro na app e tente novamente quando fizer sentido (ex.: após o usuário recuperar conexão).

## Próximos passos

- [API Reference](./api-reference) — referência completa da API pública
