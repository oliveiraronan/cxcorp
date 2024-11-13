#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL ebarn_filiais DESCRIPTION "Serviço REST para retorno das filiais do sistema"

//WSDATA CnpjCpf     As Character //As String
//WSDATA DtaInicial  As Character //As String

WSMETHOD GET listaFiliais DESCRIPTION "Retorna as filiais do sistema na URL" WSSYNTAX "/ebarn_filiais/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET listaFiliais  WSRECEIVE WSRESTFUL  ebarn_filiais

Local aArea 	:= GetArea()

SELF:SetContentType("application/json")
   
cXmlEnv :=  fFiliais()

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que retorna as filiais do sistema
Static function fFiliais( )

Local cQRYSM0		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

    BeginSQL Alias cQRYSM0

        SELECT  *  FROM  SYS_COMPANY
        WHERE  SYS_COMPANY.D_E_L_E_T_ <> '*'
        M0_CODFIL = cFilArm

	EndSQL
         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSM0 )->( dBGotop() )

	While (cQRYSM0)->( !Eof() )
          
            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['idFilial'       ] := ALLTRIM((cQRYSM0)->M0_CODFIL)
			aJson[nPos]['descricaoFilial' ] := ALLTRIM((cQRYSM0)->M0_FILIAL)
            aJson[nPos]['nome'           ] := ALLTRIM((cQRYSM0)->M0_NOMECOM)
            aJson[nPos]['cnpjCpf'        ] := ALLTRIM((cQRYSM0)->M0_CGC)
            aJson[nPos]['cei'            ] := ALLTRIM((cQRYSM0)->M0_CEI)
            aJson[nPos]['inscricao'      ] := ALLTRIM((cQRYSM0)->M0_INSC)
            ///aJson[nPos]['tipoinsc'    ] := ALLTRIM((cQRYSM0)->M0_insc)
            aJson[nPos]['inscricaoMunicipal'] := ALLTRIM((cQRYSM0)->M0_INSCM)
            aJson[nPos]['endCobranca'   ] := ALLTRIM((cQRYSM0)->M0_ENDCOB)
            aJson[nPos]['bairroCobranca'] := ALLTRIM((cQRYSM0)->M0_BAIRCOB)
            aJson[nPos]['cidadeCobranca'] := ALLTRIM((cQRYSM0)->M0_CIDCOB)
            aJson[nPos]['ufCobranca'    ] := ALLTRIM((cQRYSM0)->M0_ESTCOB)
            aJson[nPos]['cepCobranca'   ] := ALLTRIM((cQRYSM0)->M0_CEPCOB)

         (cQRYSM0)->( DbSkip() )

    EndDo
    
    (cQRYSM0)->( DbCloseArea() )

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
////EECVIEW(cXmlEnv,'endpoint filiais')
Return( cXmlEnv )


