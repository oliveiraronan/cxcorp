
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** PRAZOS OU CONDIÇÕES DE PAGAMENTO

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter a lista de condições de pagamento disponíveis no sistema.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/condicoes_pagto' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Condições de Pagamento

A API permite a consulta das condições de pagamento disponíveis no sistema.

#### Exemplo de Requisição:

```bash
curl -X GET 'https://api.cxcorp.com/v1/condicoes_pagto' \
-H 'Authorization: Bearer {api_key}'
```

---

### 3.2. Resposta da API

A API retorna um JSON com a lista de condições de pagamento disponíveis.

#### Estrutura da Resposta

| Parâmetro            | Tipo   | Descrição                              |
|----------------------|--------|----------------------------------------|
| condicaoPagamentoId  | string | ID da condição de pagamento            |
| descricao            | string | Descrição da condição de pagamento     |
| prazo                | string | Prazo de pagamento associado           |
| dataUltimaAtualizacao| string | Data da última atualização das informações |

#### Exemplo de Resposta:

```json
{
  "condicaoPagamentoId": "CP123",
  "descricao": "Parcelado em 3x",
  "prazo": "30/60/90 dias",
  "dataUltimaAtualizacao": "2024-11-10"
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de condições de pagamento",
      "endpoint": "/condicoes_pagto",
      "request": {},
      "response": {
        "condicaoPagamentoId": "CP123",
        "descricao": "Parcelado em 3x",
        "prazo": "30/60/90 dias",
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

#### Exemplo de Erro:

```json
{
  "error": {
    "code": "invalid_request_error",
    "message": "A requisição não possui os parâmetros corretos."
  }
}
```

---

## 6. FAQs e Troubleshooting

- **Como obtenho as credenciais de API?**
