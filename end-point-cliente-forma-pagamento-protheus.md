
# Documentação do Endpoint AdvPL - TOTVS PROTHEUS
**CASO DE USO:** CLIENTES FORMA DE PAGAMENTO NO TOTVS PROTHEUS

## 1. Introdução
Este documento explica o endpoint desenvolvido em AdvPL para consulta de filiais e formas de pagamento associadas a um cliente no TOTVS Protheus. O serviço permite que outros sistemas integrem-se para obter essas informações.

**Pré-requisitos**: Acesso ao sistema TOTVS Protheus e permissão para consumir o serviço RESTful.

---

## 2. Definição do Serviço REST

O endpoint é configurado como um serviço RESTful dentro do TOTVS Protheus.

```advpl
WSRESTFUL ebarn_ClientesFormaPagto DESCRIPTION "Serviço REST para retorno das filiais do sistema"
```

---

## 3. Parâmetros da Requisição

O serviço aceita o parâmetro `CnpjCpf`, que permite filtrar a busca pelo CPF ou CNPJ do cliente.

### Parâmetros

| Parâmetro  | Tipo     | Obrigatório | Descrição                    |
|------------|----------|-------------|------------------------------|
| CnpjCpf    | string   | Não         | CPF ou CNPJ do cliente       |

---

## 4. Exemplo de Requisição

Uma requisição para este serviço é feita via método `GET`, passando o `CnpjCpf` como parâmetro de consulta.

```bash
curl -X GET 'https://api.protheus.com.br/v1/ebarn_ClientesFormaPagto?CnpjCpf=12345678910'
```

---

## 5. Estrutura da Resposta

A resposta é retornada em JSON e inclui informações detalhadas sobre as filiais e formas de pagamento associadas ao cliente.

| Parâmetro            | Tipo   | Descrição                                  |
|----------------------|--------|--------------------------------------------|
| CnpjCpf              | string | CPF ou CNPJ do cliente                     |
| nome                 | string | Nome do cliente                            |
| filial               | string | Filial associada ao cliente                |
| formaPagamento       | string | Forma de pagamento cadastrada              |
| dataUltimaAtualizacao| string | Data da última atualização das informações |

### Exemplo de Resposta:

```json
{
  "CnpjCpf": "12345678910",
  "nome": "Maria de Souza",
  "filial": "Filial 1",
  "formaPagamento": "Crédito",
  "dataUltimaAtualizacao": "2024-11-10"
}
```

---

## 6. Descrição da Lógica do Serviço

### Passo 1: Validação do Parâmetro
O parâmetro `CnpjCpf` é opcional, mas, se fornecido, filtra a consulta de dados.

```advpl
IF Empty( Self:CnpjCpf )
    Self:CnpjCpf := ''
ENDIF
```

### Passo 2: Chamada à Função Auxiliar `fCliFPagto`
O serviço chama a função `fCliFPagto`, que realiza a consulta no banco de dados para obter as informações das filiais e formas de pagamento do cliente.

```advpl
cXmlEnv := fCliFPagto( Self:CnpjCpf )
```

### Passo 3: Formatação da Resposta em JSON
Os dados obtidos são convertidos em JSON e enviados como resposta.

```advpl
oResponse := JsonObject():New()
oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )
```

---

## 7. Função Auxiliar `fCliFPagto`

A função `fCliFPagto` realiza a consulta SQL no banco de dados para obter as informações das filiais e formas de pagamento do cliente com base no CPF ou CNPJ fornecido.

### Estrutura da Query SQL

A consulta SQL filtra pelo CPF/CNPJ (se fornecido) e busca dados como filial e formas de pagamento.

```advpl
Static function fCliFPagto( CnpjCpf )
    Local cQRYSA1 := GetNextAlias()
    Local aJson := {}
    Local cSqlfilter := ''

    IF !Empty( CnpjCpf )
        cSqlfilter += " AND SA1.A1_CGC = '" + CnpjCpf + "'"
    EndIF

    BeginSQL Alias cQRYSA1
        SELECT DISTINCT A1_FILIAL, A1_COD, A1_CGC, A1_NOME, ...
        WHERE SA1.D_E_L_E_T_ = ' ' %exp:cSqlFilter%
```

---

## 8. Tratamento de Erros

| Código | Descrição                                  |
|--------|--------------------------------------------|
| 400    | Requisição mal formatada                   |
| 404    | Cliente não encontrado                     |
| 500    | Erro interno ao processar a requisição     |

---

## 9. FAQs e Troubleshooting

- **Como fornecer o parâmetro CnpjCpf?**
- **O que fazer em caso de erro 404?**
