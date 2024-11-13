#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL ebarn_FormaPagto DESCRIPTION "Serviço REST para retorno das filiais do sistema"

//WSDATA CnpjCpf     As Character //As String
//WSDATA DtaInicial  As Character //As String

WSMETHOD GET listaFormaPagto DESCRIPTION "Retorna as filiais do sistema na URL" WSSYNTAX "/ebarn_FormaPagto/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET listaFormaPagto  WSRECEIVE WSRESTFUL  ebarn_FormaPagto

Local aArea 	:= GetArea()

SELF:SetContentType("application/json")
   
cXmlEnv :=  fFormaPgto()

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que retorna as filiais do sistema
Static function fFormaPgto( )
///user function xffpgto()

Local cQRYSX5		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

    BeginSQL Alias cQRYSX5

        SELECT  *    FROM %table:SX5% SX5
        WHERE  SX5.D_E_L_E_T_ <> '*'
        AND    SX5.X5_TABELA = '24' //Tabela de concições de pagamento...
       
	EndSQL
         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSX5 )->( dBGotop() )

	While (cQRYSX5)->( !Eof() )
          
            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['idFilial'              ] := ALLTRIM((cQRYSX5)->X5_FILIAL  )
			aJson[nPos]['codigo'                ] := ALLTRIM((cQRYSX5)->X5_CHAVE  )
            aJson[nPos]['descricao'             ] := ALLTRIM((cQRYSX5)->X5_DESCRI  )
           
         (cQRYSX5)->( DbSkip() )

    EndDo
    
    (cQRYSX5)->( DbCloseArea() )

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
///EECVIEW(cXmlEnv,'endpoint forma de pagto.')
Return( cXmlEnv )


