#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL ebarn_CondPagto DESCRIPTION "Serviço REST para retorno das filiais do sistema"

//WSDATA CnpjCpf     As Character //As String
//WSDATA DtaInicial  As Character //As String

WSMETHOD GET listaCondPagto DESCRIPTION "Retorna as filiais do sistema na URL" WSSYNTAX "/ebarn_CondPagto/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET listaCondPagto  WSRECEIVE WSRESTFUL  ebarn_CondPagto

Local aArea 	:= GetArea()

SELF:SetContentType("application/json")
   
cXmlEnv :=  fCondPgto()

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que retorna as formas de pagamento
Static function fCondPgto( )
///user function xCPgto( )
Local cQRYSE4		:= GetNextAlias()


Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

    BeginSQL Alias cQRYSE4

        SELECT  *  FROM  %table:SE4% SE4
        WHERE   SE4.D_E_L_E_T_ <> '*'
        ///     %exp:cSqlFilter% 
	EndSQL
         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSE4 )->( dBGotop() )

	While (cQRYSE4)->( !Eof() )
          
            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['idFilial'              ] := ALLTRIM((cQRYSE4)->E4_FILIAL)
			aJson[nPos]['codigo'                ] := ALLTRIM((cQRYSE4)->E4_CODIGO)
            aJson[nPos]['tipo'                  ] := ALLTRIM((cQRYSE4)->E4_COND)
            aJson[nPos]['descricao'             ] := ALLTRIM((cQRYSE4)->E4_DESCRI)
            aJson[nPos]['ipi'                   ] := ALLTRIM((cQRYSE4)->E4_IPI)     //N=NORMAL,J=JUNTA,S=SEPARA
            aJson[nPos]['diasDaCondicao'        ] := ALLTRIM((cQRYSE4)->E4_DDD)
            aJson[nPos]['descontoFinanceiro'    ] := ALLTRIM((cQRYSE4)->E4_DESCFIN)
            aJson[nPos]['diasParaDesconto'      ] := ALLTRIM((cQRYSE4)->E4_DIADESC)
            aJson[nPos]['ativo'                 ] := IIF ( (cQRYSE4)->E4_MSBLQL == '1' , .F. , .T. )
            aJson[nPos]['formaPagto'            ] := ALLTRIM((cQRYSE4)->E4_FORMA)
            aJson[nPos]['percAcrescFinanceiro'   ] := ALLTRIM((cQRYSE4)->E4_ACRSFIN)
            aJson[nPos]['icmSolidario'          ] := ALLTRIM((cQRYSE4)->E4_SOLID)       //N=NORMAL,J=JUNTA,S=SEPARA
            aJson[nPos]['criterioAcrescFinanc'  ] := ALLTRIM((cQRYSE4)->E4_DESCRI)      //N=NORMAL,J=JUNTA,S=SEPARA,V=NC a Vista
            aJson[nPos]['limiteSuperior'        ] := ALLTRIM( (cQRYSE4)->E4_SUPER)
            aJson[nPos]['limiteInferior'        ] := ALLTRIM( (cQRYSE4)->E4_SUPER)
            aJson[nPos]['permiteAdiantamento'   ] := ALLTRIM((cQRYSE4)->E4_CTRADT)
            aJson[nPos]['agregaAcresc'          ] := ALLTRIM((cQRYSE4)->E4_AGRACRS)
            aJson[nPos]['limiteDiasPgto'        ] := ALLTRIM((cQRYSE4)->E4_LIMACRS)
            aJson[nPos]['usaContaCorrente'      ] := ALLTRIM((cQRYSE4)->E4_CCORREN)
           
         (cQRYSE4)->( DbSkip() )

    EndDo
    
    (cQRYSE4)->( DbCloseArea() )

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
//EECVIEW(cXmlEnv,'endpoint CondPagto')
Return( cXmlEnv )


