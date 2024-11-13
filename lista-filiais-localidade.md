
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** LISTA DE FILIAIS

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para retornar uma lista das filiais disponíveis no sistema.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação, e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/filiais' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Estrutura da Resposta

A API retorna um JSON com as informações detalhadas.

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idFilial        | string  | ID da filial                                 |
| nomeFilial      | string  | Nome da filial                               |
| localizacao     | string  | Localização da filial                        |

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta lista de filiais",
      "endpoint": "https://api.cxcorp.com/v1/filiais",
      "request": {},
      "response": | Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idFilial        | string  | ID da filial                                 |
| nomeFilial      | string  | Nome da filial                               |
| localizacao     | string  | Localização da filial                        |
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
