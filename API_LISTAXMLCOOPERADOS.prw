#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#include 'TOPCONN.CH'

WSRESTFUL TmplSem_OrdemColheita DESCRIPTION "Serviço REST para retorno das Ordens Colheita SimpleField"

WSDATA dDtxmlEmis      As Character OPTIONAL //As String
WSDATA OffSET    		AS INTEGER	OPTIONAL
WSDATA PageSize			AS INTEGER	OPTIONAL	

//WSDATA DtaInicial  As Character //As String

WSMETHOD GET listaxmlOrdensCoelheita;
DESCRIPTION "Retorna XML das ordens Colheita na URL";
WSSYNTAX "/TmplSem_OrdemColheita/{dDtxmlEmis, Offset, PageSize}" PRODUCES APPLICATION_JSON


END WSRESTFUL
             
///WSMETHOD GET listacooperados  WSRECEIVE WSRESTFUL  ebarn_cooperados
WSMETHOD GET listaxmlOrdensCoelheita  QUERYPARAM dDtxmlEmis,Offset, PageSize WSRECEIVE WSRESTFUL  ebarn_xmlcooperados

//WSMETHOD GET Entities QUERYPARAM Page,PageSize,Order,Fields  WSREST OGA010API

Local aArea 	    := GetArea()
Local nConProtheus  := AdvConnection() // obtém o ID da conexão atual
Local nConTSS     

SELF:SetContentType("application/json")

	IF Empty(Self:dDtxmlEmis )
			SetRestFault(500,EncodeUTF8('O parametro Data  deve ser informado e estar no formato dd/mm/yyyy.'))
			lRet    := .F.
			Return(lRet)
	ElseIF .not. Empty( Self:dDtxmlEmis )
	    dDtIni := cTod( Self:dDtxmlEmis )

        IF Empty(dDtIni) // Se após a conversão eu não tiver uma data é pq a data esta no formato errado ...
			SetRestFault(500,EncodeUTF8('O parametro Data inicial deve estar no formato dd/mm/yyyy.'))
			lRet    := .F.
			Return(lRet)
		EndIF
    EndIF

//Verificando se é possivel logar no Banco do Tss

IF (nConTSS := fConnttSS()) < 0   //Conectando com o Banco do Pims
	  // 0= não foi possivel conectar com o pims
	SetRestFault(500,EncodeUTF8('Não foi possivel conectar com o Banco de Dados do TSS.'))
	lRet    := .F.
	Return(lRet)
EndIF

cXmlEnv :=  fXmlCoop( cTod( Self:dDtxmlEmis ), nConProtheus,nConTSS  )

oResponse := JsonObject():New() 

oResponse:FromJson( cXmlEnv )
Self:SetResponse( oResponse:toJson() )

RestArea(aArea)
Return(.T.)

//Função que retorna o XMl dos Cooperados em data especifica
Static function fXmlCoop( cDtXML, nConProtheus,nConTss )

Local cQRYSF2		:= GetNextAlias()
Local cQRYSF1		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local cSqlfilter    := ''


//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cDtXML )
    cSqlfilter += " AND SF2.F2_EMISSAO = '" +  DTOS( cDtXML )  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

//Apontanto a conexão ao protheus
TcSetConn( nConProtheus )

    BeginSQL Alias cQRYSF2

    SELECT TOP 50 A1_XMATCOO, SF2.F2_CHVNFE,F2_FILIAL,A1_COD, A1_LOJA,A1_CGC,A1_INSCR FROM %table:SF2% SF2 
    INNER JOIN %table:SA1% SA1 ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.%notdel%
    WHERE SF2.%notdel%
        %exp:cSqlFilter%     // Filtra emissão
        AND SA1.A1_XCOOP = 'S'    //Indentifica que é cooperado.
        AND F2_CHVNFE != ' '
	EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSF2 )->( dBGotop() )

	While (cQRYSF2)->( !Eof() )

       cXml := ''

       cXML :=  fGetXML( ( cQRYSF2 )->F2_CHVNFE , nConTss )
       TcSetConn( nConProtheus )

       IF .not. Empty( cXml )

            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['idFilial'       ] := ALLTRIM((cQRYSF2)->F2_FILIAL)
			aJson[nPos]['idCooperado'    ] := ALLTRIM((cQRYSF2)->A1_COD)
            aJson[nPos]['ljaCooperado'   ] := ALLTRIM((cQRYSF2)->A1_LOJA)
            aJson[nPos]['cpfCnpj'        ] := ALLTRIM((cQRYSF2)->A1_CGC)
            aJson[nPos]['inscricao'      ] := ALLTRIM((cQRYSF2)->A1_INSCR)
            aJson[nPos]['xml'            ] := cXML
            aJson[nPos]['tipo'            ] := 'SAIDA'

        EndIF


         (cQRYSF2)->( DbSkip() )

    EndDo
    
    (cQRYSF2)->( DbCloseArea() )

