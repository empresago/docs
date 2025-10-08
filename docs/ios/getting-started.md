---
sidebar_position: 2
---

# Guia de Início Rápido

Configure o GoAB SDK em sua aplicação Android em poucos minutos.

## Pré-requisitos

- Android Studio Arctic Fox ou superior
- Android API 21+ (Android 5.0)
- Kotlin 1.8+
- Coroutines

## 1. Adicionar Dependências

### Gradle (app/build.gradle)

```gradle
dependencies {
    implementation 'io.goab:goab-sdk-clean:1.0.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.2'
}
```

### Maven (pom.xml)

```xml
<dependency>
    <groupId>io.goab</groupId>
    <artifactId>goab-sdk-clean</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 2. Configuração Simplificada

### Configuração Automática

O SDK agora preenche automaticamente as informações do dispositivo e aplicação. Você só precisa fornecer os parâmetros essenciais:

```kotlin
import io.goab.sdk.GoABSDKFactory

// Configuração simplificada - o SDK preenche automaticamente:
// - packageName, packageVersion (da aplicação)
// - deviceId, deviceModel, osVersion (do dispositivo)
// - screenResolution, networkType (do sistema)
// - timezone, country, language (do sistema)
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 12345,
    apiToken = "your-api-token",
    timeoutSeconds = 30
)
```

## 3. Inicializar o SDK

### Na sua Activity/Fragment

```kotlin
import io.goab.sdk.GoABSDKFactory
import io.goab.sdk.GoABSDK
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Criar e inicializar SDK em uma linha
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        // Inicializar em background
        lifecycleScope.launch {
            goabSDK.initialize()
        }
    }
}
```

### Usando ViewModel (Recomendado)

```kotlin
class MainViewModel(application: Application) : AndroidViewModel(application) {
    private val goabSDK: GoABSDK by lazy {
        GoABSDKFactory.create(
            context = application,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
    }
    
    init {
        viewModelScope.launch {
            goabSDK.initialize()
        }
    }
}
```

## 4. Usar Valores dos Experimentos

### Obter Valores

```kotlin
// String
val buttonText = goabSDK.getValue("button_text", "Clique Aqui")

// Boolean
val showFeature = goabSDK.getValue("show_new_feature", false)

// Number
val maxRetries = goabSDK.getValue("max_retries", 3)

// JSON (como String)
val configJson = goabSDK.getValue("feature_config", "{}")
```

### Em Views

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
    }
    
    private fun setupSDK() {
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        lifecycleScope.launch {
            goabSDK.initialize()
            setupUI() // Configurar UI após inicialização
        }
    }
    
    private fun setupUI() {
        // Aplicar valores dos experimentos
        val button = findViewById<Button>(R.id.button)
        val buttonText = goabSDK.getValue("button_text", "Clique Aqui")
        button.text = buttonText.toString()
        
        val showBanner = goabSDK.getValue("show_banner", true)
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner as Boolean) View.VISIBLE else View.GONE
    }
}
```

## 5. Enviar Eventos

```kotlin
// Evento simples
goabSDK.sendEvent("button_clicked")

// Evento com propriedades
goabSDK.sendEvent("purchase_completed", mapOf(
    "product_id" to "prod_123",
    "price" to 29.99,
    "currency" to "BRL"
))
```

## 6. Verificar Status

```kotlin
// Verificar se está inicializado
if (goabSDK.isInitialized()) {
    // SDK pronto para uso
}

// Obter userId atual
val currentUserId = goabSDK.getCurrentUserId()
```

## Próximos Passos

- [Inicialização Avançada](./initialization) - Configurações detalhadas
- [API Reference](./api-reference) - Todos os métodos disponíveis
- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas

## Exemplo Completo

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
    }
    
    private fun setupSDK() {
        // Configuração simplificada - o SDK preenche automaticamente as informações
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        lifecycleScope.launch {
            goabSDK.initialize()
            applyExperiments()
        }
    }
    
    private fun applyExperiments() {
        // Aplicar experimentos
        val buttonText = goabSDK.getValue("button_text", "Clique Aqui")
        findViewById<Button>(R.id.button).text = buttonText.toString()
        
        val showBanner = goabSDK.getValue("show_banner", true)
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner as Boolean) View.VISIBLE else View.GONE
    }
    
    private fun onButtonClick() {
        // Enviar evento
        goabSDK.sendEvent("button_clicked", mapOf(
            "button_id" to "main_button",
            "timestamp" to System.currentTimeMillis()
        ))
    }
}
```
