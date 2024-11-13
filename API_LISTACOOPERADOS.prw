#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL ebarn_cooperados DESCRIPTION "Serviço REST para retorno dos clientes cooperados"

WSDATA CnpjCpf     As Character OPTIONAL //As String
//WSDATA DtaInicial  As Character //As String

WSMETHOD GET listacooperados DESCRIPTION "Retorna Saldo de Cota Capital na URL" WSSYNTAX "/ebarn_cooperados/" PRODUCES APPLICATION_JSON

END WSRESTFUL

///WSMETHOD GET listacooperados  WSRECEIVE WSRESTFUL  ebarn_cooperados
WSMETHOD GET listacooperados  QUERYPARAM CnpjCpf WSRECEIVE WSRESTFUL  ebarn_cooperados

//WSMETHOD GET Entities QUERYPARAM Page,PageSize,Order,Fields  WSREST OGA010API

Local aArea 	:= GetArea()

SELF:SetContentType("application/json")


    IF Empty( Self:CnpjCpf )
       Self:CnpjCpf := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
     EndIF
   
cXmlEnv :=  fCooperado( Self:CnpjCpf  )

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que retorna as filiais do sistema
Static function fCooperado( CnpjCpf )
////user function femecoop()

Local cQRYSA1		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( CnpjCpf )
    cSqlfilter += " AND SA1.A1_CGC = '" + CnpjCpf  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

    BeginSQL Alias cQRYSA1

        SELECT DISTINCT A1_XMATCOO, A1_FILIAL,A1_COD, A1_LOJA,A1_CGC,A1_INSCR, A1_NOME,A1_NREDUZ,A1_END,A1_BAIRRO,A1_CEP,A1_CODMUN, A1_MUN,A1_XDTADMI, A1_XSITUAC, A1_XDTDESL,A1_EMAIL,A1_DDD, A1_TEL,A1_FAX,A1_CONTATO,A1_XWHATS 
            FROM %table:SA1% SA1
        WHERE   SA1.D_E_L_E_T_ = ' '
             %exp:cSqlFilter% 
            ///AND SA1.A1_XSITUAC = '1' //Atuante
            AND SA1.A1_XCOOP = 'S'    //Indentifica que é cooperado.
            ORDER BY A1_XMATCOO ASC
	EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSA1 )->( dBGotop() )

	While (cQRYSA1)->( !Eof() )
          
            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['idFilial'       ] := ALLTRIM((cQRYSA1)->A1_FILIAL)
			aJson[nPos]['idCooperado'    ] := ALLTRIM((cQRYSA1)->A1_COD)
            aJson[nPos]['ljaCooperado'   ] := ALLTRIM((cQRYSA1)->A1_LOJA)
            aJson[nPos]['cpfCnpj'        ] := ALLTRIM((cQRYSA1)->A1_CGC)
            aJson[nPos]['inscricao'      ] := ALLTRIM((cQRYSA1)->A1_INSCR)
            aJson[nPos]['nome'           ] := ALLTRIM((cQRYSA1)->A1_NOME)
            aJson[nPos]['nomeReduzido'   ] := ALLTRIM((cQRYSA1)->A1_NREDUZ)
            aJson[nPos]['endereco'       ] := ALLTRIM((cQRYSA1)->A1_END)
            aJson[nPos]['bairro'         ] := ALLTRIM((cQRYSA1)->A1_BAIRRO)
            aJson[nPos]['cidade'         ] := ALLTRIM((cQRYSA1)->A1_MUN)
            aJson[nPos]['cep'            ] := ALLTRIM((cQRYSA1)->A1_CEP)
            aJson[nPos]['email'          ] := ALLTRIM((cQRYSA1)->A1_EMAIL)
            aJson[nPos]['ddd'            ] := ALLTRIM((cQRYSA1)->A1_DDD)
            aJson[nPos]['telefone'       ] := ALLTRIM((cQRYSA1)->A1_TEL)
            aJson[nPos]['fax'            ] := ALLTRIM((cQRYSA1)->A1_FAX)
            aJson[nPos]['contato'        ] := ALLTRIM((cQRYSA1)->A1_CONTATO)
            aJson[nPos]['whatsapp'       ] := ALLTRIM((cQRYSA1)->A1_XWHATS)

         (cQRYSA1)->( DbSkip() )

    EndDo
    
    (cQRYSA1)->( DbCloseArea() )

WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

/*
cXmlEnv := '{'
cXmlEnv += '"FAMILIAS":'
cXmlEnv +=  WjSonAux:toJSON()
cXmlEnv +=  '}'
*/

cXmlEnv :=  WjSonAux:toJSON()
FreeObj( WjSonAux )
///EECVIEW(cXmlEnv,'endpoint cooperados')
Return( cXmlEnv )


