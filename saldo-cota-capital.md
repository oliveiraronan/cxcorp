
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** Saldo de Cota Capital

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para consultar o saldo de cota capital de um cooperado.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/coopcotacapital' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Saldo de Cota Capital

A API permite a consultar o saldo de cota capital de um cooperado.

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
  "saldoCotaCapital": 5000.00,
  "dataUltimaAtualizacao": "2024-11-10"
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de Saldo de Cota Capital",
      "endpoint": "/coopcotacapital",
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

