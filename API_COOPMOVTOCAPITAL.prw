#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

User Function EbarnC09 ()
Return

WSRESTFUL ebarn_movimentosCota DESCRIPTION "Serviço REST para retorno do Saldo de Cota Capital"

WSDATA CnpjCpf     As Character //As String
WSDATA DtaInicial  As Character //As String

WSMETHOD GET movimentosCotaCapital DESCRIPTION "Retorna Saldo de Cota Capital na URL" WSSYNTAX "/ebarn_movimentosCota/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET movimentosCotaCapital  WSRECEIVE WSRESTFUL  ebarn_movimentosCota

Local aArea 	:= GetArea()
Local dDtIni 	:= ctod('//')

SELF:SetContentType("application/json")

    IF Empty(Self:CnpjCpf )
        SetRestFault(500,EncodeUTF8('O parametro CPF/CNPJ do Cooperado deve ser informado.'))
        lRet    := .F.
        Return(lRet)
	ElseIF Empty(Self:DtaInicial )
	    dDtIni:= date() - 30
        ///SetRestFault(500,EncodeUTF8('O parametro CPF/CNPJ do Cooperado deve ser informado.'))
        ///lRet    := .F.
        ///Return(lRet)
	ElseIF .not. Empty( Self:DtaInicial )
	    dDtIni := cTod( Self:DtaInicial )

        IF Empty(dDtIni) // Se após a conversão eu não tiver uma data é pq a data esta no formato errado ...
			SetRestFault(500,EncodeUTF8('O parametro Data inicial deve estar no formato dd/mm/yyyy.'))
			lRet    := .F.
			Return(lRet)
		EndIF

    EndIF
	
cXmlEnv :=  fGetMvtCta( Self:CnpjCpf, dDtini    )

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
Static function fGetMVTCta( cnpjcpf, dDtini    )
///user function feme1( cnpjcpf, dDtIni  )

Local cQRYSA1		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local nSaldoini     := 0
Local nIdx			:= 0

    BeginSQL Alias cQRYSA1

        SELECT  A1_COD,A1_CGC, A1_INSCR,A1_PESSOA, ROW_NUMBER() OVER ( PARTITION BY A1_COD,A1_CGC ORDER BY A1_COD,A1_CGC) AS IdLine FROM  %table:SA1% SA1
        WHERE SA1.D_E_L_E_T_ <> '*'
        AND SA1.A1_CGC = %exp:cnpjcpf%
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
            nSaldoIni := SldSN1((cQRYSA1)->A1_COD,'A', (cQRYSA1)->A1_PESSOA, dDtIni )
            aDetalhe  := AchaMov((cQRYSA1)->A1_COD, nSaldoIni,  (cQRYSA1)->A1_PESSOA, dDtIni )

 			For nIdx := 1 to Len( aDetalhe )
                Aadd(aJson,JsonObject():new())
                nPos := Len(aJson)
                aJson[nPos][ 'datamovto' ] :=  sToD(aDetalhe[nIdx, 1])
				aJson[nPos][ 'historico' ] :=  Alltrim( aDetalhe[nIdx, 2] )
				aJson[nPos][ 'documento' ] :=  Alltrim( aDetalhe[nIdx, 7] )
				aJson[nPos][ 'tipo'      ] :=  Alltrim( aDetalhe[nIdx, 3] )
				aJson[nPos][ 'entrada'   ] :=  aDetalhe[nIdx, 4]
				aJson[nPos][ 'saida'     ] :=  aDetalhe[nIdx, 5]
				aJson[nPos][ 'saldo'     ] :=  aDetalhe[nIdx, 6]
            nExt nIdx

         (cQRYSA1)->( DbSkip() )

    EndDo
    
    (cQRYSA1)->( DbCloseArea() )

WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

cXmlEnv:=''
///cXmlEnv := '{'
///cXmlEnv += '"MovtoCotaCapital":'
cXmlEnv +=  WjSonAux:toJSON()
///cXmlEnv +=  '}'

