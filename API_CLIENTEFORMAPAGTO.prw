#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL ebarn_ClientesFormaPagto DESCRIPTION "Serviço REST para retorno das filiais do sistema"

WSDATA CnpjCpf     As Character OPTIONAL

//WSDATA DtaInicial  As Character //As String

WSMETHOD GET ClientesFormasPagto DESCRIPTION "Retorna as filiais do sistema na URL" WSSYNTAX "/ebarn_ClientesFormaPagto/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET ClientesFormasPagto  QUERYPARAM CnpjCpf WSRECEIVE WSRESTFUL  ebarn_ClientesFormaPagto

Local aArea 	:= GetArea()

SELF:SetContentType("application/json")


IF Empty( Self:CnpjCpf )
       Self:CnpjCpf := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
     EndIF


   
cXmlEnv :=  fCliFPagto( Self:CnpjCpf  )

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)


//Função que retorna formas de pagto do sistema..
Static function fCliFPagto( cnpjCpf)
//user function xPagto( cnpjCpf)

Local cQryFmaPag	:= GetNextAlias()
Local cQrySA1   	:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil
///Local cCliLoja      := ''
Local nRecCount     := 0


Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cnpjCpf )
    cSqlfilter += " AND SA1.A1_CGC = '" + cnpjCpf  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

BeginSQL Alias cQrySA1

    SELECT SA1.A1_FILIAL, SA1.A1_CGC, SA1.A1_INSCR, SA1.A1_COD, SA1.A1_LOJA FROM %table:SA1% SA1
         WHERE SA1.D_E_L_E_T_ <> '*'
         ///AND SA1.A1_XSITUAC = '1' //Atuante
        AND SA1.A1_XCOOP = 'S'    //Indentifica que é cooperado.
         %exp:cSqlFilter%
    ORDER BY A1_FILIAL, A1_COD, A1_LOJA

EndSQL

    ( cQrySA1 )->( dBGotop() )

	While ( cQrySA1 )->( !Eof() )

           BeginSQL Alias cQryFmaPag
                SELECT ZZ1.* FROM %table:ZZ1% ZZ1
                    WHERE ZZ1.D_E_L_E_T_ <> '*'
                     AND  ZZ1_FILIAL = %exp:( cQrySA1 )->A1_FILIAL% 
                     AND ZZ1.ZZ1_COD = %exp:( cQrySA1 )->A1_COD% 
                     AND ZZ1.ZZ1_LOJA  = %exp:( cQrySA1 )->A1_LOJA% 
                    ORDER BY ZZ1_FILIAL, ZZ1_COD, ZZ1_LOJA
	        EndSQL

            nRecCount := 0
            Count To nRecCount

            IF nRecCount >0 //( cQryFmaPag )->(RECCOUNT()) > 0 //Adiciono o cliente somente se ele tiver condição de pagamento cadastrada...

                Aadd(aJson,JsonObject():new())
                nPos := Len(aJson)
                aJson[nPos]['idFilial'              ] := ALLTRIM((cQrySA1)->A1_FILIAL  )
                aJson[nPos]['codigo'                ] := ALLTRIM((cQrySA1)->A1_COD )
                aJson[nPos]['loja'                  ] := ALLTRIM((cQrySA1)->A1_LOJA  )
                aJson[nPos]['cpfCnpj'               ] := ALLTRIM((cQrySA1)->A1_CGC)
                aJson[nPos]['inscricao'             ] := ALLTRIM((cQrySA1)->A1_INSCR)

                aJsonForma := {}

                ( cQryFmaPag )->( dBGotop() )
                While ( cQryFmaPag )->( !Eof() )

                        Aadd(aJsonForma,JsonObject():new())
                        nPos := Len(aJsonForma)

                        aJsonForma[nPos]['codigo'       ] := Alltrim( (cQryFmaPag)->ZZ1_FORMA   ) 
                        aJsonForma[nPos]['descricao'    ] := (cQryFmaPag)->ZZ1_DESCFO

                        (cQryFmaPag)->( DbSkip() )
                EndDo

                aJson[Len(aJson)]['formasPagto'     ] := aJsonForma 
                
            EndIF

            (cQryFmaPag)->( dbclosearea () )

          (cQrySA1)->( DbSkip() )
    EndDo

 
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )
    
    (cQrySA1)->( DbCloseArea() )

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
///EECVIEW(cXmlEnv,'endpoint formaS de pagto.')
Return( cXmlEnv )


