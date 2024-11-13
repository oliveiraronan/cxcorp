
# Documentação do Endpoint AdvPL - TOTVS PROTHEUS
**CASO DE USO:** SALDO DE ESTOQUE DE PRODUTO

## 1. Introdução
Este documento detalha o endpoint desenvolvido em AdvPL para retornar o saldo em estoque de um produto específico. O objetivo é permitir que outros sistemas consumam esses dados por meio de uma integração RESTful com o Protheus.

**Pré-requisitos**: Acesso ao sistema TOTVS Protheus, permissões adequadas para consumir o serviço RESTful e familiaridade com SQL e estrutura de dados no contexto do ERP Protheus.

---

## 2. Definição do Serviço REST

O endpoint é configurado como um serviço RESTful dentro do TOTVS Protheus.

```advpl
WSRESTFUL ebarn_Saldo DESCRIPTION "retornar o saldo em estoque de um produto específico"
```

---

## 3. Parâmetros da Requisição

Este serviço aceita parâmetros conforme descrito abaixo:

| Parâmetro | Tipo    | Obrigatório | Descrição                                      |
|-----------|---------|-------------|------------------------------------------------|
| CnpjCpf   | string  | Opcional    | CPF ou CNPJ utilizado para filtrar os dados    |
| Outros    | string  | Opcional    | Dependendo da implementação, parâmetros como data, ID de categoria podem ser incluídos |

---

## 4. Exemplo de Requisição

```bash
curl -X GET 'https://api.protheus.com.br/v1/ebarn_Saldo?CnpjCpf=12345678910'
```

---

## 5. Estrutura da Resposta

O retorno é em JSON e traz informações detalhadas sobre saldo de estoque de produto:

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| idProd          | string  | ID do produto para consulta de saldo         |
| saldoAtual      | float   | Saldo atual em estoque do produto            |
| unidadeMedida   | string  | Unidade de medida do produto                 |
| dataUltimaAtualizacao | string | Data da última atualização de estoque    |


---

## 6. Lógica Interna do Endpoint

### Função Principal

O endpoint utiliza a função principal definida no AdvPL que executa a consulta SQL e retorna os dados em formato JSON. A função checa se há parâmetros de entrada (como `CnpjCpf`) e ajusta a consulta conforme necessário.

### Exemplo de Consulta SQL

Abaixo está um exemplo da consulta SQL usada para recuperar os dados no TOTVS Protheus:

```advpl
Static function MainFunction( CnpjCpf )
    Local cQRY := GetNextAlias()
    Local aJson := {}
    Local cSqlfilter := ''

    IF !Empty( CnpjCpf )
        cSqlfilter += " AND coluna_cnpjCpf = '" + CnpjCpf + "'"
    EndIF

    BeginSQL Alias cQRY
        SELECT idProd, saldoAtual, unidadeMedida, dataUltimaAtualizacao
                           FROM estoque_produtos
                           WHERE idProd = :idProd AND status = 'A' %exp:cSqlFilter%
    EndSQL
```

### Descrição dos Campos do SQL

Os principais campos da consulta incluem:

| Campo              | Tipo    | Descrição                                                   |
|--------------------|---------|-------------------------------------------------------------|
| coluna_cnpjCpf     | string  | CPF/CNPJ do cliente para filtro opcional                    |
| coluna_nome        | string  | Nome do cliente                                             |
| coluna_valor       | decimal | Valores específicos para cada endpoint, como saldo          |

---

## 7. Tratamento de Erros

| Código | Descrição                                  |
|--------|--------------------------------------------|
| 400    | Requisição mal formatada                   |
| 404    | Registro não encontrado                    |
| 500    | Erro interno ao processar a requisição

---

## 8. FAQs e Troubleshooting

- **Quais informações podem ser retornadas para cada endpoint?**
- **Como formatar corretamente a requisição?**