FreeObj( WjSonAux )
///EECVIEW(cXmlEnv,'SldCotaCapital')
Return( cXmlEnv )

//Função para buscar os saldos cooperado
//Passar codigo do bem = A1_COD
//Passar .t.
//Passar se é pessoa fisica ou juridica.

Static Function SldSN1(cCodBem, cTipo, cFrmPsq, dDtIni)
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
		cQuery += "AND N1_AQUISIC < '" +  DTOS( dDtIni ) + "' " ////DTOS( DATE() - 30 ) + "' "
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


//Função para Achar os Movimentos
Static Function AchaMov(cCodBem, nSldIni, cFrmPsq,dDtIni )
	Local cQuery	:= ""
	Local aRetMov 	:= {}
	Local aTmp		:= {}
	Local nFaz		:= 0
	Local cGrupo	:= SuperGetMV("CM_GRPCOT",,  "0025")
	Local nValor	:= 0
	Local cTmpHst	:= ""
	Local nEntrada	:= 0
	Local nSaida	:= 0
	Local nSaldo	:= nSldIni

	Private lTrzFil	:= SuperGetMV("CM_TRZFIL",,  "N") == "S"

	cQuery := "SELECT N1_AQUISIC, N3_XHISTO, N3_HISTOR, N3_TIPO, N1_XTIPO, N3_VORIG1, N1_QUANTD, N3_ITEM, N3_BAIXA, N1_BAIXA, N1_NFISCAL "
	cQuery += "FROM "+ retsqlname("SN1")+" SN1 "
	cQuery += "INNER JOIN "+ retsqlname("SN3")+" SN3 ON SN3.D_E_L_E_T_ = ' ' AND N3_CBASE = N1_CBASE AND N3_ITEM = N1_ITEM AND SN3.N3_FILIAL = SN1.N1_FILIAL "
	IF lTrzFil
		cQuery += "WHERE " + RetSqlCond("SN1")+" "
	Else
		cQuery += "WHERE SN1.D_E_L_E_T_ = ' ' "
	EndIF 
	IF cFrmPsq == "J"
		cQuery += "AND SUBSTRING(N1_CBASE,1,8) = '"+substr(cCodBem,1,8)+"' "
	Else
		cQuery += "AND SUBSTRING(N1_CBASE,1,9) = '"+substr(cCodBem,1,9)+"' "
	EndIF
	cQuery += "AND N1_GRUPO = '"+cGrupo+"' "
	cQuery += "AND N1_AQUISIC BETWEEN '" +  DTOS( dDtIni ) + "' " 
	cQuery += " AND '" +  DTOS( date() ) + "' "
	cQuery += "ORDER BY N1_AQUISIC, N1_CBASE, N1_ITEM "

	//MemoWrite("C:\TEMP\AchaMov.sql",cQuery)
	aTmp	:= CMV00G01(cQuery)
	IF Len(aTmp)>0 
		For nFaz:=1 to Len(aTmp)
		
			nEntrada	:= 0
			nSaida		:= 0
			
			nValor	:= aTmp[nFaz,6]
			cTmpHst	:= IIF(Empty(aTmp[nFaz,2]),aTmp[nFaz,3], aTmp[nFaz,2])

			IF (aTmp[nFaz,5] == "P" .OR. aTmp[nFaz,5] == "O")
				nEntrada := nValor
				nSaldo += nEntrada
			ElseIF (aTmp[nFaz,5] == "R" .OR. aTmp[nFaz,5] == "D")
				nSaida := nValor
				nSaldo -= nSaida
			EndIF

			aadd(aRetMov, {aTmp[nFaz,1],cTmpHst, aTmp[nFaz,4],nEntrada, nSaida, nSaldo, aTmp[nFaz,11] })

		Next nFaz
	EndIF

Return aRetMov


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



