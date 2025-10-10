---
sidebar_position: 6
---

# Troubleshooting

Resolução de problemas comuns ao usar o GoAB SDK.

## Problemas de Inicialização

### SDK não inicializa

**Sintomas:**
- `isInitialized()` retorna false
- Valores padrão são sempre retornados
- Logs mostram erro de inicialização

**Possíveis Causas:**
1. Configuração inválida
2. Problemas de rede
3. Token de API inválido
4. Contexto Android inválido

**Soluções:**

```kotlin
// 1. Verificar configuração
fun validateSDKParams(accountId: Int, apiToken: String): Boolean {
    return accountId > 0 && apiToken.isNotEmpty()
}

// 2. Inicializar com tratamento de erro
lifecycleScope.launch {
    try {
        if (validateSDKParams(2, "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8")) {
            sdk.initialize()
        } else {
            Log.e("GoAB", "Configuração inválida")
        }
    } catch (e: Exception) {
        Log.e("GoAB", "Erro ao inicializar", e)
        // Usar valores padrão
    }
}
```

### Timeout na inicialização

**Sintomas:**
- SDK demora para inicializar
- Logs mostram timeout
- Aplicação fica lenta

**Soluções:**

```kotlin
// 1. Aumentar timeout
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
    timeoutSeconds = 60 // Aumentar timeout
)

// 2. Inicializar em background
lifecycleScope.launch(Dispatchers.IO) {
    sdk.initialize()
}
```

## Problemas de Rede

### Falha ao buscar experimentos

**Sintomas:**
- Valores padrão são sempre retornados
- Logs mostram erro de rede
- Experimentos não são atualizados

**Possíveis Causas:**
1. Sem conexão com internet
2. URL da API incorreta
3. Token de API inválido
4. Firewall bloqueando requisições

**Soluções:**

```kotlin
// 1. Verificar conectividade
fun isNetworkAvailable(context: Context): Boolean {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val network = connectivityManager.activeNetwork
    val capabilities = connectivityManager.getNetworkCapabilities(network)
    return capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true
}

// 2. Configurar SDK corretamente
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8", // Verificar token
    timeoutSeconds = 30
)

// 3. Tratar falhas de rede
lifecycleScope.launch {
    try {
        sdk.initialize()
    } catch (e: Exception) {
        if (e is UnknownHostException || e is ConnectException) {
            Log.w("GoAB", "Problema de rede, usando cache local")
            // Usar valores do cache local
        } else {
            Log.e("GoAB", "Erro inesperado", e)
        }
    }
}
```

### Experimentos não são atualizados

**Sintomas:**
- Valores antigos são retornados
- Mudanças no servidor não refletem na app
- `refreshExperiments()` não funciona

**Soluções:**

```kotlin
// 1. Forçar atualização
sdk.refreshExperiments()

// 2. Limpar experimentos ativos e recarregar
lifecycleScope.launch {
    sdk.clearActiveUsers()
    sdk.refreshExperiments()
}

// 3. Verificar se está inicializado
if (sdk.isInitialized()) {
    sdk.refreshExperiments()
} else {
    Log.w("GoAB", "SDK não inicializado")
}
```

## Problemas de Valores

### Valores incorretos retornados

**Sintomas:**
- Tipos incorretos (String em vez de Boolean)
- Valores inesperados
- Conversão de tipos falha

**Soluções:**

```kotlin
// 1. Verificar tipo do valor
    fun getValueSafely(key: String, defaultValue: Any): Any {
        val value = sdk.getValue(key, defaultValue)
        
        // Log para debug
        Log.d("GoAB", "Valor para $key: $value (tipo: ${value.javaClass.simpleName})")
        
        return value
    }

// 2. Converter tipos explicitamente
fun getBooleanValue(key: String, defaultValue: Boolean): Boolean {
    val value = sdk.getValue(key, defaultValue)
    return when (value) {
        is Boolean -> value
        is String -> value.toBooleanStrictOrNull() ?: defaultValue
        else -> defaultValue
    }
}

// 3. Usar valores padrão seguros
val buttonText = sdk.getValue("button_text", "Clique Aqui") as String
```

### Valores padrão sempre retornados

**Sintomas:**
- Experimentos não funcionam
- Valores padrão são sempre usados
- Mudanças no servidor não refletem

**Possíveis Causas:**
1. SDK não inicializado
2. Chave do experimento incorreta
3. Usuário não está no experimento
4. Problemas de rede

**Soluções:**

```kotlin
// 1. Verificar inicialização
if (!sdk.isInitialized()) {
    Log.w("GoAB", "SDK não inicializado")
    return
}

// 2. Verificar chave do experimento
val value = sdk.getValue("button_color", "#FF0000")
Log.d("GoAB", "Valor obtido: $value")

// 3. Aguardar inicialização
lifecycleScope.launch {
    sdk.initialize()
    
    // Aguardar um pouco para garantir que os experimentos foram carregados
    delay(1000)
    
    val value = sdk.getValue("button_color", "#FF0000")
    Log.d("GoAB", "Valor após inicialização: $value")
}
```

