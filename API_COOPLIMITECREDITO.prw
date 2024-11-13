#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EbarnC08 ()
Return

WSRESTFUL ebarn_limiteCredito DESCRIPTION "Serviço REST para retorno do Saldo de limite de credito do cooperado"

WSDATA cnpjCpf As Character //As String

WSMETHOD GET saldos DESCRIPTION "Retorno do Saldo de limite de credito do cooperado na URL" WSSYNTAX "/ebarn_limiteCredito/" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET saldos  WSRECEIVE WSRESTFUL  ebarn_limiteCredito  

Local aArea := GetArea()

SELF:SetContentType("application/json")

   
    IF Empty(Self:cnpjCpf )
        SetRestFault(500,EncodeUTF8('O parametro CPF/CNPJ do Cooperado deve ser informado.'))
        lRet    := .F.
        Return(lRet)
    EndIF

    ////IF Empty( Self:CGRPFIM )
    ///   Self:CGRPFIM := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
    /// EndIF


cXmlEnv := fGetSldCre(Self:cnpjCpf )

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

//Função que retorna o Sldo. de Limite de Credito do  protheus do cliente ///
Static function fGetSldCre( cnpjCpf  )
////user function femeA( cnpjCpf , aSldLimite  )

Local cQRYSA1		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

Local nSaldo        := 0
Local aInfSldCre    := {}
Local nIdx          := 0
Local nIdx1         := {}

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

            //U_CMV06M04( (cQRYSA1)->A1_COD,'4', aSldLimite )


             aSldLimite := fCalcLimit( (cQRYSA1)->A1_COD )
             
            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            
            For nIdx := 1 to Len( aSldLimite )

                aJson[nPos][ aSldLimite [nIdx, 1] ] :=  aSldLimite [nIdx, 2]

            nExt nIdx

         (cQRYSA1)->( DbSkip() )

    EndDo
    
    (cQRYSA1)->( DbCloseArea() )

WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

cXmlEnv := '{'
cXmlEnv += '"LimiteCredito":'
cXmlEnv +=  WjSonAux:toJSON()
cXmlEnv +=  '}'

FreeObj( WjSonAux )
///EECVIEW(cXmlEnv,'SldCotaCapital')
Return( cXmlEnv )

#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"

#DEFINE ENTER Chr(10)+Chr(13)

/*
função baseada na CMV06M04 que retorna o Limite de credito do cooperado ...
Rotina que calcula o limite de credito da comiva 

*/

sTatic Function fCalcLimit( cCodCli )
//User Function ftstCALC(cCodCli )
	Local xArea			:= GetArea()
	Local cFormaPag		:= ''
	Local lValidLim		:= .T.
    Local ASLDLIMITE    := {}

	Private nSaltit		:= 0										//SALDO DE Titulos
	Private nAbatim		:= 0										//VALOR DO ABATIMENTO
	Private nSalPed		:= 0										//SALDO DE PEDIDOS
	Private nSaldo		:= 0										//SALDO TOTAL EM ABERTO DO CLIENTE	
	Private nValLim		:= 0										//VALOR DO LIMITE
	Private nSalAtu		:= 0										//LIMITE MENOS SALDO EM ABERTO
	Private nValVenda	:= 0										//VALOR TOTAL DA VENDA
	Private nDif		:= 0										//Limite ultrapassado em										
	Private cCliente	:= cCodCli									//CODIGO DO CLIENTE
	Private cLoja		:= "01"//cLojCli							//LOJA DO CLIENTE
	///Private cOrigem		:= cOriSoli									//Origem da solicitação
	Private cFormas		:= SUPERGETMV('CM_FORMPG',.F.,'R$/CD/CC/VF')//FORMAS QUE NÃO SERÃO VALIDADAS
	Private cPedido		:= ""										//Em caso de alteração armazena o pedido atual
	Private cTes		:= ""
	Private _ccond 		:= ""
	Private _ccpf		:= Posicione("SA1",1,XFilial("SA1")+cCliente+cLoja,'A1_CGC')	//Cpf do cliente
	Private _aret		:= FVerFunc(_ccpf)

	DbSelectArea('SA1')
	SA1->(DbSetOrder(1))

	DbSelectArea('SX5')
	SX5->(DbSetOrder(1))

	DbSelectArea('ZZ1')
	ZZ1->(DbSetOrder(1))
	
	//Não valida formas definida no parametro.
	IF !(cFormaPag $ cFormas)
		If !ZZ1->(DbSeek(XFilial('ZZ1')+cCliente+'01'+cFormaPag))
			nValLim	:= 0
		Else
			//POSICIONA NO PRIMEIRO LIMITE DO CLIENTE
			nValLim := Posicione("ZZ1",1,XFilial('ZZ1')+cCliente+'01',"ZZ1_VALLIM")
		EndIf
		
		lValidLim	:= .T.
	ELSE
		lValidLim	:= .F.
	ENDIF

		//Função para Consulta de Limite
		//SALDO EM ABERTO DO CLIENTE
		nSaldo := FSalCli( )

		nDif	:=  nValLim - nSaltit + nAbatim - nSalPed - nValVenda 

		aAdd(aSldLimite,{'SLDOLIMITE',nValLim})

		aAdd(aSldLimite,{'SLDOTITULOS',nSaltit})

		aAdd(aSldLimite,{'VRABATIMENTOS',nAbatim})

		aAdd(aSldLimite,{'SLDOPEDIDOS',nSalPed})

		aAdd(aSldLimite,{'VRPEDIDO',nValvenda})

	If nDif >= 0 
		aAdd(aSldLimite,{'LIMITEDISP',Abs(nDif)})
	Else
		aAdd(aSldLimite,{'LIMITEULTR',Abs(nDif)})
	EndIf

	RestArea(xArea)

