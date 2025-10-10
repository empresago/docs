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
    implementation 'io.goab:goab-sdk:1.0.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.2'
}
```

### Configuração do Repositório

Adicione o repositório S3 do GoAB no seu `settings.gradle`:

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

### Maven (pom.xml)

```xml
<dependency>
    <groupId>io.goab</groupId>
    <artifactId>goab-sdk</artifactId>
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
    accountId = 2,  // ID da sua conta
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",  // Seu token de API
    timeoutSeconds = 30
)
```

### Parâmetros Obrigatórios

| Parâmetro | Tipo | Descrição | Exemplo |
|-----------|------|-----------|---------|
| `context` | Context | Contexto Android | `this` (Activity) |
| `accountId` | Int | ID da sua conta no GoAB | `2` |
| `apiToken` | String | Token de autenticação | `"app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8"` |

### Parâmetros Opcionais

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `timeoutSeconds` | Int | 30 | Timeout das requisições em segundos |

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
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
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
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
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
// String - Cores de botões
val buttonColor = goabSDK.getValue("button_color", "#4CAF50") as String

// String - Texto de botões
val buttonText = goabSDK.getValue("button_text", "Clique Aqui") as String

// Boolean - Mostrar/ocultar features
val showFeature = goabSDK.getValue("show_new_feature", false) as Boolean

// Number - Configurações numéricas
val maxRetries = goabSDK.getValue("max_retries", 3) as Int

// String - Cores de elementos específicos
val footerButtonColor = goabSDK.getValue("footer_btn_color", "#4CAF50") as String
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
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
            timeoutSeconds = 30
        )
        
        lifecycleScope.launch {
            goabSDK.initialize()
            setupUI() // Configurar UI após inicialização
        }
    }
    
    private fun setupUI() {
        // Aplicar cores dos experimentos
        applyButtonColors()
        
        // Aplicar textos dos experimentos
        val button = findViewById<Button>(R.id.button)
        val buttonText = goabSDK.getValue("button_text", "Clique Aqui") as String
        button.text = buttonText
        
        // Mostrar/ocultar features
        val showBanner = goabSDK.getValue("show_banner", true) as Boolean
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner) View.VISIBLE else View.GONE
    }
    
    private fun applyButtonColors() {
        try {
            // Cor do botão principal
            val buttonColor = goabSDK.getValue("button_color", "#4CAF50") as String
            val color = Color.parseColor(buttonColor)
            findViewById<Button>(R.id.card1Button).setBackgroundColor(color)
            
            // Cor do botão flutuante
            val footerButtonColor = goabSDK.getValue("footer_btn_color", "#4CAF50") as String
            val fabColor = Color.parseColor(footerButtonColor)
            findViewById<FloatingActionButton>(R.id.fab).backgroundTintList = 
                ColorStateList.valueOf(fabColor)
                
        } catch (e: Exception) {
            Log.e("MainActivity", "Erro ao aplicar cores", e)
        }
    }
}
```

## 5. Enviar Eventos

```kotlin
// Evento simples
goabSDK.sendEvent("button_clicked")

// Evento de compra com propriedades
goabSDK.sendEvent("purchase", mapOf(
    "revenue" to 120,
    "product_id" to "prod_123",
    "currency" to "BRL"
))

// Evento de renderização de botão
goabSDK.sendEvent("button_rendered", mapOf(
    "button_id" to 1,
    "button_type" to "primary"
))

// Evento de renderização de botão do rodapé
goabSDK.sendEvent("button_rendered", mapOf(
    "footer_btn_id" to 1,
    "button_type" to "floating"
))
```

## 6. Verificar Status

```kotlin
// Verificar se está inicializado
if (goabSDK.isInitialized()) {
    // SDK pronto para uso
    val value = goabSDK.getValue("button_color", "#4CAF50")
}

// Obter userId atual
val currentUserId = goabSDK.getCurrentUserId()

// Obter userId persistido (do SharedPreferences)
lifecycleScope.launch {
    val userId = goabSDK.getUserId()
    println("User ID: $userId")
}

// Atualizar userId
lifecycleScope.launch {
    goabSDK.setUserId("new_user_123")
}

// Limpar experimentos ativos
lifecycleScope.launch {
    goabSDK.clearActiveUsers()
}
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
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
            timeoutSeconds = 30
        )
        
        lifecycleScope.launch {
            goabSDK.initialize()
            applyExperiments()
        }
    }
    
    private fun applyExperiments() {
        // Aplicar cores dos experimentos
        try {
            val buttonColor = goabSDK.getValue("button_color", "#4CAF50") as String
            val color = Color.parseColor(buttonColor)
            findViewById<Button>(R.id.card1Button).setBackgroundColor(color)
            
            val footerButtonColor = goabSDK.getValue("footer_btn_color", "#4CAF50") as String
            val fabColor = Color.parseColor(footerButtonColor)
            findViewById<FloatingActionButton>(R.id.fab).backgroundTintList = 
                ColorStateList.valueOf(fabColor)
        } catch (e: Exception) {
            Log.e("MainActivity", "Erro ao aplicar cores", e)
        }
        
        // Aplicar textos dos experimentos
        val buttonText = goabSDK.getValue("button_text", "Clique Aqui") as String
        findViewById<Button>(R.id.button).text = buttonText
        
        // Mostrar/ocultar features
        val showBanner = goabSDK.getValue("show_banner", true) as Boolean
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner) View.VISIBLE else View.GONE
    }
    
    private fun onButtonClick() {
        // Enviar evento de compra
        goabSDK.sendEvent("purchase", mapOf(
            "revenue" to 120,
            "product_id" to "prod_123"
        ))
        
        // Enviar evento de renderização
        goabSDK.sendEvent("button_rendered", mapOf(
            "button_id" to 1,
            "button_type" to "primary"
        ))
    }
    
    private fun onUserIdUpdate(newUserId: String) {
        lifecycleScope.launch {
            try {
                goabSDK.setUserId(newUserId)
                Log.d("MainActivity", "UserId atualizado: $newUserId")
            } catch (e: Exception) {
                Log.e("MainActivity", "Erro ao atualizar userId", e)
            }
        }
    }
}
```
