---
sidebar_position: 2
---

# Guia de Início Rápido

Configure o GoAB Survey SDK na sua aplicação Android.

## Pré-requisitos

- Android Studio Arctic Fox ou superior
- Android API 21+ (Android 5.0)
- Kotlin 1.8+
- Coroutines

## 1. Adicionar dependência

### Gradle (app/build.gradle)

```gradle
dependencies {
    implementation 'io.goab:goab-survey-sdk-android:1.0.0'
}
```

### Repositório Maven

```gradle
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://devs.goab.io/android/releases/")
        }
    }
}
```

## 2. Criar instância

```kotlin
import io.goab.survey.sdk.SurveySdkFactory

val surveySdk = SurveySdkFactory.create(
    context = this,
    accountId = 2,
    apiToken = "your-api-token",
    timeoutMillis = 30_000L
)
```

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `context` | Context | Sim | Contexto Android (tipicamente da Activity) |
| `accountId` | Int | Sim | ID da conta GoAB |
| `apiToken` | String | Sim | Token de API da aplicação |
| `timeoutMillis` | Long | Não | Timeout HTTP em milissegundos (padrão: 30 000) |

## 3. Inicializar e registar host de UI

O SDK precisa de um [SurveyUiHost](api-reference#surveyuihost) para apresentar surveys:

```kotlin
import io.goab.survey.ui.SurveyUiHost
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    private lateinit var surveySdk: SurveySdk

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        surveySdk = SurveySdkFactory.create(
            context = this,
            accountId = 2,
            apiToken = "your-api-token",
            timeoutMillis = 30_000L
        )

        lifecycleScope.launch {
            surveySdk.setPresentationHost(
                SurveyUiHost(supportFragmentManager, this@MainActivity)
            )
            surveySdk.initialize()
        }
    }

    override fun onResume() {
        super.onResume()
        // Re-registar após rotação / retorno à Activity
        surveySdk.setPresentationHost(
            SurveyUiHost(supportFragmentManager, this@MainActivity)
        )
    }
}
```

## 4. Enviar eventos de ativação

```kotlin
// Tela visitada
surveySdk.sendEvent("screen_view", mapOf(
    "screen_name" to "Checkout",
    "screen_class" to "CheckoutActivity"
))

// Evento customizado
surveySdk.sendEvent("purchase_completed", mapOf(
    "plan" to "premium",
    "revenue" to 99.90
))
```

Enquanto houver uma survey ativa na tela, novos `sendEvent` são ignorados — a survey corrente não é substituída.

## 5. Utilizador e atributos

```kotlin
surveySdk.setUserId("user_123")

surveySdk.setUserAttributes(mapOf(
    "segment" to "premium",
    "country" to "BR"
))
```

Ao mudar o `userId`, surveys visíveis são fechadas e uma nova sessão analítica é iniciada.

## 6. Observar eventos de survey (opcional)

```kotlin
import io.goab.survey.sdk.OnSurveyEventListener

val surveyListener = OnSurveyEventListener { event ->
    Log.d("Survey", "telemetria: ${event.eventType}")
}
surveySdk.addOnSurveyEventListener(surveyListener)

// remover quando não precisar mais:
surveySdk.removeOnSurveyEventListener(surveyListener)
```

## 7. Fechar survey visível

```kotlin
surveySdk.disposeSurvey()
```

Útil em logout, troca de conta ou navegação que deve dispensar a UI da survey.

## Próximos passos

- [Inicialização](./initialization) — configuração detalhada e ambientes
- [API Reference](./api-reference) — todos os métodos públicos