Return(aSldLimite)

/*--------------------------------------------------------------------------------------*
| Função		:	FSalCli	                        	                       			|
| Autor			:	Erivaldo                                                    		|
| Data			:	??????????                                                  		|
| Descrição		:	CALCULA O SALDO DEVEDOR DO CLIENTE (SE1)							|
| Parametros	:																		|  
| Observação	:		                                                          		|
*--------------------------------------------------------------------------------------*/

Static Function FSalCli()
	Local cAlias  := GetNextAlias()
	Local cWhere	:= ""
	Local cWhere2	:= ""
	Local cWhereFp	:= ""
	Local nSaldo	:= 0
	Private cFormas2	:= STRSQL(cFormas)

	cWhere := "SE1.E1_TIPO NOT IN ('RA ','NCC','AB-','R$ ','CD ','CC','VF')"
	cWhere := '%'+cWhere+'%'
	
	//Verificar parametro de validação da forma de pagamento
	cWhere2 := "SE1.E1_XFORMPG NOT IN ('R$ ','CD ','CC','VF')"
	cWhere2 := '%'+cWhere2+'%'

	//CONTAS A RECEBER
	BeginSql Alias cAlias

		SELECT 
			SUM(E1_SALDO) AS SALDO
		FROM
			%TABLE:SE1% SE1
		WHERE
			SE1.E1_CLIENTE = %Exp:cCliente% AND
			SE1.E1_EMISSAO <= %Exp:DTOS(date() )% AND
			%Exp:cWhere% AND
			%Exp:cWhere2% AND
			SE1.%NotDel%
	EndSQL

	nSaltit	:= (cAlias)->SALDO
	
	aQry	:= GetLastQuery()
	//MemoWrite(GetTempPath()+'FSalCliContasReceber.sql',aQry[2])
	
	(cAlias)->(dbCloseArea())

	cWhere := "SE1.E1_TIPO IN ('RA ','NCC','AB-')"
	cWhere := '%'+cWhere+'%'

	//Abatimentos
	BeginSql Alias cAlias
	
		SELECT 
			SUM(E1_SALDO) AS SALDO
		FROM 
			%TABLE:SE1% SE1
		WHERE 
			SE1.E1_CLIENTE = %Exp:cCliente% AND
			SE1.E1_EMISSAO <= %Exp:DTOS(date() )% AND
			%Exp:cWhere% AND
			SE1.%NotDel%	
	EndSQL
	
	aQry	:= GetLastQuery()
	//MemoWrite(GetTempPath()+'FSalCliAbatimentos.sql',aQry[2])

	nAbatim	:= (cAlias)->SALDO

	(cAlias)->(dbCloseArea())

	cWhereFp := "SCV.CV_FORMAPG NOT IN "+cFormas2
	cWhereFp:= '%'+cWhereFp+'%'

	//PEDIDO DE VENDA
	BeginSql Alias cAlias
		
		SELECT
		 	SUM(((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN) + ((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN) * (E4_ACRSFIN / 100))  AS SALDOPED
		FROM
		 	%TABLE:SC5% SC5
			LEFT JOIN %TABLE:SC6% SC6
			ON	SC5.C5_NUM 		= SC6.C6_NUM AND
				SC5.C5_CLIENTE	= SC6.C6_CLI AND
				SC5.C5_LOJACLI	= SC6.C6_LOJA
			LEFT JOIN %TABLE:SCV% SCV
			ON	SC5.C5_FILIAL	= SCV.CV_FILIAL AND
			 	SC5.C5_NUM 		= SCV.CV_PEDIDO
			LEFT JOIN %TABLE:SE4% SE4
			ON SC5.C5_CONDPAG 	= SE4.E4_CODIGO
		WHERE
			SC5.C5_CLIENTE	=	%Exp:cCliente% AND
			SC6.C6_NOTA		=	%Exp:''% AND
			SC5.C5_LIBEROK  =	%Exp:'S'% AND
			SC6.C6_BLQ		<> 	%Exp:'R'% AND
			SC6.C6_NUM		<> 	%Exp:CPEDIDO% AND
			%Exp:cWhereFp% AND
			SC5.%NotDel% AND
			SC6.%NotDel% AND
			SE4.%NotDel%
	EndSQL
	
	aQry	:= GetLastQuery()
	//MemoWrite(GetTempPath()+'FSalCliPedidoDevenda.sql',aQry[2])

	nSalPed	:= A410Arred((cAlias)->SALDOPED , "C5_DESC4")

	(cAlias)->(dbCloseArea())

	nSaldo	:= nSaltit - nAbatim + nSalPed
	
Return nSaldo

/*--------------------------------------------------------------------------------------*
| Função		:	STRSQL                                                   			|
| Autor			:	Erivaldo                                                   			|
| Data			:	??????????                                                  		|
| Descrição		:	Formata Formas														|
| Parametros	:																		|  
| Observação	:		                                                          		|
*--------------------------------------------------------------------------------------*/
//String para SQL (IN)
Static Function STRSQL(cFormas)
Local cpar	:= cFormas
Local cret	:= "('"
Local cAux	:= ""
Local nX	:= 0

cpar	:= strtran(cpar,"'","")		//Retira apóstrofo
cpar	:= strtran(cpar,"/",",")		//substitui barra por vírgula

For nX := 1 To Len(cpar)
	cAux := Substr(cpar,nX,1)
	If ',' <> cAux
		cret	:= cret+cAux
	Else
		cret	:= cret+"'"+cAux+"'"
	EndIf
Next nX

cret	:= cret+"')"
Return(cret)


//Verifica se é funcionário e o limite.
static function FVerFunc(_ccpf)
	Local _calias		:= getnextalias()
	Local _aret			:= {}
	Local _zarea		:= getarea()
	Local _ccatlimc		:= getmv('CM_CATLIMC')		//Categoria(s) que entra(m) no cálculo do limite.
	Local _cwhere		:= ""						//Condiçao para consulta SQL, com base nos parametros.
	
	If len(_ccatlimc) > 0
		_cwhere := "sra.ra_categ in "+_ccatlimc
		_cwhere := '%'+_cwhere+'%'
	Else
		MSGSTOP("O parâmetro CM_CATLIMC não está preenchido corretamente, favor entrar em contato com o TI.")
		return .f.
	EndIf
	
	beginsql alias _calias
		select ra_filial, ra_mat, ra_nome, ra_xlimcom, ra_admissa
		from %table:SRA% sra
		where sra.ra_cic = %Exp:_ccpf%
		and %exp:_cwhere%
		and sra.ra_sitfolh <> %Exp:'D'%
		and sra.%notdel%
	endsql 
	
	aqry	:= getlastquery()

	If !Empty((_calias)->ra_mat)
		aadd(_aret,{.t.,(_calias)->ra_xlimcom,(_calias)->ra_mat,(_calias)->ra_nome,(_calias)->ra_admissa,(_calias)->ra_filial})
	Else
		aadd(_aret,{.f.,(_calias)->ra_xlimcom,(_calias)->ra_mat,(_calias)->ra_nome,(_calias)->ra_admissa,(_calias)->ra_filial})	
	Endif
	
	/*_aret
	/*1 - E funcionario?
	/*2 - Valor do limite
	/*3 - Matricula do Funcionario
	/*4 - Nome do Funcionario
	/*5 - Data de Admissao
	/*6 - Filial do Funcionario
	*/

	(_calias)->(dbclosearea())

	restarea(_zarea)
return(_aret)
