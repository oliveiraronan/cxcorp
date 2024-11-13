#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EbarnC01 ()
Return

WSRESTFUL ebarn_romaneios DESCRIPTION "Serviço REST para retorno romaneios dos contratos da agroindustria"

WSDATA IdContrato As Character //As String
WSDATA Filial     As Character //As String

WSMETHOD GET romaneioscontrato DESCRIPTION "Retorna Romaneios dos Contratos da agro industria na URL" WSSYNTAX "/ebarn_romaneios/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET romaneioscontrato  WSRECEIVE WSRESTFUL  ebarn_romaneios  

Local aArea := GetArea()


SELF:SetContentType("application/json")
    /*
    obrigatorio informar o numero do pedido
    */
    IF Empty(Self:IdContrato)
        SetRestFault(500,EncodeUTF8('O parametro IdContrato de deposito de terceiro é obrigatório'))
        lRet    := .F.
        Return(lRet)
    ElseIF Empty( Self:Filial )
        SetRestFault(500,EncodeUTF8('O parametro Filial do Contrato é obrigatório'))
        lRet    := .F.
        Return(lRet)
     EndIF

cXmlEnv := fRomCtr3(Self:IdContrato, Self:Filial)

oResponse := JsonObject():New() 
////oResponse:set(aJson)                          //Será Inserido Array na Raiz do documento (Somente Array ou JsonObject deve ser informado no parametro)
///   conout(Len(wrk))                       //Imprime a contagem de elementos
///    conout(wrk:toJSON())

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

//cReturn := "{ 'SUCESS: ok', 'MESSAGE :  emerson ', 'Emerson1: '}"
//cJson := FWJsonSerialize(oObjProd)
//cJson := FWJsonSerialize(cReturn)

//self:SetResponse(cJson)

RestArea(aArea)
Return(.T.)

//Função que encontra os vrs. financeiros a Receber do Cooperado informado....
//Atenção a Posição financeira do cooperado é  A PAGAR da cooperativa
Static function fRomCtr3(cIdContrat, cFilCtr )
///user function feme2(cIdContrato, cFilCtr )

Local aJson         := {}
Local WjSonAux      := nil
Local lEntrada      :=  .t.

 fGetRomaneios(cIdContrat, cFilCtr, lEntrada, aJson )   //Pega os romaneios de entrada
 fGetRomaneios(cIdContrat, cFilCtr, .f.,      aJson )        //Pega os romaneios de saida

WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

///cXmlEnv := '{'
///cXmlEnv += '"Romaneios":'
///cXmlEnv +=  WjSonAux:toJSON()
///cXmlEnv +=  '}'

cXmlEnv :=  WjSonAux:toJSON()

FreeObj( WjSonAux )

///EECVIEW(cXmlEnv,'validando qtd dos itens')
Return( cXmlEnv )

//Função que pega os romaneios do Contrato por Tipo ( Entrada ou Saida )

static function fGetRomaneios(cIdCtr, cFilCtr, lEntrada,aJson )

Local cQRYNJM		:= GetNextAlias()
Local cAliasDesc	:= GetNextAlias()

//Local aJson         := {}
Local nPos          := 0

Local cSqlfilter    := ''

IF lEntrada
    cSqlFilter := " AND NJM.NJM_TIPO IN ('1','3', '5','7', '9','A')"
Else  //Saidas
   cSqlFilter := " AND NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' , 'B' ) " 
EndIF

IF  Empty(cSqlFilter)
	cSqlFilter := "%%"
Else
	cSqlFilter := "% " + cSqlFilter + " %"
Endif


BeginSQL Alias cQryNJM
       SELECT *  FROM   %table:NJM%  NJM
               LEFT JOIN %table:NJJ% NJJ 
                     ON NJJ.NJJ_FILIAL = NJM.NJM_FILIAL
                    AND NJJ.NJJ_CODROM = NJM.NJM_CODROM
            WHERE NJM.NJM_CODCTR = %exp:cIdCtr%
            AND NJM.D_E_L_E_T_!= '*'
             %exp:cSqlFilter%
            AND NJM.NJM_FILIAL = %exp:cFilCtr%
            
            AND NJJ.NJJ_STATUS != '4'
            ////AND NJM.NJM_TIPO IN ('1','3', '5','7', '9','A')