// Lendo devoluções
cSqlFilter := ' '
IF !Empty( cDtXML )
    cSqlfilter += " AND SF1.F1_EMISSAO = '" +  DTOS( cDtXML )  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

BeginSQL Alias cQRYSF1

        SELECT TOP 50 F1_FILIAL , F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA,  F1_CHVNFE, A1_XMATCOO, A1_COD, A1_LOJA,A1_CGC,A1_INSCR FROM %table:SF1% SF1 
        INNER JOIN %table:SA1% SA1 ON SA1.A1_COD = F1_FORNECE AND SA1.A1_LOJA = F1_LOJA AND SA1.%notdel%
        WHERE SF1.%notdel%
            %exp:cSqlFilter%     // Filtra emissão
            AND SA1.A1_XCOOP = 'S'    //Indentifica que é cooperado.
            AND F1_CHVNFE != ' '
            AND F1_TIPO = 'D'           //Devolução
            AND F1_FORMUL != 'N'        //Formulario proprio
            AND F1_ESPECIE = 'SPED' 
        EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSF1 )->( dBGotop() )

	While (cQRYSF1)->( !Eof() )

       cXml := ''

       cXML :=  fGetXML( ( cQRYSF1 )->F1_CHVNFE , nConTss )
       TcSetConn( nConProtheus )

       IF .not. Empty( cXml )

            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['idFilial'       ] := ALLTRIM((cQRYSF1)->F1_FILIAL)
			aJson[nPos]['idCooperado'    ] := ALLTRIM((cQRYSF1)->A1_COD)
            aJson[nPos]['ljaCooperado'   ] := ALLTRIM((cQRYSF1)->A1_LOJA)
            aJson[nPos]['cpfCnpj'        ] := ALLTRIM((cQRYSF1)->A1_CGC)
            aJson[nPos]['inscricao'      ] := ALLTRIM((cQRYSF1)->A1_INSCR)
            aJson[nPos]['xml'            ] := cXML
            aJson[nPos]['tipo'           ] := 'DEVOLUCAO'

        EndIF

         (cQRYSF1)->( DbSkip() )

    EndDo
    
    (cQRYSF1)->( DbCloseArea() )

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
TCUNLINK( nConTss )
Return( cXmlEnv )


//==>> Função que conecta com o banco de dados do TSS  <<===
Static function fConnttSS()
//Dados do Server
Local cTopDataBase:= Supergetmv("MV_XTSSDB",.F.,"MSSQL/CAV45N_151705_TS_PD")  // "MSSQL/PIMS_TST"
Local cTopConType := "TCPIP"
Local cTopServer  := Supergetmv("MV_XTSSIP",.F.,"10.0.1.15") //'192.168.10.21' //"SRV-SQL"
Local nPort       := Supergetmv("MV_XTSPORT",.F.,7891) //"SRV-SQL" // 7890
Local nCon
Local lRet		  := .f.

	nCon := TCLink(cTopDataBase, cTopServer,nport)
	
	If  nCon < 0
	    
		Qout("Falha de conexão com o TOPConnect no servidor :") //"Falha de conexão com o TOPConnect"
		Qout("TopDataBase = " + cTopDataBase)
		Qout("TopServer   = " + cTopServer  )
		Qout("TopConType  = " + cTopConType ) 
		Return ( -1 )
	Else
	   
	   if TCSetConn( nCon ) == .F.
	   		Qout( "Could not change connection to " + cTopDataBase  )
	   		Return ( -1 ) 
	   	Else
	   		Return ( nCon )
	   	endif

	Endif

Return( nCon  )


//Busca chave na sped050
static function fGetXMl( cChveNFE,nConTSS )

Local cQRYXML		:= GetNextAlias()
Local cSqlfilter    := ''
Local cXml          := ''

IF !Empty( cChveNFE )
    cSqlFilter := " DOC_CHV = '" +  cChveNFE +"'"
EndIF

IF  Empty(cSqlFilter)
	cSqlFilter := "%%"
Else
	cSqlFilter := "% AND " + cSqlFilter + " %"
Endif

TcSetConn( nConTSS ) // Aponta para o bco do TSS


BeginSQL Alias cQRYXML
    Select  XML_SIG from SPED050 
    where 1 = 1
    %exp:cSqlFilter%     // Filtra Chave
EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )
( cQRYXML )->( dBGotop() )
// DBSELECTAREA( 'SPED050' )
// SPED050->(DBGOTO(cQRYXML->R_E_C_N_O_))

cXml:= (cQRYXML)->xml_sig

( cQRYXML )->( DBCLOSEAREA() )


Return( cXml )
