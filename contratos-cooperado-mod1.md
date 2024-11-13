
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** Contratos de Depósito de Terceiros

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para listar os contratos de depósito de terceiros.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/cooppostrcterdept' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Contratos de Depósito de Terceiros

A API permite a listar os contratos de depósito de terceiros.

#### Parâmetros da Requisição

| Parâmetro  | Tipo     | Obrigatório | Descrição                             |
|------------|----------|-------------|-----------------------------------------|
| cnpjCpf    | string   | Sim         | CPF ou CNPJ do cooperado               |
| inscricao  | string   | Não         | Inscrição do cooperado                 |

---

### 3.2. Resposta da API

A API retorna um JSON com as informações solicitadas.

#### Exemplo de Resposta:

```json
{
  "cnpjCpf": "12345678910",
  "contratos": [
    {"contratoId": "C001", "descricao": "Contrato 1", "valor": 5000.00},
    {"contratoId": "C002", "descricao": "Contrato 2", "valor": 2500.00}
  ]
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de Contratos de Depósito de Terceiros",
      "endpoint": "/cooppostrcterdept",
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

