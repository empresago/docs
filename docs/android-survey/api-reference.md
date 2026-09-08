---
sidebar_position: 5
---

# API Reference

Documentação da **API pública** do GoAB Survey SDK Android.

---

## SurveySdkFactory

Factory para criar instâncias do SDK.

### `create`

```kotlin
import io.goab.survey.platform.SurveyPlatformContext

fun create(
    context: SurveyPlatformContext,
    accountId: Int,
    apiToken: String,
    timeoutMillis: Long = 30_000L
): SurveySdk
```

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `context` | SurveyPlatformContext | Contexto da plataforma — em Android, envolva com `SurveyPlatformContext(context)` |
| `accountId` | Int | ID da conta GoAB |
| `apiToken` | String | Token de API |
| `timeoutMillis` | Long | Timeout HTTP (milissegundos; padrão: 30 000) |

**Retorna:** instância de [SurveySdk](#surveysdk) (não inicializada até [initialize](#initialize)).

**Exemplo:**

```kotlin
import io.goab.survey.platform.SurveyPlatformContext

val surveySdk = SurveySdkFactory.create(
    context = SurveyPlatformContext(this),
    accountId = 2,
    apiToken = "your-api-token",
    timeoutMillis = 30_000L
)
```

---

## SurveyUiHost

Contexto mínimo que a app host fornece para apresentar surveys.

```kotlin
data class SurveyUiHost(
    val fragmentManager: FragmentManager,
    val context: Context
)
```

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `fragmentManager` | FragmentManager | Gerencia fragments de survey (tipicamente `supportFragmentManager`) |
| `context` | Context | Contexto da Activity para inflar layouts e temas |

**Exemplo:**

```kotlin
surveySdk.setPresentationHost(
    SurveyUiHost(supportFragmentManager, this@MainActivity)
)
```

---

## OnSurveyEventListener

`fun interface` de callback para os eventos da survey — impressão, resposta,
minimizar, envio, fecho, etc.

```kotlin
fun interface OnSurveyEventListener {
    fun onSurveyEvent(event: SurveyAnalyticsEvent)
}
```

| Método | Descrição |
|--------|-----------|
| `onSurveyEvent` | Recebe um [`SurveyAnalyticsEvent`](./events#surveyanalyticsevent) por evento |

A tipagem de `SurveyAnalyticsEvent`, a lista de [tipos de evento](./events#tipos-de-evento)
e exemplos de uso estão em **[Eventos de Survey](./events)**.

**Exemplo:**

```kotlin
val listener = OnSurveyEventListener { event ->
    Log.d("Survey", "event=${event.eventType.wireValue} surveyId=${event.surveyId}")
}

surveySdk.addOnSurveyEventListener(listener)

// ao destruir Activity / logout:
surveySdk.removeOnSurveyEventListener(listener)
```

---

## SurveySdk

Classe principal do SDK.

### `initialize`

```kotlin
suspend fun initialize()
```

Prepara o SDK para uso. Chame uma vez antes de [sendEvent](#sendevent).

**Exemplo:**

```kotlin
lifecycleScope.launch {
    surveySdk.initialize()
}
```

---

### `isInitialized`

```kotlin
fun isInitialized(): Boolean
```

**Retorna:** `true` se [initialize](#initialize) concluiu.

---

### `sendEvent`

```kotlin
fun sendEvent(
    eventName: String,
    props: Map<String, Any> = emptyMap()
)
```

Informa ao SDK que algo aconteceu na app (ex.: o usuário abriu uma tela ou concluiu uma ação). O SDK avalia se deve exibir uma pesquisa.

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `eventName` | String | Nome do evento (ex.: `"screen_view"`, `"purchase"`) |
| `props` | Map | Propriedades do evento. Para telas: `screen_name`, `screen_class` |

**Comportamento:**

- Ignorado se o SDK não estiver inicializado
- Ignorado se já houver uma pesquisa aberta na tela

**Exemplo:**

```kotlin
surveySdk.sendEvent("screen_view", mapOf(
    "screen_name" to "ProductDetail",
    "screen_class" to "ProductDetailActivity"
))

surveySdk.sendEvent(
    eventName = "checkout_started",
    props = mapOf("cart_value" to 150.0)
)
```

---

### `setPresentationHost`

```kotlin
fun setPresentationHost(host: SurveyUiHost?)
```

Define onde o SDK pode apresentar pesquisas na tela. Passe `null` para remover.

---

### `setUserId`

```kotlin
fun setUserId(userId: String?)
```

Define o ID do usuário logado.

- `null` ou string em branco remove o usuário
- Ao mudar o ID, pesquisas abertas são fechadas

---

### `setUserAttributes`

```kotlin
fun setUserAttributes(attributes: Map<String, String>?)
```

Define atributos do usuário (ex.: plano, segmento, país).

```kotlin
surveySdk.setUserAttributes(mapOf(
    "plan" to "enterprise",
    "locale" to "pt-BR"
))

surveySdk.setUserAttributes(null) // limpar
```

---

### `disposeSurvey`

```kotlin
fun disposeSurvey()
```

Fecha qualquer pesquisa visível na tela.

Pode ser chamado mesmo antes de [initialize](#initialize).

```kotlin
surveySdk.disposeSurvey()
```

---

### `setInspectEnabled`

```kotlin
fun setInspectEnabled(enabled: Boolean)
```

Habilita ou desabilita Chrome DevTools inspect para WebViews do SDK.

**Recomendação:** use apenas em builds de desenvolvimento ou homologação.

```kotlin
if (BuildConfig.DEBUG) {
    surveySdk.setInspectEnabled(true)
}
```

---

### `addOnSurveyEventListener`

```kotlin
fun addOnSurveyEventListener(listener: OnSurveyEventListener)
```

Regista um observador de eventos da survey.

- Vários listeners podem coexistir
- O mesmo listener não é registado duas vezes

---

### `removeOnSurveyEventListener`

```kotlin
fun removeOnSurveyEventListener(listener: OnSurveyEventListener)
```

Remove um listener previamente registado com [addOnSurveyEventListener](#addonsurveyeventlistener).

---

## Exemplo completo

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var surveySdk: SurveySdk

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        surveySdk = SurveySdkFactory.create(
            context = this,
            accountId = 2,
            apiToken = "your-api-token",
            timeoutMillis = 30_000L
        )

        lifecycleScope.launch {
            if (BuildConfig.DEBUG) {
                surveySdk.setInspectEnabled(true)
            }
            surveySdk.setPresentationHost(
                SurveyUiHost(supportFragmentManager, this@MainActivity)
            )
            surveySdk.setUserId(getLoggedInUserId())
            surveySdk.initialize()
        }
    }

    override fun onResume() {
        super.onResume()
        surveySdk.setPresentationHost(
            SurveyUiHost(supportFragmentManager, this)
        )
    }

    fun onCheckoutOpened() {
        surveySdk.sendEvent("screen_view", mapOf(
            "screen_name" to "Checkout"
        ))
    }

    fun onLogout() {
        surveySdk.disposeSurvey()
        surveySdk.setUserId(null)
        surveySdk.setUserAttributes(null)
    }
}
```

## Próximos passos

- [Guia de Início Rápido](./getting-started) — setup básico
- [Inicialização](./initialization) — ciclo de vida e setup
