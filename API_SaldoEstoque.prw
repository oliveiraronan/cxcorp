#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL ebarn_Saldo DESCRIPTION "Serviço REST para retorno do Saldo Produto em estoque"

WSDATA idProd     As Character OPTIONAL //As String


WSMETHOD GET saldoProdutos DESCRIPTION "Retorna o Saldo em estoque do produto" WSSYNTAX "/ebarn_Saldo/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET saldoProdutos  QUERYPARAM idProd WSRECEIVE WSRESTFUL  ebarn_Saldo

Local aArea 	:= GetArea()

SELF:SetContentType("application/json")

    IF Empty( Self:idProd )
       Self:idProd := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
     EndIF

   
cXmlEnv :=  fSldProds( Self:idProd )

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que retorna as filiais do sistema
Static function fSldProds( cCodProd )
///User function fSldEme( cCodProd )


Local cQRYSB2		:= GetNextAlias()
Local lLocaliza     := .f.
Local lRastro       := .f.

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cCodProd )
    cSqlfilter += " AND SB2.B2_COD = '" + cCodProd  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif


	BeginSQL Alias cQRYSB2
		SELECT *
		FROM 	%Table:SB2% SB2
		WHERE 	SB2.%NotDel% 
        %exp:cSqlFilter% 
		///AND %Exp:cFilQry%
		ORDER BY SB2.B2_COD, SB2.B2_LOCAL
	EndSQL
         
	///EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSB2 )->( dBGotop() )
    
    SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

	While ( cQRYSB2 )->(!Eof())

            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)

			SB2->(dbSeek(( cQRYSB2 )->B2_FILIAL + ( cQRYSB2 )->B2_COD + (cQRYSB2)->B2_LOCAL))
			///lLocaliza  := Localiza(( cQRYSB2 )->B2_COD)
			///lRastro    := Rastro(( cQRYSB2 )->B2_COD)

            aJson[nPos]['idFilial'          ] := RTrim(  (cQRYSB2 )->B2_FILIAL ) 
            aJson[nPos]['idItem'            ] := RTrim((cQRYSB2)->B2_COD)
            aJson[nPos]['idArmazem'         ] := RTrim((cQRYSB2)->B2_LOCAL)
            aJson[nPos]['EstoqueAtual'      ] :=  ( cQRYSB2 )->B2_QATU
            aJson[nPos]['EstoqueDisponivel' ] := SaldoSB2()
    
    /*
				cXMLRet  += '<RequestItem>'
				cXMLRet  += 		'<CompanyId>'+ cEmpAnt +'</CompanyId>'
				cXMLRet  += 		'<BranchId>' + RTrim(xFilial("SB2")) +'</BranchId>'
				cXMLRet  += 		'<CompanyInternalId>' + cEmpAnt + "|" + RTrim(xFilial("SB2")) + '</CompanyInternalId>'
				cXMLRet  += 		'<ItemInternalId>' + cEmpAnt + "|" + RTrim(xFilial("SB1")) + "|" + RTrim(TMPSB2->B2_COD) +	'</ItemInternalId>'
				cXMLRet  += 		'<WarehouseInternalId>' + cEmpAnt + "|" + RTrim(xFilial("NNR")) + "|" + RTrim(TMPSB2->B2_LOCAL) +'</WarehouseInternalId>'
				cXMLRet  += 		'<UnitItemCost>' + AllTrim(cValToChar(TMPSB2->B2_CM1)) + '</UnitItemCost>'
				cXMLRet  += 		'<AverageUnitItemCost>' + AllTrim(cValToChar(TMPSB2->B2_VATU1)) + '</AverageUnitItemCost>'
				cXMLRet  += 		'<CurrentStockAmount>' + AllTrim(cValToChar(TMPSB2->B2_QATU)) + '</CurrentStockAmount>'
				cXMLRet  += 		'<AvailableStockAmount>' + AllTrim(cValToChar(SaldoSB2())) + '</AvailableStockAmount>'
				cXMLRet  += 		'<BookedStockAmount>' + AllTrim(cValToChar(TMPSB2->B2_RESERVA)) + '</BookedStockAmount>'
				cXMLRet  += 		'<ValueOfCurrentStockAmount>' + AllTrim(cValToChar(TMPSB2->B2_VATU1)) + '</ValueOfCurrentStockAmount>'
          
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
        */

         (cQRYSB2)->( DbSkip() )

    EndDo
    
    (cQRYSB2)->( DbCloseArea() )

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
//EECVIEW(cXmlEnv,'endpoint filiais')
Return( cXmlEnv )