EndSQL
          
	///EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    (cQryNJM)->( dBGotop() )

		While (cQryNJM)->( !Eof() )

        	nDesconto 	:= 0
			nPeso1		:= 0
			nPeso2		:= 0
			nPercRom	:= 0
			nPesoBruto	:= 0
			nPesoLiq	:= 0

 		dbSelectArea( "NJJ" )
		NJJ->( dbSetOrder( 1 ) )
		cTransp 	:= ''
		cPlaca		:= ''
		cStatus		:= ''
		If NJJ->( dbSeek( (cQryNJM)->NJM_FILIAL + (cQryNJM)->NJM_CODROM ) ) 
			cTransp 	:= NJJ->NJJ_CODTRA + ' ' + POSICIONE('SA4',1,XFILIAL('SA4')+NJJ->NJJ_CODTRA,'A4_NOME')
			cPlaca  	:= NJJ->NJJ_PLACA

			nDesconto 	:= 0
			nPeso1		:= 0
			nPeso2		:= 0
			nPercRom	:= 0
			nPesoBruto	:= 0
			nPesoLiq	:= 0
			
			dbSelectArea( "NJK" )
			NJK->( dbSetOrder( 1 ) )
			If NJK->( dbSeek( NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM ) )
				While NJK->(!Eof()) .AND. NJK->NJK_FILIAL == NJJ->NJJ_FILIAL .AND. NJK->NJK_CODROM == NJJ->NJJ_CODROM
					nDesconto 	+= NJK->NJK_QTDDES
					NJK->( DbSkip() )
				EndDo
			EndIf 
			
			nPeso1 		:= NJJ->NJJ_PESO1
			nPeso2 		:= NJJ->NJJ_PESO2
			nPercRom  	:= (cQryNJM)->NJM_PERDIV
			//Verificando se o item do Romaneio e 100 % da Carga 
			IF !nPercRom = 100
				nPeso1 		*= nPercRom / 100
				nPeso2 		*= nPercRom / 100
				nDesconto 	*= nPercRom / 100
			EndIF  
			
			nPesoBruto 	:= ( nPeso1 - nPeso2 )	
			nPesoLiq 	:= nPesoBruto - nDesconto	
		EndIf

        //Encontrando os descontos
		cQueryDesc:=''
////		cTpDesctos := " 'UMI', 'IMP', 'AVAR', 'PH' "

		cQueryDesc := " SELECT NJK_CODDES, NJK_PERDES, NJK_READES, NJK_QTDDES FROM " + RETSQLTAB("NJK")
		cQueryDesc += " WHERE	NJK_CODROM	= '" 	+ (cQryNJM)->NJM_CODROM  	+ "'"
////		cQueryDesc += "   AND   NJK_CODDES	IN (" 	+ cTpDesctos 			+ ")"
		cQueryDesc += "   AND 	NJK_FILIAL = '" 	+ (cQryNJM)->NJM_FILIAL 	+ "'"
		cQueryDesc += "   AND 	D_E_L_E_T_ !='*'"

		cQuery := ChangeQuery(cQueryDesc)
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryDesc),cAliasDesc,.T.,.T.)

        aJsonDesct:= {}
        
        While !(cAliasDesc)->(EOF())
            Aadd(aJsonDesct,JsonObject():new())
            nPos := Len(aJsonDesct)
            aJsonDesct[nPos]['tipoDesconto'       ] := Alltrim( (cAliasDesc)->NJK_CODDES   ) 
            aJsonDesct[nPos]['percentualDesconto' ] := (cAliasDesc)->NJK_PERDES
            aJsonDesct[nPos]['qtDesconto'         ] := (cAliasDesc)->NJK_QTDDES
          
            (cAliasDesc)->( DbSkip() ) 
        EndDo
        
        (cAliasDesc)->( dBCloseArea() )

            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['tipoMovimento'      ] := IIF(lEntrada == .T. ,'ENTRADA','SAIDA')
            aJson[nPos]['filial'       ] := (cQryNJM)->NJM_FILIAL
            aJson[nPos]['idContrato'   ] := (cQryNJM)->NJM_CODCTR
            aJson[nPos]['emissao'       ] := DtoC( StoD( (cQryNJM)->NJM_DOCEMI) )  
            aJson[nPos]['documento'     ] := (cQryNJM)->NJM_DOCNUM
            aJson[nPos]['serie'         ] := (cQryNJM)->NJM_DOCSER
            aJson[nPos]['placa'         ] := cPlaca
            aJson[nPos]['idromaneio'      ] := (cQryNJM)->NJM_CODROM
            aJson[nPos]['pesoBruto'     ] := cValToChar ( nPesoBruto )
            aJson[nPos]['qtDesconto'    ] := cValToChar ( nDesconto )
            aJson[nPos]['pesoLiquido'   ] := cValToChar ( nPesoLiq )
            aJson[nPos]['qtFiscal'      ] := cValToChar ( (cQryNJM)->NJM_QTDFIS )
            aJson[nPos]['romaneiocompesagem'  ] := IIF( (cQryNJM)->NJJ_STSPES  == '1',.F.,.T.)


            aJson[Len(aJson)]['classificacao'] := aJsonDesct     //Cria uma propriedade do tipo array no ultimo elemento

        (cQRYNJM)->( !Dbskip() )

    EndDo
    
    (cQRYNJM)->( !DbCloseArea() )

Return( aJson )