## Problemas de Performance

### SDK lento

**Sintomas:**
- Aplicação fica lenta
- UI trava durante inicialização
- Timeout em operações

**Soluções:**

```kotlin
// 1. Inicializar em background
lifecycleScope.launch(Dispatchers.IO) {
    sdk.initialize()
}

// 2. Usar cache local
// O SDK já usa cache local, mas você pode forçar o uso
val value = sdk.getValue("key", "default") // Usa cache se disponível

// 3. Configurar timeout menor
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 2,
    apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
    timeoutSeconds = 10 // Timeout menor
)
```

### Memória alta

**Sintomas:**
- Aplicação consome muita memória
- OutOfMemoryError
- Performance degradada

**Soluções:**

```kotlin
// 1. Limpar experimentos ativos periodicamente
lifecycleScope.launch {
    // Limpar experimentos ativos a cada 24 horas
    delay(24 * 60 * 60 * 1000)
    sdk.clearActiveUsers()
}

// 2. Usar valores padrão quando possível
val value = sdk.getValue("key", "default")
if (value == "default") {
    // Usar valor padrão sem fazer mais requisições
}
```

## Problemas de Usuário

### Mudança de usuário não funciona

**Sintomas:**
- `setUserId()` não atualiza experimentos
- Valores antigos são mantidos
- Usuário não muda

**Soluções:**

```kotlin
// 1. Verificar se SDK está inicializado
if (!sdk.isInitialized()) {
    Log.w("GoAB", "SDK não inicializado")
    return
}

// 2. Aguardar atualização
lifecycleScope.launch {
    sdk.setUserId("new_user_id")
    
    // Aguardar um pouco para garantir que os experimentos foram recarregados
    delay(1000)
    
    // Verificar se o usuário mudou
    val currentUserId = sdk.getCurrentUserId()
    Log.d("GoAB", "Usuário atual: $currentUserId")
}

// 3. Limpar experimentos ativos se necessário
lifecycleScope.launch {
    sdk.clearActiveUsers()
    sdk.setUserId("new_user_id")
}
```

### Usuário não é persistido

**Sintomas:**
- Usuário é perdido ao reiniciar app
- `getCurrentUserId()` retorna null
- Experimentos não são carregados

**Soluções:**

```kotlin
// 1. Verificar se o usuário está sendo salvo
lifecycleScope.launch {
    sdk.setUserId("user123")
    
    // Verificar se foi salvo
    val savedUserId = sdk.getUserId()
    Log.d("GoAB", "Usuário salvo: $savedUserId")
}

// 2. Configurar usuário na inicialização
val config = GoABConfig(
    baseUrl = "https://api.goab.com",
    accountId = 12345,
    appContext = GoABConfig.AppContext(
        userId = "user123" // Definir usuário na configuração
    )
)
```

## Logs e Debug

### Habilitar logs detalhados

```kotlin
val config = GoABConfig(
    baseUrl = "https://api.goab.com",
    accountId = 12345,
    enableLogging = true, // Habilitar logs
    appContext = appContext
)
```

### Verificar logs

```kotlin
// Filtrar logs do GoAB
adb logcat | grep "GoAB"
```

### Debug de valores

```kotlin
suspend fun debugExperimentValues() {
    val keys = listOf("button_color", "show_banner", "max_retries")
    
    keys.forEach { key ->
        val value = sdk.getValue(key, null)
        Log.d("GoAB", "Chave: $key, Valor: $value, Tipo: ${value?.javaClass?.simpleName}")
    }
}
```

## Contato e Suporte

Se você ainda está enfrentando problemas:

1. Verifique os logs do Android
2. Teste com uma configuração mínima
3. Verifique a conectividade de rede
4. Entre em contato com o suporte técnico

## Exemplo de Configuração de Debug

```kotlin
class DebugGoABManager {
    private val sdk: GoABSDK
    
    constructor(context: Context) {
        sdk = GoABSDKFactory.create(
            context = context,
            accountId = 2,
            apiToken = "app_bf8f8ffe8c9e8b5877a0028f67750633e18d293ed760454af88a66543a3f90f8",
            timeoutSeconds = 60
        )
    }
    
    suspend fun initializeWithDebug() {
        try {
            Log.d("DebugGoAB", "Iniciando inicialização...")
            sdk.initialize()
            
            // Aguardar inicialização
            while (!sdk.isInitialized()) {
                delay(100)
            }
            
            Log.d("DebugGoAB", "SDK inicializado com sucesso")
            
            // Testar valores
            testExperimentValues()
            
        } catch (e: Exception) {
            Log.e("DebugGoAB", "Erro na inicialização", e)
        }
    }
    
    private suspend fun testExperimentValues() {
        val testKeys = listOf("test_key_1", "test_key_2", "test_key_3")
        
        testKeys.forEach { key ->
            val value = sdk.getValue(key, "default_value")
            Log.d("DebugGoAB", "Teste - Chave: $key, Valor: $value")
        }
    }
}
```
