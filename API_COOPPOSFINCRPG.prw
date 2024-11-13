#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EbarnC02 ()
Return

WSRESTFUL ebarn_posContasPagar DESCRIPTION "Serviço REST para retorno posicao financeira a Pagar cooperado"

WSDATA CnpjCpf As Character //As String
WSDATA Inscricao As Character //As String

WSMETHOD GET posicaoContasPagar DESCRIPTION "Retorna Posicão Financeira a Pagar do Cooperado na URL" WSSYNTAX "/ebarn_posContasPagar/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET posicaoContasPagar  WSRECEIVE WSRESTFUL  ebarn_posContasPagar  

 aArea := GetArea()

SELF:SetContentType("application/json")
    /*
    obrigatorio informar o numero do pedido
    */
    IF Empty(Self:CnpjCpf)
        SetRestFault(500,EncodeUTF8('O parametro CNPJ/CPJ do produtor é obrigatório'))
        lRet    := .F.
        Return(lRet)
    EndIF

    IF Empty( Self:Inscricao )
       Self:Inscricao := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
     EndIF

cXmlEnv := fVrsaReceb(Self:CnpjCpf, Self:Inscricao)

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
Static function fVrsaReceb(cCnpjCpf, cInscr)
 ////user function feme(cCnpjCpf, cInscr)

Local cQRYSM0		:= GetNextAlias()
Local nCrecAVnc     := 0
Local nCrecVcdo     := 0

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local cSqlfilter    := ''

   BeginSQL Alias cQRYSM0

        SELECT  *  FROM  SYS_COMPANY
        WHERE  SYS_COMPANY.D_E_L_E_T_ <> '*'

	EndSQL
         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSM0 )->( dBGotop() )

	While (cQRYSM0)->( !Eof() )

       nCrecAVnc:=0
       nCrecAVnc:= fCPagAVcer(cCnpjCpf, cInscr, ALLTRIM((cQRYSM0)->M0_CODFIL) )
	   nCrecVcdo:=0
	   nCrecVcdo:= fCPagVcdos(cCnpjCpf, cInscr, ALLTRIM((cQRYSM0)->M0_CODFIL) )

        Aadd(aJson,JsonObject():new())
        nPos := Len(aJson)
        aJson[nPos]['FILIAL '         ]  :=  ALLTRIM((cQRYSM0)->M0_CODFIL)
        aJson[nPos]['SaldoVencdo'     ]  := nCrecVcdo
        aJson[nPos]['SaldoAVencer'    ] := nCrecAVnc

        (cQRYSM0)->( Dbskip() )

    EndDo
    
    (cQRYSM0)->( !DbCloseArea() )

WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

///cXmlEnv := '{'
///cXmlEnv += '"PosFinFiliais":'
///cXmlEnv +=  WjSonAux:toJSON()
///cXmlEnv +=  '}'

cXmlEnv := WjSonAux:toJSON()

///    Self:SetResponse(oResponse:toJson())

FreeObj( WjSonAux )

Return( cXmlEnv )



//Função que encontra os vrs. financeiros a Receber do Cooperado informado....
//Atenção a Posição financeira do cooperado é  A PAGAR da cooperativa
Static function fCPagVcdos(cCnpjCpf, cInscr,cFilAux)
////user function feme(cCnpjCpf, cInscr)

Local cAliasQRY		:= GetNextAlias()
Local cDtAtual      := dtos( ddatabase )
Local nVrVencdo     :=0

Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cInscr )
    cSqlfilter += " AND SA1.A1_INSCR = '" + cInscr  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

BeginSQL Alias cAliasQRY

        SELECT  SE1.E1_FILIAL,
                SA1.A1_CGC, 
                SUM(E1_SALDO) SALDO

        FROM  %table:SE1% SE1
        INNER JOIN  %table:SA1% SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' '

        WHERE SE1.D_E_L_E_T_ <> '*'
         %exp:cSqlFilter% 
        AND SE1.E1_Filial = %exp:cFilAux%
        AND SE1.E1_SALDO > 0
        AND  SE1.E1_TIPO != 'PA'
        AND SE1.E1_VENCTO < %exp:cDtAtual%
        AND SA1.A1_CGC = %exp:cCnpjCpf%
         GROUP BY SE1.E1_FILIAL, SA1.A1_CGC
	EndSQL

	nSldLteTot	:= 0

    (cAliasQRY)->( dBGotop() )

////EECVIEW(getLastQuery()[2],'validando qtd dos itens')

    (cAliasQRY)->( dBGotop() )
	
	While (cAliasQRY)->( !Eof() )

        nVrVencdo += (cAliasQRY)->SALDO
        
        (cAliasQRY)->( Dbskip() )
    EndDo
    
    (cAliasQRY)->( DbCloseArea() )

Return( nVrVencdo )

//Função que Verifica  o vr. a receber por filial 

static function fCPagAVcer(cCnpjCpf, cInscr,cFilAux)
Local nVrAVencer   := 0
Local cAliasQRY		:= GetNextAlias()
Local cDtAtual      := dtos( ddatabase )

Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cInscr )
    cSqlfilter += " AND SA1.A1_INSCR = '" + cInscr  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

    BeginSQL Alias cAliasQRY

        SELECT  SE1.E1_FILIAL,
                SA1.A1_NOME, 
                SA1.A1_INSCR, 
                SA1.A1_CGC, 
                SA1.A1_LOJA,
                SUM(E1_SALDO) SALDO

        FROM  %table:SE1% SE1
        INNER JOIN  %table:SA1% SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' '

        WHERE SE1.D_E_L_E_T_ <> '*'

        %exp:cSqlFilter% 
        AND SE1.E1_Filial = %exp:cFilAux%
        AND SE1.E1_SALDO > 0
        AND  SE1.E1_TIPO != 'PA'
        AND SE1.E1_VENCTO >= %exp:cDtAtual%
        AND SA1.A1_CGC = %exp:cCnpjCpf%
        ///AND SA1.A1_INSCR = %exp:cInscr%

        GROUP BY SE1.E1_FILIAL, SA1.A1_NOME, SA1.A1_INSCR, SA1.A1_CGC, SA1.A1_LOJA

	EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')

    (cAliasQRY)->( dBGotop() )
	
	While (cAliasQRY)->( !Eof() )

        nVrAVencer += (cAliasQRY)->SALDO
        
        (cAliasQRY)->( Dbskip() )
    EndDo
    
    (cAliasQRY)->( DbCloseArea() )

Return (nVrAVencer)
