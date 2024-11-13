#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EbarnC03 ()
Return

WSRESTFUL ebarn_posContasReceber DESCRIPTION "Serviço REST para retorno posicao financeira a Receber"

WSDATA CnpjCpf As Character //As String
///WSDATA Inscricao As Character //As String

WSMETHOD GET posicaoContasReceber DESCRIPTION "Retorna Posicão Financeira a Receber na URL" WSSYNTAX "/ebarn_posContasReceber/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET posicaoContasReceber  WSRECEIVE WSRESTFUL  ebarn_posContasReceber  

Local aArea := GetArea()


SELF:SetContentType("application/json")
    /*
    obrigatorio informar o numero do pedido
    */
    IF Empty(Self:CnpjCpf)
        SetRestFault(500,EncodeUTF8('O parametro CNPJ/CPJ do produtor é obrigatório'))
        lRet    := .F.
        Return(lRet)
    EndIF

    /*
    IF Empty( Self:Inscricao )
       Self:Inscricao := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
     EndIF
    */

cXmlEnv := fVrsaReceb(Self:CnpjCpf) //, Self:Inscricao)

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


//Função que encontra os vrs. financeiros a Pagar do Cooperado informado....
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
       nCrecAVnc:= fCRecAVcer(cCnpjCpf, cInscr, ALLTRIM((cQRYSM0)->M0_CODFIL) )
	   nCrecVcdo:=0
	   nCrecVcdo:= fCRecVcdos(cCnpjCpf, cInscr, ALLTRIM((cQRYSM0)->M0_CODFIL) )

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

//Função que encontra os vrs. financeiros a Pagar do Cooperado informado....
//Atenção a Posição financeira do cooperado é  A PAGAR da cooperativa
Static function fCRecVcdos(cCnpjCpf, cInscr,cFilAux)

Local cAliasQRY		:= GetNextAlias()
Local cDtAtual      := dtos( ddatabase )
Local nCrecAVnc     := 0
Local nVrVencdo     := 0

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cInscr )
    cSqlfilter += " AND SA2.A2_INSCR = '" + cInscr  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

BeginSQL Alias cAliasQRY

        SELECT  SE2.E2_FILIAL,
                SA2.A2_NOME, 
                SA2.A2_INSCR, 
                SA2.A2_CGC, 
                SA2.A2_LOJA,
                SUM(E2_SALDO) SALDO

        FROM  %table:SE2% SE2
        INNER JOIN  %table:SA2% SA2 ON SA2.A2_COD = SE2.E2_FORNECE AND SA2.A2_LOJA = SE2.E2_LOJA AND SA2.D_E_L_E_T_ = ' '

        WHERE SE2.D_E_L_E_T_ <> '*'

         %exp:cSqlFilter% 
        AND SE2.E2_Filial = %exp:cFilAux%
        AND SE2.E2_SALDO > 0
        AND  SE2.E2_TIPO != 'PA'
        AND SE2.E2_VENCTO < %exp:cDtAtual%
        AND SA2.A2_CGC = %exp:cCnpjCpf%
    
         GROUP BY SE2.E2_FILIAL, SA2.A2_NOME, SA2.A2_INSCR, SA2.A2_CGC, SA2.A2_LOJA
	EndSQL

     ////   AND SA2.A2_INSCR = %exp:cInscr%
          
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    (cAliasQRY)->( dBGotop() )

	
	While (cAliasQRY)->( !Eof() )
      
         nVrVencdo += (cAliasQRY)->SALDO
        
        (cAliasQRY)->( Dbskip() )

    EndDo
    
    (cAliasQRY)->( DbCloseArea() )

Return( nVrVencdo )

//Função que Verifica  o vr. a receber por filial 

static function fCRecAVcer(cCnpjCpf, cInscr, cFilAux)
Local nVrAVencer   := 0
Local cAliasQRY		:= GetNextAlias()
Local cDtAtual      := dtos( ddatabase )

Local cSqlfilter    := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cInscr )
    cSqlfilter += " AND SA2.A2_INSCR = '" + cInscr  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif

    BeginSQL Alias cAliasQRY

        SELECT  SE2.E2_FILIAL,
                SA2.A2_NOME, 
                SA2.A2_INSCR, 
                SA2.A2_CGC, 
                SA2.A2_LOJA,
                SUM(E2_SALDO) SALDO

        FROM  %table:SE2% SE2
        INNER JOIN  %table:SA2% SA2 ON SA2.A2_COD = SE2.E2_FORNECE AND SA2.A2_LOJA = SE2.E2_LOJA AND SA2.D_E_L_E_T_ = ' '

        WHERE SE2.D_E_L_E_T_ <> '*'
        //AND SE2.E2_FILIAL BETWEEN '' AND 'ZZZZZZZZ'
        //AND SE2.E2_EMISSAO BETWEEN '' AND 'ZZZZZZZ'
        //AND SE2.E2_NATUREZ BETWEEN '' AND 'ZZZZZZZZ'
        //AND SE2.E2_PREFIXO BETWEEN '' AND 'ZZZZZZZZZ'
        //AND SE2.E2_BAIXA BETWEEN '' AND 'ZZZZZZZ'
        %exp:cSqlFilter% 
        AND SE2.E2_Filial = %exp:cFilAux%
        AND SE2.E2_SALDO > 0
        AND  SE2.E2_TIPO != 'PA'
        AND SE2.E2_VENCTO >= %exp:cDtAtual%
        AND SA2.A2_CGC = %exp:cCnpjCpf%
        ///AND SA2.A2_INSCR = %exp:cInscr%

        GROUP BY SE2.E2_FILIAL, SA2.A2_NOME, SA2.A2_INSCR, SA2.A2_CGC, SA2.A2_LOJA

	EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')


    (cAliasQRY)->( dBGotop() )
	
	While (cAliasQRY)->( !Eof() )

        nVrAVencer += (cAliasQRY)->SALDO
        
        (cAliasQRY)->( Dbskip() )
    EndDo
    
    (cAliasQRY)->( DbCloseArea() )

Return (nVrAVencer)
