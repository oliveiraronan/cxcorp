
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** SALDO DE ESTOQUE DE PRODUTO

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para retornar o saldo em estoque de um produto específico.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação, e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/produtos/saldo_estoque?idProd=PROD123' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Estrutura da Resposta

A API retorna um JSON com as informações detalhadas.

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idProd          | string  | ID do produto para consulta de saldo         |
| saldoAtual      | float   | Saldo atual em estoque do produto            |
| unidadeMedida   | string  | Unidade de medida do produto                 |
| dataUltimaAtualizacao | string | Data da última atualização de estoque    |


---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta saldo de estoque de produto",
      "endpoint": "https://api.cxcorp.com/v1/produtos/saldo_estoque?idProd=PROD123",
      "request": {},
      "response": | Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idProd          | string  | ID do produto para consulta de saldo         |
| saldoAtual      | float   | Saldo atual em estoque do produto            |
| unidadeMedida   | string  | Unidade de medida do produto                 |
| dataUltimaAtualizacao | string | Data da última atualização de estoque    |

    }
  ]
}
```

---

## 5. Tratamento de Erros

| Código | Descrição                                  |
|--------|--------------------------------------------|
| 400    | Requisição mal formatada                   |
| 401    | Falha de autenticação                      |
| 404    | Registro não encontrado                    |

---
