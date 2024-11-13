
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** ROMANEIOS DE CONTRATOS AGROINDUSTRIAIS

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para retornar os romaneios associados aos contratos agroindustriais.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação, e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/contratos/romaneios' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Estrutura da Resposta

A API retorna um JSON com as informações detalhadas.

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idContrato      | string  | ID do contrato                               |
| filial          | string  | Filial associada ao contrato                 |
| dataRomaneio    | string  | Data do romaneio                             |

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta romaneios de contratos agroindustriais",
      "endpoint": "https://api.cxcorp.com/v1/contratos/romaneios",
      "request": {},
      "response": | Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idContrato      | string  | ID do contrato                               |
| filial          | string  | Filial associada ao contrato                 |
| dataRomaneio    | string  | Data do romaneio                             |
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
