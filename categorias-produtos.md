
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** Categorias de Produtos

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter a lista de categorias de produtos e seus produtos.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/coopcadgrp' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: Solicitação de Categorias de Produtos

A API permite a obter a lista de categorias de produtos e seus produtos.

#### Parâmetros da Requisição

| Parâmetro  | Tipo     | Obrigatório | Descrição                             |
|------------|----------|-------------|-----------------------------------------|
| CGRUPO     | string   | Não         | Código inicial do grupo de produtos    |
| CGRPFIM    | string   | Não         | Código final do grupo de produtos      |

---

### 3.2. Resposta da API

A API retorna um JSON com as informações solicitadas.

#### Exemplo de Resposta:

```json
{
  "CGRUPO": "001",
  "NomeGrupo": "Grupo 1",
  "Produtos": [
    {"ProdutoID": "P001", "Nome": "Produto A"},
    {"ProdutoID": "P002", "Nome": "Produto B"}
  ]
}
```

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta de Categorias de Produtos",
      "endpoint": "/coopcadgrp",
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

