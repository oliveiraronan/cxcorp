
# Documentação de Integração da Plataforma CX CORP
**CASO DE USO:** POSIÇÃO FINANCEIRA DE CONTAS A PAGAR

## 1. Introdução
Esta documentação detalha a integração entre a plataforma CX CORP e o sistema ERP para obter a posição financeira das contas a pagar para o cooperado.

**Pré-requisitos**: Acesso à API da CX CORP, credenciais de autenticação, e conhecimento básico de APIs RESTful.

---

## 2. Autenticação

Para acessar a API, é necessário o uso de uma chave de autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/contas/posicao_pagar' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Estrutura da Resposta

A API retorna um JSON com as informações detalhadas.

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| cnpjCpf         | string  | CPF ou CNPJ do cooperado                     |
| saldoCredor     | float   | Saldo total credor                           |
| dataUltimaAtualizacao | string | Data da última atualização               |

---

## 4. Exemplo de Fluxo de Integração

```json
{
  "flow": [
    {
      "action": "Consulta posição financeira de contas a pagar",
      "endpoint": "https://api.cxcorp.com/v1/contas/posicao_pagar",
      "request": {},
      "response": | Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| cnpjCpf         | string  | CPF ou CNPJ do cooperado                     |
| saldoCredor     | float   | Saldo total credor                           |
| dataUltimaAtualizacao | string | Data da última atualização               |
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
