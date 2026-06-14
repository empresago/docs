---
sidebar_position: 3
---

# Inicialização

Configure o Survey SDK na sua app.

## Criar instância

```kotlin
import io.goab.survey.platform.SurveyPlatformContext
import io.goab.survey.sdk.SurveySdkFactory

val surveySdk = SurveySdkFactory.create(
    context = SurveyPlatformContext(applicationContext),
    accountId = 2,
    apiToken = "your-api-token",
    timeoutMillis = 30_000L
)
```

## Ordem recomendada de setup

```kotlin
lifecycleScope.launch {
    // 1. Criar instância
    val surveySdk = SurveySdkFactory.create(...)

    // 2. (Opcional) inspeção de WebView — só em desenvolvimento
    if (BuildConfig.DEBUG) {
        surveySdk.setInspectEnabled(true)
    }

    // 3. Onde a pesquisa pode aparecer na tela
    surveySdk.setPresentationHost(SurveyUiHost(supportFragmentManager, this@MainActivity))

    // 4. Usuário (se já conhecido)
    surveySdk.setUserId(currentUserId)
    surveySdk.setUserAttributes(userAttributes)

    // 5. Preparar o SDK
    surveySdk.initialize()
}
```

## O que `initialize()` faz

Prepara o SDK para receber eventos e exibir pesquisas. Deve ser chamado **uma vez** após criar a instância.

`initialize()` é **suspend** — chame de uma coroutine (`lifecycleScope`, `viewModelScope`, etc.).

## Verificar estado

```kotlin
if (surveySdk.isInitialized()) {
    surveySdk.sendEvent("app_ready")
} else {
    Log.w("Survey", "SDK ainda não inicializado")
}
```

`sendEvent` antes de `initialize()` é ignorado (sem crash).

## Ciclo de vida da Activity

Registe o [SurveyUiHost](api-reference#surveyuihost) em `onResume` (ou após `onCreate`) para garantir que a pesquisa possa ser exibida:

```kotlin
override fun onResume() {
    super.onResume()
    surveySdk.setPresentationHost(
        SurveyUiHost(supportFragmentManager, this)
    )
}
```

## Tratamento de erros

```kotlin
lifecycleScope.launch {
    try {
        surveySdk.initialize()
    } catch (e: Exception) {
        Log.e("Survey", "Falha na inicialização", e)
    }
}
```

Se a inicialização falhar, trate o erro na app e tente novamente quando fizer sentido (ex.: após o usuário recuperar conexão).

## Próximos passos

- [API Reference](./api-reference) — referência completa da API pública
