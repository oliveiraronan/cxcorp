
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** Limite de Crédito

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter o limite de crédito do cooperado.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/cooplimitecredito' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Limite de Crédito

A API permite a obter o limite de crédito do cooperado.

#### Parâmetros da Requisição

| Parâmetro  | Tipo     | Obrigatório | Descrição                             |
|------------|----------|-------------|-----------------------------------------|
| cnpjCpf    | string   | Sim         | CPF ou CNPJ do cooperado               |

---

### 3.2. Resposta da API

A API retorna um JSON com as informações solicitadas.

#### Exemplo de Resposta:

```json
{
  "cnpjCpf": "12345678910",
  "limiteCredito": 15000.00,
  "saldoUtilizado": 3000.00,
  "dataUltimaAtualizacao": "2024-11-10"
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de Limite de Crédito",
      "endpoint": "/cooplimitecredito",
      "request": {}
    }
  ]
}
```

---

## 5. Tratamento de Erros

Descrição de possíveis erros:

- **400**: Requisição mal formatada.
- **401**: Falha de autenticação.

