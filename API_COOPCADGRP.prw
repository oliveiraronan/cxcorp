#Include 'TOTVS.CH'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EbarnC06 ()
Return

WSRESTFUL ebarn_produtos DESCRIPTION "Serviço REST para retorno das Categorias de Produtos e seus Produtos"

//WSDATA CGRUPO //PINI  As Character //As String
//WSDATA CGRPFIM  As Character //As String
//WSDATA CITEMINI As Character //As String
//WSDATA CITEMFIM As Character //As String

//WSMETHOD GET categorias DESCRIPTION "Retorna o Cadastro das Categorias de Produtos e seus Produtos na URL" WSSYNTAX "/PRODUTOS/ebarn_categorias/" PRODUCES APPLICATION_JSON

WSMETHOD GET categorias  DESCRIPTION "Retorna o Cadastro das Categorias de Produtos e seus Produtos na URL" WSSYNTAX "/ebarn_produtos/" PRODUCES APPLICATION_JSON

END WSRESTFUL

//WSMETHOD GET categorias  WSRECEIVE WSRESTFUL  ebarn_categorias
WSMETHOD GET categorias  WSRECEIVE WSRESTFUL ebarn_produtos

Local aArea := GetArea()

SELF:SetContentType("application/json")
 
 /*
    IF Empty(Self:CGRUPO )
        SetRestFault(500,EncodeUTF8('O parametro Grupo/Familia deve ser indicado'))
        lRet    := .F.
        Return(lRet)
    EndIF
  */
    ////IF Empty( Self:CGRPFIM )
    ///   Self:CGRPFIM := ''
    ///    SetRestFault(500,EncodeUTF8('O parametro Inscrição do produtor é obrigatório'))
    ////    lRet    := .F.
    ///    Return(lRet)
    /// EndIF


cXmlEnv := fGetGrupos(/*Self:CGRUPO*/)

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
Static function fGetGrupos(/*cGrupo*/ )
///user function feme1( cGrupo )

Local cQRYSBM		:= GetNextAlias()


Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil

    BeginSQL Alias cQRYSBM

        SELECT  *  FROM  %table:SBM% SBM
        WHERE SBM.D_E_L_E_T_ <> '*'
        AND   SBM.BM_GRUPO IN ('0008','0047','0001', '0012', '5001' )

	EndSQL

    /*
Ração  0008
Herbicidas 0047
Agropecuária 0001
Milho 0012
Soja 5001 */

         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSBM )->( dBGotop() )

    DbSelectArea("SBM")
    DbSetOrder(1)

	While (cQRYSBM)->( !Eof() )
          
              Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['filial'       ] := Alltrim( (cQRYSBM)->BM_FILIAL )
            aJson[nPos]['idCategoria'  ] := Alltrim( (cQRYSBM)->BM_GRUPO  )
            aJson[nPos]['descricao'    ] := Alltrim( (cQRYSBM)->BM_DESC )
   
            aJsonSB1 := fGetItem( (cQRYSBM)->BM_FILIAL, (cQRYSBM)->BM_GRUPO  )
            aJson[Len(aJson)]['produtos'] := aJsonSB1  

         (cQRYSBM)->( DbSkip() )

    EndDo
    
    (cQRYSBM)->( DbCloseArea() )

WjSonAux    := JsonObject():new()
WjSonAux:set(aJson) 

cXmlEnv := '{'
cXmlEnv += '"FAMILIAS":'
cXmlEnv +=  WjSonAux:toJSON()
cXmlEnv +=  '}'

FreeObj( WjSonAux )
///EECVIEW(cXmlEnv,'validando qtd dos itens')
Return( cXmlEnv )

//Função que retorna o cadastro de produtos relacionado ao Grupo / Familia enviado
Static function fGetItem(cFilGrupo, cGrupo )
///user function feme1( cGrupo )

Local cQRYSB1		:= GetNextAlias()

