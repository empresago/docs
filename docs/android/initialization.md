---
sidebar_position: 3
---

# Inicialização

Configure e inicialize o GoAB SDK com todas as opções disponíveis.

## Configuração Simplificada

### Factory Pattern

O SDK agora usa uma factory simplificada que preenche automaticamente as informações do dispositivo:

```kotlin
val sdk = GoABSDKFactory.create(
    context = this,           // Contexto Android
    accountId = 2,            // ID da conta
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",  // Token de API
    timeoutSeconds = 30       // Timeout das requisições
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

## Configuração Automática

O SDK agora preenche automaticamente todas as informações do dispositivo e aplicação:

### Informações Preenchidas Automaticamente

| Campo | Fonte | Exemplo |
|-------|-------|---------|
| `packageName` | `context.packageName` | `com.yourapp.package` |
| `packageVersion` | `PackageManager.getPackageInfo()` | `1.0.0` |
| `deviceId` | `Settings.Secure.ANDROID_ID` | `abc123def456` |
| `deviceModel` | `Build.MODEL` | `Samsung Galaxy S21` |
| `osVersion` | `Build.VERSION.RELEASE` | `12` |
| `screenResolution` | `DisplayMetrics` | `1080x2400` |
| `networkType` | `ConnectivityManager` | `wifi` ou `mobile` |
| `timezone` | `TimeZone.getDefault().id` | `America/Sao_Paulo` |
| `country` | `Locale.getDefault().country` | `BR` |
| `language` | `Locale.getDefault().language` | `pt` |

### Parâmetros do AppContext

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `userId` | String? | Não | ID único do usuário |
| `apiToken` | String? | Sim | Token de autenticação |
| `packageName` | String? | Sim | Nome do pacote da aplicação |
| `packageVersion` | String? | Não | Versão da aplicação |
| `deviceId` | String? | Não | ID único do dispositivo |
| `deviceModel` | String? | Não | Modelo do dispositivo |
| `osVersion` | String? | Não | Versão do Android |
| `appVersion` | String? | Não | Versão da aplicação |
| `screenResolution` | String? | Não | Resolução da tela (ex: "1080x2400") |
| `networkType` | String? | Não | Tipo de conexão (wifi, 4g, 5g) |
| `timezone` | String? | Não | Fuso horário |
| `country` | String? | Não | Código do país (ISO 3166-1) |
| `language` | String? | Não | Código do idioma (ISO 639-1) |

## Inicialização

### Método 1: Factory Pattern (Recomendado)

```kotlin
import io.goab.sdk.GoABSDKFactory

// Criar e configurar instância
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
    timeoutSeconds = 30
)

// Inicializar
lifecycleScope.launch {
    sdk.initialize()
}
```

### Método 2: Injeção de Dependência

Se você usa Hilt/Dagger na sua aplicação:

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object GoABModule {
    
    @Provides
    @Singleton
    fun provideGoABSDK(
        @ApplicationContext context: Context
    ): GoABSDK {
        return GoABSDKFactory.create(
            context = context,
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
            timeoutSeconds = 30
        )
    }
}
```

## Configurações Avançadas

### Configuração para Desenvolvimento

```kotlin
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
    timeoutSeconds = 10  // Timeout menor para desenvolvimento
)
```

### Configuração para Produção

```kotlin
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
    timeoutSeconds = 30  // Timeout padrão para produção
)
```

### Configuração com Timeout Personalizado

```kotlin
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
    timeoutSeconds = 60  // Timeout maior para redes lentas
)
```

## Verificação de Inicialização

### Verificar Status

```kotlin
if (sdk.isInitialized()) {
    // SDK pronto para uso
    val value = sdk.getValue("key", "default")
} else {
    // SDK ainda não inicializado
    Log.w("GoAB", "SDK não inicializado")
}
```

### Aguardar Inicialização

```kotlin
lifecycleScope.launch {
    // Inicializar
    sdk.initialize()
    
    // Aguardar conclusão
    while (!sdk.isInitialized()) {
        delay(100)
    }
    
    // SDK pronto para uso
    applyExperiments()
}
```

## Tratamento de Erros

### Try-Catch na Inicialização

```kotlin
lifecycleScope.launch {
    try {
        sdk.initialize()
        Log.d("GoAB", "SDK inicializado com sucesso")
    } catch (e: Exception) {
        Log.e("GoAB", "Erro ao inicializar SDK", e)
        // Fallback para valores padrão
        applyDefaultValues()
    }
}
```

### Verificação de Configuração

```kotlin
fun validateSDKParams(accountId: Int, apiToken: String): Boolean {
    return accountId > 0 && apiToken.isNotEmpty()
}

// Usar validação
if (validateSDKParams(12345, "your-api-token")) {
    val sdk = GoABSDKFactory.create(this, 12345, "your-api-token", 30)
    lifecycleScope.launch {
        sdk.initialize()
    }
} else {
    Log.e("GoAB", "Parâmetros inválidos")
}
```

## Exemplo Completo

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupGoABSDK()
    }
    
    private fun setupGoABSDK() {
        // Configuração simplificada - o SDK preenche automaticamente as informações
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
            timeoutSeconds = 30
        )
        
        lifecycleScope.launch {
            try {
                goabSDK.initialize()
                Log.d("GoAB", "SDK inicializado com sucesso")
                applyExperiments()
            } catch (e: Exception) {
                Log.e("GoAB", "Erro ao inicializar SDK", e)
                applyDefaultValues()
            }
        }
    }
    
    private fun applyExperiments() {
        // Aplicar experimentos após inicialização
        val buttonText = goabSDK.getValue("button_text", "Clique Aqui")
        findViewById<Button>(R.id.button).text = buttonText.toString()
    }
    
    private fun applyDefaultValues() {
        // Valores padrão quando SDK não está disponível
        findViewById<Button>(R.id.button).text = "Clique Aqui"
    }
}
```

## Próximos Passos

- [API Reference](../api-reference) - Métodos disponíveis
  - [Casos de Uso](../use-cases) - Exemplos práticos
  - [Troubleshooting](../troubleshooting) - Resolução de problemas
