
# Documentação do Endpoint AdvPL - TOTVS PROTHEUS
**CASO DE USO:** CONDIÇÕES DE PAGAMENTO NO TOTVS PROTHEUS

## 1. Introdução
Este documento explica o endpoint desenvolvido em AdvPL para consulta de condições de pagamento no TOTVS Protheus, permitindo que outros sistemas integrem-se para obter essa lista de informações.

**Pré-requisitos**: Acesso ao sistema TOTVS Protheus e permissão para consumir o serviço RESTful.

---

## 2. Definição do Serviço REST

O endpoint é configurado como um serviço RESTful dentro do TOTVS Protheus.

```advpl
WSRESTFUL ebarn_CondPagto DESCRIPTION "Serviço REST para retorno das condições de pagamento"
```

---

## 3. Parâmetros da Requisição

Este serviço não requer parâmetros adicionais para listar as condições de pagamento.

---

## 4. Exemplo de Requisição

Uma requisição para este serviço é feita via método `GET`.

```bash
curl -X GET 'https://api.protheus.com.br/v1/ebarn_CondPagto'
```

---

## 5. Estrutura da Resposta

A resposta é retornada em JSON e inclui informações detalhadas sobre as condições de pagamento.

| Parâmetro            | Tipo   | Descrição                              |
|----------------------|--------|----------------------------------------|
| condicaoPagamentoId  | string | ID da condição de pagamento            |
| descricao            | string | Descrição da condição de pagamento     |
| prazo                | string | Prazo de pagamento associado           |
| dataUltimaAtualizacao| string | Data da última atualização das informações |

### Exemplo de Resposta:

```json
{
  "condicaoPagamentoId": "CP123",
  "descricao": "Parcelado em 3x",
  "prazo": "30/60/90 dias",
  "dataUltimaAtualizacao": "2024-11-10"
}
```

---

## 6. Descrição da Lógica do Serviço

### Passo 1: Chamada à Função Auxiliar `fCondPgto`
O serviço chama a função `fCondPgto`, que realiza a consulta no banco de dados para obter as informações das condições de pagamento.

```advpl
cXmlEnv := fCondPgto()
```

### Passo 2: Formatação da Resposta em JSON
Os dados obtidos são convertidos em JSON e enviados como resposta.

```advpl
oResponse := JsonObject():New()
oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )
```

---

## 7. Função Auxiliar `fCondPgto`

A função `fCondPgto` realiza a consulta SQL no banco de dados para obter as informações das condições de pagamento.

### Estrutura da Query SQL

A consulta SQL busca todos os dados relacionados às condições de pagamento na tabela `%table:SE4%`.

```advpl
Static function fCondPgto()
    Local cQRYSE4 := GetNextAlias()
    Local aJson := {}

    BeginSQL Alias cQRYSE4
        SELECT * FROM %table:SE4% SE4
```

---

## 8. Tratamento de Erros

| Código | Descrição                                  |
|--------|--------------------------------------------|
| 400    | Requisição mal formatada                   |
| 500    | Erro interno ao processar a requisição     |

---

## 9. FAQs e Troubleshooting

- **Quais informações são retornadas para as condições de pagamento?**
