
# Documentação do Endpoint AdvPL - TOTVS PROTHEUS
**CASO DE USO:** LISTA XML DE ORDENS DE COLHEITA

## 1. Introdução
Este documento detalha o endpoint desenvolvido em AdvPL para retornar uma lista em XML das ordens de colheita. O objetivo é permitir que outros sistemas consumam esses dados por meio de uma integração RESTful com o Protheus.

**Pré-requisitos**: Acesso ao sistema TOTVS Protheus, permissões adequadas para consumir o serviço RESTful e familiaridade com SQL e estrutura de dados no contexto do ERP Protheus.

---

## 2. Definição do Serviço REST

O endpoint é configurado como um serviço RESTful dentro do TOTVS Protheus.

```advpl
WSRESTFUL TmplSem_OrdemColheita DESCRIPTION "retornar uma lista em XML das ordens de colheita"
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
curl -X GET 'https://api.protheus.com.br/v1/TmplSem_OrdemColheita?CnpjCpf=12345678910'
```

---

## 5. Estrutura da Resposta

O retorno é em JSON e traz informações detalhadas sobre lista xml de ordens de colheita:

| Parâmetro       | Tipo    | Descrição                                    |
|-----------------|---------|----------------------------------------------|
| dDtxmlEmis      | string  | Data de emissão do XML                       |
| OffSET          | int     | Posição inicial dos resultados               |
| PageSize        | int     | Quantidade de registros por página           |
| ordemColheitaId | string  | ID da ordem de colheita                      |
| descricao       | string  | Descrição da ordem de colheita               |


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
        SELECT dDtxmlEmis, OffSET, PageSize, ordemColheitaId, descricao
                           FROM ordens_colheita
                           WHERE status = 'A' %exp:cSqlFilter%
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
