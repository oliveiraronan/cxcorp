#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

User Function EbarnC07 ()
Return

WSRESTFUL ebarn_filiais DESCRIPTION "Serviço REST para retorno das filiais do sistema"

WSMETHOD GET filiais DESCRIPTION "Retorna Saldo de Cota Capital na URL" WSSYNTAX "/ebarn_filiais/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD filiais  WSRECEIVE WSRESTFUL  ebarn_filiais

Local aArea := GetArea()

SELF:SetContentType("application/json")

    IF Empty(Self:cnpjCpf )
        SetRestFault(500,EncodeUTF8('O parametro CPF/CNPJ do Cooperado deve ser informado.'))
        lRet    := .F.
        Return(lRet)
    EndIF

cXmlEnv := fGetSldCta(Self:cnpjCpf )

oResponse := JsonObject():New() 
oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que encontra o saldo da Cota Capital do Cooperado.
Static function fGetSldCta( cnpjCpf    )
////user function ftst1( cnpjCpf   )

Local cQRYSA1		:= GetNextAlias()

Local oJson         
Local nPos          := 0
Local WjSonAux      := nil

Local nSaldo        := 0

    BeginSQL Alias cQRYSA1

        SELECT  A1_COD,A1_CGC, A1_INSCR,A1_PESSOA, ROW_NUMBER() OVER ( PARTITION BY A1_COD,A1_CGC ORDER BY A1_COD,A1_CGC) AS IdLine FROM  %table:SA1% SA1
        WHERE SA1.D_E_L_E_T_ <> '*'
        AND SA1.A1_CGC = %exp:cnpjCpf%
        ORDER BY A1_COD

	EndSQL
         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSA1 )->( dBGotop() )
	  
	While (cQRYSA1)->( !Eof() )
  
            IF .not. (cQRYSA1)->IdLine = 1
                (cQRYSA1)->( DbSkip() )
                Loop
            EndIF

            //Função sldsn1 criada por mentes no fonte CMV01R01 ( Se alterar lá tem que alterar aqui)
            nSaldo := 0
            nSaldo := SldSN1((cQRYSA1)->A1_COD,'T', (cQRYSA1)->A1_PESSOA )

            //Aadd(aJson,JsonObject():new())
            oJson:= JsonObject():new()
			//nPos := Len(aJson)
            ////aJson[nPos]['cnpjCpf' ] := Alltrim( (cQRYSA1)->A1_CGC )
            ////aJson[nPos]['Saldo'   ]  := nSaldo
            oJson['cnpjCpf' ]  := Alltrim( (cQRYSA1)->A1_CGC )
            oJson['Saldo'   ]  := nSaldo
						
			Exit //Abandona o sistema, pois so faz uma vez ...
              
         (cQRYSA1)->( DbSkip() )

    EndDo
    
    (cQRYSA1)->( DbCloseArea() )

///WjSonAux    := JsonObject():new()
///WjSonAux:set(aJson) 

/****
cXmlEnv := '{'
cXmlEnv += '"SldCotaCapital":'
cXmlEnv +=  WjSonAux:toJSON()
cXmlEnv +=  '}'
***/

cXmlEnv := oJson:ToJson()

FreeObj( oJson )
///FreeObj( WjSonAux )
///EECVIEW(cXmlEnv,'SldCotaCapital')
Return( cXmlEnv )

//Função para buscar os saldos da cota capital do cooperado
//Passar codigo do bem = A1_COD
//Passar .t.
//Passar se é pessoa fisica ou juridica.
Static Function SldSN1(cCodBem, cTipo, cFrmPsq)
	Local cQuery	:= ""
	Local aTmp		:= {}
	Local cGrupo	:= SuperGetMV("CM_GRPCOT",,  "0025")
	Local nSaldo	:= 0

    Private lTrzFil	:= SuperGetMV("CM_TRZFIL",,  "N") == "S"
    

	cQuery := "SELECT " 
	//cQuery += "COALESCE(SUM(CASE N1_XTIPO WHEN 'P' THEN N3_VORIG1 ELSE 0  END),0) DEBITO, "	
	cQuery += "COALESCE(SUM(CASE WHEN N1_XTIPO = 'P' THEN N3_VORIG1 WHEN N1_XTIPO = 'O' THEN N3_VORIG1 ELSE 0  END),0) DEBITO, "
	cQuery += "COALESCE(SUM(CASE WHEN N1_XTIPO = 'R' THEN N3_VORIG1 WHEN N1_XTIPO = 'D' THEN N3_VORIG1 ELSE 0  END),0) CREDITO "
	cQuery += "FROM "+ retsqlname("SN1")+" SN1 "
	cQuery += "INNER JOIN "+ retsqlname("SN3")+" SN3 ON SN3.D_E_L_E_T_ = ' ' AND N3_CBASE = N1_CBASE AND N3_ITEM = N1_ITEM AND SN3.N3_FILIAL = SN1.N1_FILIAL "
	IF lTrzFil
		cQuery += "WHERE " + RetSqlCond("SN1")+" "
	Else
		cQuery += "WHERE SN1.D_E_L_E_T_ = ' ' "
	EndIF 
	
	IF cFrmPsq == "J"
		cQuery += "AND SUBSTRING(N1_CBASE,1,8) = '"+Substr(cCodBem,1,8)+"' "
	Else
		cQuery += "AND SUBSTRING(N1_CBASE,1,9) = '"+Substr(cCodBem,1,9)+"' "
	EndIF
	
	cQuery += "AND N1_GRUPO = '"+cGrupo+"' "

	IF cTipo == "A" //Saldo Anterior
		cQuery += "AND N1_AQUISIC < '" +  DTOS(MV_PAR01) + "' "
	ElseIF cTipo == "F" //Saldo Final Pesquisa
		cQuery += "AND N1_AQUISIC <= '" +  DTOS(MV_PAR02) + "' "
	ElseIF cTipo == "T"// Saldo até data Atual
		cQuery += "AND N1_AQUISIC <= '" +  DTOS(date()) + "' "
	EndIF

	/*IF cTipo == "A" //Saldo Anterior
		MemoWrite("C:\TEMP\SldSN1_A.sql",cQuery)
	ElseIF cTipo == "F" //Saldo Final Pesquisa
		MemoWrite("C:\TEMP\SldSN1_F.sql",cQuery)
	ElseIF cTipo == "T"// Saldo até data Atual
		MemoWrite("C:\TEMP\SldSN1_T.sql",cQuery)
	EndIF*/
	
	//MemoWrite("C:\TEMP\SldSN1.sql",cQuery)
	aTmp	:= CMV00G01( cQuery )

	IF Len(aTmp) > 0
		nSaldo := (aTmp[1,1] - aTmp[1,2])
	EndIF

Return nSaldo


//Função para tratamento da query //
Static Function CMV00G01(cQuery)

	Local aRet    := {}
	Local aRet1   := {}
	Local nRegAtu := 0
	Local x       := 0

	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "_TRB"

	dbSelectArea("_TRB")
	aRet1   := Array(Fcount())
	nRegAtu := 1

	While !Eof()

		For x:=1 To Fcount()
			aRet1[x] := FieldGet(x)
		Next
		Aadd(aRet,aclone(aRet1))

		dbSkip()
		nRegAtu += 1
	Enddo

	dbSelectArea("_TRB")
	_TRB->(DbCloseArea())

Return(aRet)


