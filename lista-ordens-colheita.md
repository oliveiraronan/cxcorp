
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** LISTA XML DE ORDENS DE COLHEITA

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter uma lista em XML das ordens de colheita.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação, e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/ordens/colheita_xml' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Estrutura da Resposta

A API retorna um JSON com as informações detalhadas.

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| dDtxmlEmis      | string  | Data de emissão do XML                       |
| OffSET          | int     | Posição inicial dos resultados               |
| PageSize        | int     | Quantidade de registros por página           |
| ordemColheitaId | string  | ID da ordem de colheita                      |
| descricao       | string  | Descrição da ordem de colheita               |


---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta lista xml de ordens de colheita",
      "endpoint": "https://api.cxcorp.com/v1/ordens/colheita_xml",
      "request": {},
      "response": | Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| dDtxmlEmis      | string  | Data de emissão do XML                       |
| OffSET          | int     | Posição inicial dos resultados               |
| PageSize        | int     | Quantidade de registros por página           |
| ordemColheitaId | string  | ID da ordem de colheita                      |
| descricao       | string  | Descrição da ordem de colheita               |

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
