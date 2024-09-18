
# Documentação de Integração da Plataforma CX CORP

## 1. Introdução
Esta documentação cobre a integração entre o sistema CX CORP e o ERP do cliente para o envio e processamento de indicações e conversões, relacionadas ao programa de pontos e recompensas da Irmãos Soares.

**Pré-requisitos**: Necessidade de acesso à API da CX CORP, credenciais de autenticação, e conhecimento básico de APIs REST.

---

## 2. Autenticação

Como obter as credenciais necessárias para autenticação.

### Autenticação via API Key

```bash
curl -X GET 'https://api.cxcorp.com/v1/referrals' \
-H 'Authorization: Bearer {api_key}'
```

---

## 3. Processo de Integração

### 3.1. Passo 1: CX CORP Envia Indicações ao ERP

O CX CORP envia as indicações ao ERP, que processará a regra de negócio para determinar o status da indicação (aprovado ou recusado), bem como o valor a ser creditado ou debitado, seja em pontos ou em moeda.

#### Parâmetros da Requisição

| Parâmetro      | Tipo   | Obrigatório | Descrição                                            |
|----------------|--------|-------------|------------------------------------------------------|
| affiliate_id   | string | Sim         | ID primário gerado pelo CX CORP                      |
| secondary_id   | string | Sim         | CPF ou outro ID definido pelo cliente                |
| datetime       | string | Sim         | Data e hora da indicação                             |
| campaign_id    | string | Sim         | ID da campanha associada                             |
| referral_id    | string | Sim         | ID da indicação                                      |
| nfe_key        | string | Sim         | Chave da Nota Fiscal Eletrônica (NF-e)               |
| profile        | string | Não         | Perfil do afiliado (ex: pedreiro, pintor)            |

#### Exemplo de Requisição:

```bash
curl -X POST 'https://api.cxcorp.com/v1/affiliates/aff_123456/referrals' \
-H 'Authorization: Bearer {api_key}' \
-d '{
  "secondary_id": "123.456.789-10",
  "referral_data": {
    "datetime": "2024-09-17T14:30:00",
    "campaign_id": "camp_98765",
    "referral_id": "ref_54321",
    "nfe_key": "35170730290879000106550010001234567890123456",
    "profile": "eletricista"
  }
}'
```

---

### 3.2. Passo 2: CX CORP Recebe Resposta do ERP

O CX CORP recebe do ERP o status da indicação (aprovado, recusado), o valor creditado ou debitado (em pontos ou moeda), e outras informações adicionais para atualizar o extrato do afiliado.

#### Parâmetros da Resposta

| Parâmetro          | Tipo   | Obrigatório | Descrição                                                |
|--------------------|--------|-------------|----------------------------------------------------------|
| referral_id        | string | Sim         | ID da indicação registrada                                |
| status             | string | Sim         | Status da indicação (pendente, aprovado, recusado)        |
| points_increment   | float  | Não         | Incremento ou decremento de pontos                        |
| cashback_increment | float  | Não         | Incremento ou decremento em valor monetário               |
| currency           | string | Não         | Padrão de moeda (BRL ou USD)                              |
| history_short      | string | Sim         | Histórico reduzido (até 15 caracteres)                    |
| details            | string | Não         | Detalhamento adicional (até 255 caracteres)               |

#### Exemplo de Requisição:

```bash
curl -X POST 'https://api.cxcorp.com/v1/affiliates/aff_123456/referrals/ref_54321/response' \
-H 'Authorization: Bearer {api_key}' \
-d '{
  "status": "approved",
  "points_increment": 10,
  "cashback_increment": null,
  "currency": "BRL",
  "history_short": "Promo Set",
  "details": "Indicação aprovada e pontos adicionados."
}'
```

---

## 4. Exemplo de Fluxo de Integração

Exemplo completo de envio de uma indicação do CX CORP para o ERP e o retorno com o status e os valores processados.

```json
{
  "flow": [
    {
      "action": "Enviar indicação ao ERP",
      "endpoint": "/affiliates/aff_123456/referrals",
      "request": {
        "secondary_id": "123.456.789-10",
        "referral_data": {
          "datetime": "2024-09-17T14:30:00",
          "campaign_id": "camp_98765",
          "referral_id": "ref_54321",
          "nfe_key": "35170730290879000106550010001234567890123456",
          "profile": "eletricista"
        }
      }
    },
    {
      "action": "Receber resposta do ERP",
      "endpoint": "/affiliates/aff_123456/referrals/ref_54321/response",
      "response": {
        "status": "approved",
        "points_increment": 10,
        "cashback_increment": null,
        "currency": "BRL",
        "history_short": "Promo Set",
        "details": "Indicação aprovada e pontos adicionados."
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
- **404**: Recurso não encontrado.

#### Exemplo de Erro:

```json
{
  "error": {
    "code": "invalid_request_error",
    "message": "O campo 'nfe_key' é obrigatório."
  }
}
```

---

## 6. Webhooks

A plataforma CX CORP permite o uso de webhooks para receber notificações automáticas sobre eventos como novas indicações ou conversões completadas. O cliente deve fornecer um endpoint para receber esses eventos.

#### Exemplo de Webhook:

```json
{
  "event": "conversion.completed",
  "data": {
    "affiliate_id": "aff_123456",
    "conversion_id": "conv_987654",
    "amount": 1000.00,
    "points_increment": 50,
    "cashback_increment": null,
    "currency": "BRL"
  }
}
```

---

## 7. FAQs e Troubleshooting

- **Como obtenho as credenciais de API?**
- **O que fazer em caso de falha de autenticação?**
- **Como lidar com erros 404?**
