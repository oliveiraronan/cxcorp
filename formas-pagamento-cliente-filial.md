
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** FORMAS DE PAGAMENTO POR CLIENTE E FILIAL OU UNIDADE DE NEGÓCIO

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter as filiais e formas de pagamento associadas a um cliente específico.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/clientesforma_pagto' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Filiais e Formas de Pagamento do Cliente

A API permite a consulta das filiais e formas de pagamento associadas a um cliente utilizando o CPF ou CNPJ como parâmetro de pesquisa.

#### Parâmetros da Requisição

| Parâmetro  | Tipo     | Obrigatório | Descrição                    |
|------------|----------|-------------|------------------------------|
| CnpjCpf    | string   | Não         | CPF ou CNPJ do cliente       |

#### Exemplo de Requisição:

```bash
curl -X GET 'https://api.cxcorp.com/v1/clientesforma_pagto?CnpjCpf=12345678910' \
-H 'Authorization: Bearer {api_key}'
```

---

### 3.2. Resposta da API

A API retorna um JSON com as informações das filiais e formas de pagamento associadas ao cliente.

#### Estrutura da Resposta

| Parâmetro            | Tipo   | Descrição                                  |
|----------------------|--------|--------------------------------------------|
| CnpjCpf              | string | CPF ou CNPJ do cliente                     |
| nome                 | string | Nome do cliente                            |
| filial               | string | Filial associada ao cliente                |
| formaPagamento       | string | Forma de pagamento cadastrada              |
| dataUltimaAtualizacao| string | Data da última atualização das informações |

#### Exemplo de Resposta:

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

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de filiais e formas de pagamento do cliente",
      "endpoint": "/clientesforma_pagto",
      "request": {
        "CnpjCpf": "12345678910"
      },
      "response": {
        "CnpjCpf": "12345678910",
        "nome": "Maria de Souza",
        "filial": "Filial 1",
        "formaPagamento": "Crédito",
        "dataUltimaAtualizacao": "2024-11-10"
      }
    }
  ]
}
```

---

## 5. Tratamento de Erros

Descrição de possíveis erros:

- **400**: Requisição mal formatada.
- **401**: Falha de autenticação.
- **404**: Cliente não encontrado.

#### Exemplo de Erro:

```json
{
  "error": {
    "code": "invalid_request_error",
    "message": "O campo 'CnpjCpf' é obrigatório."
  }
}
```

---

## 6. FAQs e Troubleshooting

- **Como obtenho as credenciais de API?**
- **O que fazer em caso de erro 404 ao buscar o cliente?**
