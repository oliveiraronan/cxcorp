
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** LISTA DE COOPERADOS

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter a lista de cooperados e informações associadas ao saldo de cota capital.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/cooperados' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Lista de Cooperados

A API permite a consulta de cooperados utilizando o CPF ou CNPJ como parâmetro de pesquisa.

#### Parâmetros da Requisição

| Parâmetro  | Tipo     | Obrigatório | Descrição                    |
|------------|----------|-------------|------------------------------|
| CnpjCpf    | string   | Não         | CPF ou CNPJ do cooperado     |

#### Exemplo de Requisição:

```bash
curl -X GET 'https://api.cxcorp.com/v1/cooperados?CnpjCpf=12345678910' \
-H 'Authorization: Bearer {api_key}'
```

---

### 3.2. Resposta da API

A API retorna um JSON com as informações de cota capital e outros dados pertinentes ao cooperado.

#### Estrutura da Resposta

| Parâmetro            | Tipo   | Descrição                                  |
|----------------------|--------|--------------------------------------------|
| CnpjCpf              | string | CPF ou CNPJ do cooperado                   |
| nome                 | string | Nome do cooperado                          |
| saldoCotaCapital     | float  | Saldo da cota capital do cooperado         |
| dataUltimaAtualizacao| string | Data da última atualização do saldo        |

#### Exemplo de Resposta:

```json
{
  "CnpjCpf": "12345678910",
  "nome": "João da Silva",
  "saldoCotaCapital": 1500.50,
  "dataUltimaAtualizacao": "2024-11-10"
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta lista de cooperados",
      "endpoint": "/cooperados",
      "request": {
        "CnpjCpf": "12345678910"
      },
      "response": {
        "CnpjCpf": "12345678910",
        "nome": "João da Silva",
        "saldoCotaCapital": 1500.50,
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
- **404**: Cooperado não encontrado.

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
- **O que fazer em caso de erro 404 ao buscar cooperado?**
