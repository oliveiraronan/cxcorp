#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EbarnC04 ()
Return

WSRESTFUL ebarn_ctrsDepTerceiros DESCRIPTION "Serviço REST para retorno dos Contratos Deposito Terceiros"

WSDATA CnpjCpf As Character //As String
WSDATA Inscricao As Character //As String

WSMETHOD GET contratosDeposito DESCRIPTION "Retorna Lista de Contratos Deposito de terceiros na URL" WSSYNTAX "/ebarn_ctrsDepTerceiros/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET contratosDeposito  WSRECEIVE WSRESTFUL  ebarn_ctrsDepTerceiros  

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

    IF Empty( Self:Inscricao )
       Self:Inscricao := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
     EndIF

cXmlEnv := fCTRDEPOS(Self:CnpjCpf, Self:Inscricao)

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
Static function fCTRDEPOS(cCnpjCpf, cInscr)
///user function feme1(cCnpjCpf, cInscr)

Local cQRYNJ0		:= GetNextAlias()
Local cQRYNJR		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local cSqlfilter    := ''
Local cProdDesc     := ''

//Somente concidera inscrição se ela vier preenchida ...
IF !Empty( cInscr )
    cSqlfilter += " AND NJ0.NJ0_INSCR = '" + cInscr  + "'"
EndIF

If Empty(cSqlFilter)
		cSqlFilter := "%%"
Else
		cSqlFilter := "% " + cSqlFilter + " %"
Endif


BeginSQL Alias cQryNJ0

        SELECT  NJ0.NJ0_FILIAL, NJ0.NJ0_CODENT, NJ0.NJ0_LOJENT
        FROM  %table:NJ0% NJ0
        WHERE NJ0.D_E_L_E_T_ <> '*'
        %exp:cSqlFilter%
        AND NJ0.NJ0_CGC = %exp:cCnpjCpf%

	EndSQL
   
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    (cQryNJ0)->( dBGotop() )

	
	While (cQryNJ0)->( !Eof() )

    // Ler os contratos referente a entidade informada ...

    ///Encontrando a Filial do Contrato ...
       
       BeginSQL Alias cQryNJR

        SELECT  NJR.NJR_FILIAL, NJR.NJR_CODCTR, NJR.NJR_CODSAF, NJR.NJR_QTDCTR , NJR.NJR_CODPRO, NJR.NJR_UM1PRO
            FROM  %table:NJR% NJR
            WHERE NJR.D_E_L_E_T_ <> '*'
            AND NJR.NJR_CODENT = %exp:(cQryNJ0)->NJ0_CODENT%
            AND NJR.NJR_LOJENT = %exp:(cQryNJ0)->NJ0_LOJENT%
            AND NJR.NJR_TIPO = '3'
            AND NJR.NJR_STATUS IN ( 'A' , 'I' )   /*P=Previsto;A=Aberto;I=Iniciado;E=Cancelado;F=Finalizado      */                                                                   

	    EndSQL

        While (cQryNJR)->( !Eof() )

            cProdDesc := Posicione('SB1',1,xFilial('SB1')+(cQryNJR)->NJR_CODPRO,'B1_DESC')
            //Busca os dados dos contratos Encontrados ...

            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['filial'            ] := (cQryNJR)->NJR_FILIAL
            aJson[nPos]['idcontrato'        ] := (cQryNJR)->NJR_CODCTR
            aJson[nPos]['safra'             ] := (cQryNJR)->NJR_CODSAF 
            aJson[nPos]['qtContrato'        ] := (cQryNJR)->NJR_QTDCTR
            aJson[nPos]['idproduto'         ] := (cQryNJR)->NJR_CODPRO
            aJson[nPos]['descricaoProduto'  ] := alltrim( cProdDesc )
            aJson[nPos]['unidadeMedida'     ] := alltrim( (cQryNJR)->NJR_UM1PRO)

            (cQryNJR)->( !Dbskip() )

        EnddO

         (cQryNJR)->( !DbCloseArea() )

        (cQryNJ0)->( !Dbskip() )

    EndDo
    
    (cQryNJ0)->( !DbCloseArea() )


WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

///cXmlEnv := '{'
///cXmlEnv += '"Contratos":'
///cXmlEnv +=  WjSonAux:toJSON()
///cXmlEnv +=  '}'
cXmlEnv :=  WjSonAux:toJSON()

FreeObj( WjSonAux )

///EECVIEW(cXmlEnv,'validando qtd dos itens')

Return( cXmlEnv )