Local aJson         := {}
Local nPos          := 0
Local WjSonAux      := nil
///Local cPath         := GetTempPath()
Local cTextoIMG        := ''

    BeginSQL Alias cQRYSB1

        SELECT  *  FROM  %table:SB1% SB1
        WHERE SB1.D_E_L_E_T_ <> '*'
        AND SB1.B1_GRUPO  = %exp:cGrupo%
        AND SB1.B1_FILIAL = %exp:cFilGrupo%

	EndSQL
         
	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
    //conout ( getLastQuery()[2] )

    ( cQRYSB1 )->( dBGotop() )

    DbSelectArea("SB1")
    DbSetOrder(1)

	While (cQRYSB1)->( !Eof() )

            //Get Imagem
            // VERIFICA SE O PRODUTO INFORMADO TEM IMAGEM CADASTRADA
            IF .not. Empty( (cQRYSB1)->B1_BITMAP )
                If (MsSeek( (cQRYSB1)->B1_FILIAL + (cQRYSB1)->B1_COD ))
                    // CASO O PRODUTO TENHA IMAGEM, EFETUA E EXTRAÇÃO PARA O ROOTHPATH
                     IF .not. ExistDir( "/temp/" )
                        MakeDir( "/temp" )
                     EndIF
                    If (RepExtract(AllTrim(SB1->B1_BITMAP), '/temp/' + Alltrim( (cQRYSB1)->B1_COD ) + ".bmp" , .T.))
                        oFile := FwFileReader():New('/temp/' +  Alltrim( (cQRYSB1)->B1_COD ) + ".bmp")

                        // EFETUA A MANIPULAÇÃO DO ARQUIVO
                        If (oFile:Open())
                            // RETORNA O ARQUIVO PARA DOWNLOAD
                            //Self:SetHeader("Content-Disposition", "attachment; filename=" + (cQRYSB1)->B1_COD + ".bmp")
                            //Self:SetResponse(oFile:FullRead())
                            cTextoIMG := Encode64( oFile:FullRead() )
                            // APAGA O ARQUIVO GERADO
                            FErase( (cQRYSB1)->B1_COD + (cQRYSB1)->B1_COD + ".bmp")
                            //Cria uma cópia do arquivo utilizando cTexto em um processo inverso(Decode64) para validar a conversão.    
                            ////nHandle := fcreate("C:\temp\emerso_pp.BMP")
                            ////FWrite(nHandle, Decode64(cTextoIMG))
                            ////fclose(nHandle) 
                        ////Else
                        ////    SetRestFault(002, "can't load file") // GERA MENSAGEM DE ERRO CUSTOMIZADA
                        EndIf
                    Else
                        ////SetRestFault(002, "can't load image")
                    EndIf
                Else // SE NÃO ACHA A IMAGEM
                    ////SetRestFault(404, "product image not found")
                EndIf

            EndIF       

            Aadd(aJson,JsonObject():new())
            nPos := Len(aJson)
            aJson[nPos]['ativo'         ] := IIF ( (cQRYSB1)->B1_MSBLQL == '1' , .F. , .T. )
            aJson[nPos]['codBarras'     ] := Alltrim( (cQRYSB1)->B1_CODBAR)
            aJson[nPos]['descricao'     ] := Alltrim( (cQRYSB1)->B1_DESC  )
            aJson[nPos]['filial'        ] := Alltrim( (cQRYSB1)->B1_FILIAL)
            aJson[nPos]['idCategoria'   ] := Alltrim( (cQRYSB1)->B1_GRUPO )
            aJson[nPos]['idProduto'     ] := Alltrim( (cQRYSB1)->B1_COD   )
            aJson[nPos]['informacaoTecnica'] := ''
            aJson[nPos]['preco'         ] := 0
            aJson[nPos]['unidadeMedida' ] := Alltrim( (cQRYSB1)->B1_UM )
            aJson[nPos]['imagem'        ] := cTextoIMG    

         (cQRYSB1)->( DbSkip() )

    EndDo
    
    (cQRYSB1)->( DbCloseArea() )

Return( aJson )


