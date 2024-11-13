
# Documentação do Endpoint AdvPL - TOTVS PROTHEUS
**CASO DE USO:** LISTA DE COOPERADOS NO TOTVS PROTHEUS

## 1. Introdução
Este documento explica o endpoint desenvolvido em AdvPL para consulta de cooperados no TOTVS Protheus, permitindo que outros sistemas integrem-se para obter informações como o saldo de cota capital do cooperado.

**Pré-requisitos**: Acesso ao sistema TOTVS Protheus e permissão para consumir o serviço RESTful.

---

## 2. Definição do Serviço REST

O endpoint é configurado como um serviço RESTful dentro do TOTVS Protheus.

```advpl
WSRESTFUL ebarn_cooperados DESCRIPTION "Serviço REST para retorno dos clientes cooperados"
```

---

## 3. Parâmetros da Requisição

O serviço aceita o parâmetro `CnpjCpf`, que permite filtrar a busca pelo CPF ou CNPJ do cooperado.

### Parâmetros

| Parâmetro  | Tipo     | Obrigatório | Descrição                    |
|------------|----------|-------------|------------------------------|
| CnpjCpf    | string   | Não         | CPF ou CNPJ do cooperado     |

---

## 4. Exemplo de Requisição

Uma requisição para este serviço é feita via método `GET`, passando o `CnpjCpf` como parâmetro de consulta.

```bash
curl -X GET 'https://api.protheus.com.br/v1/ebarn_cooperados?CnpjCpf=12345678910'
```

---

## 5. Estrutura da Resposta

A resposta é retornada em JSON e inclui informações detalhadas sobre o cooperado.

| Parâmetro            | Tipo   | Descrição                                  |
|----------------------|--------|--------------------------------------------|
| CnpjCpf              | string | CPF ou CNPJ do cooperado                   |
| nome                 | string | Nome do cooperado                          |
| saldoCotaCapital     | float  | Saldo da cota capital do cooperado         |
| dataUltimaAtualizacao| string | Data da última atualização do saldo        |

### Exemplo de Resposta:

```json
{
  "CnpjCpf": "12345678910",
  "nome": "João da Silva",
  "saldoCotaCapital": 1500.50,
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

### Passo 2: Chamada à Função Auxiliar `fCooperado`
O serviço chama a função `fCooperado`, que realiza a consulta no banco de dados para obter as informações dos cooperados.

```advpl
cXmlEnv := fCooperado( Self:CnpjCpf )
```

### Passo 3: Formatação da Resposta em JSON
Os dados obtidos são convertidos em JSON e enviados como resposta.

```advpl
oResponse := JsonObject():New()
oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )
```

---

## 7. Função Auxiliar `fCooperado`

A função `fCooperado` realiza a consulta SQL no banco de dados para obter as informações do cooperado com base no CPF ou CNPJ fornecido.

### Estrutura da Query SQL

A consulta SQL filtra pelo CPF/CNPJ (se fornecido) e busca dados como nome, endereço e saldo.
ATENÇÃO: No exemplo abaixo, o campo A1_XMATCOO é utilizado para identificar os registros da tabela clientes, flagados como cooperados.

```advpl
Static function fCooperado( CnpjCpf )
    Local cQRYSA1 := GetNextAlias()
    Local aJson := {}
    Local cSqlfilter := ''

    IF !Empty( CnpjCpf )
        cSqlfilter += " AND SA1.A1_CGC = '" + CnpjCpf + "'"
    EndIF

    BeginSQL Alias cQRYSA1
        SELECT DISTINCT A1_XMATCOO, A1_FILIAL, ...
        WHERE SA1.D_E_L_E_T_ = ' ' %exp:cSqlFilter%
```

---

## 8. Tratamento de Erros

| Código | Descrição                                  |
|--------|--------------------------------------------|
| 400    | Requisição mal formatada                   |
| 404    | Cooperado não encontrado                   |
| 500    | Erro interno ao processar a requisição     |

---

## 9. FAQs e Troubleshooting

- **Como fornecer o parâmetro CnpjCpf?**
- **O que fazer em caso de erro 404?**
