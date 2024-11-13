
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** Movimentos de Cota Capital

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter o histórico de movimentos de cota capital.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/coopmovtocapital' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Movimentos de Cota Capital

A API permite a obter o histórico de movimentos de cota capital.

#### Parâmetros da Requisição

| Parâmetro  | Tipo     | Obrigatório | Descrição                             |
|------------|----------|-------------|-----------------------------------------|
| cnpjCpf    | string   | Sim         | CPF ou CNPJ do cooperado               |
| dtaInicial | string   | Não         | Data inicial do período                |

---

### 3.2. Resposta da API

A API retorna um JSON com as informações solicitadas.

#### Exemplo de Resposta:

```json
{
  "cnpjCpf": "12345678910",
  "movimentos": [
    {"data": "2024-10-01", "tipo": "Depósito", "valor": 1000.00},
    {"data": "2024-10-15", "tipo": "Retirada", "valor": 200.00}
  ]
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de Movimentos de Cota Capital",
      "endpoint": "/coopmovtocapital",
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

