---
sidebar_position: 1
---

# GoAB SDK Android

Bem-vindo à documentação do **GoAB SDK Android** - uma biblioteca Android para gerenciamento de experimentos A/B e configurações remotas.

## O que é o GoAB SDK?

O GoAB SDK é uma solução completa para:

- **Experimentos A/B**: Execute testes A/B em tempo real
- **Configurações Remotas**: Gerencie configurações da aplicação sem deploy
- **Analytics**: Colete métricas e eventos dos usuários
- **Segmentação**: Direcione experimentos para usuários específicos

## Características Principais

- ✅ **Fácil Integração**: Setup simples em poucos minutos
- ✅ **Offline First**: Funciona mesmo sem conexão
- ✅ **Clean Architecture**: Código bem estruturado e testável
- ✅ **Type Safety**: Suporte completo ao Kotlin
- ✅ **Performance**: Cache local para acesso rápido
- ✅ **Flexível**: Configuração personalizável

## Início Rápido

```kotlin
// 1. Crie uma instância do SDK
val sdk = GoABSDKFactory.create(context, config)

// 2. Inicialize
lifecycleScope.launch {
    sdk.initialize(config)
}

// 3. Use os valores dos experimentos
val buttonColor = sdk.getValue("button_color", "#FF0000")
```

## Próximos Passos

- [Guia de Início Rápido](./getting-started) - Configure o SDK em 5 minutos
- [Inicialização](./initialization) - Configure parâmetros e contexto
- [API Reference](./api-reference) - Documentação completa da API
- [Casos de Uso](./use-cases) - Exemplos práticos de implementação
