*** Settings ***
##########################################################################
#                                 Settings                               #
##########################################################################
Library  RequestsLibrary
Library  FakerLibrary


*** Variables ***
##########################################################################
#                                 Variables                              #
##########################################################################
${token}


${base_viacep}       https://viacep.com.br/
${base_herokuapp}    https://api-de-tarefas.herokuapp.com

&{lista_ceps}
...  cep1=07176690
...  cep2=01007050
...  cep3=01007080
...  cep4=01007040
...  cep5=01012030
...  cep6=01034020
...  cep7=01023050
...  cep8=01012010
...  cep9=01007010
...  cep10=01014010
        
*** Test Cases ***
##########################################################################
#                                 Test Cases                             #
##########################################################################
Efetuar GET de CEP no site viacep com - Exemplo GET
    Dado que efetuo o GET no site informando um CEP
    Então devo ter o endereço referente a esse CEP retornado com sucesso    

Efetuar cadastro de uma nova pessoa via method POST na API api-de-tarefas.herokuapp
    Dado que efetuo envio da cadastro de uma nova pessoa para API api-de-tarefas.herokuapp
    Então devera ser cadastrado com sucesso e retornar o body da API com sucesso 

Efetuar listagem de contatos
    Dado que efetuar GET na API api-de-tarefas.herokuapp
    Então retornar os dados com sucesso

Efetuar a exclusão de contatos
    Delete contatos da API api-de-tarefas.herokuapp

##########################################################################
#                                 Keywords                               #
##########################################################################
*** Keywords ***
Dado que efetuo o GET no site informando um CEP
   ${i}  FakerLibrary.random int  min=1  max=10
   EXECUTE     GET     /ws/${lista_ceps.cep${i}}/json/    ${base_viacep} 
   [Return]  ${response.status_code}  ${response.json()}


Então devo ter o endereço referente a esse CEP retornado com sucesso
   Log To Console    Status code: ${response.status_code}
   Log To Console    Dado retornados do endereço:${response.json()}
   Log    Status code: ${response.status_code}
   Log    Dado retornados do endereço:${response.json()}


##########################################################################
#                                 Proximo teste                          #
##########################################################################
Dado que efetuo envio da cadastro de uma nova pessoa para API api-de-tarefas.herokuapp
    ${nome}     FakerLibrary.File Name
    ${nome_l}     FakerLibrary.Last Name
    ${email}     FakerLibrary.Email
    ${numero}     FakerLibrary.Numerify
    ${endereco}     FakerLibrary.Address
    ${city}     FakerLibrary.City
    ${State}     FakerLibrary.State
    ${idade}  FakerLibrary.random int  min=1  max=10


    &{body}  Create Dictionary
    ...  name=${nome}
    ...  last_name=${nome_l} 
    ...  email=${email}
    ...  age=${idade}
    ...  phone=${numero}
    ...  address=${endereco}
    ...  state=${State} 
    ...  city=${city}
    ${response}  EXECUTE    POST    /contacts  ${base_herokuapp}     ${body}
    [Return]  ${response.status_code}  ${response.json()}

Então devera ser cadastrado com sucesso e retornar o body da API com sucesso  
    Log To Console    ${response.status_code}
    Log To Console    ${response.json()}
    Log     ${response.status_code}
    Log     ${response.json()}

Dado que efetuar GET na API api-de-tarefas.herokuapp
   EXECUTE     GET     /contacts    ${base_herokuapp}
   [Return]  ${response.status_code}  ${response.json()}

Então retornar os dados com sucesso
    Log To Console    ${response.status_code}
    Log To Console    ${response.json()}
    Log     ${response.status_code}
    Log     ${response.json()}


Delete contatos da API api-de-tarefas.herokuapp
   ${id}  FakerLibrary.random int  min=1  max=10
   EXECUTE     DELETE     /contacts?id=${id}    ${base_herokuapp}
   [Return]  ${response.status_code}  #${response.json()}
    
    
##########################################################################
#                                 Global API                             #
##########################################################################
EXECUTE
    [Arguments]  ${method}  ${endpoint}  ${link}   ${body}=None

    ${headers}  Authorization Headers  ${token}
    
    IF  $method.upper() == 'POST'
        ${response}  POST
        ...  url=${link}${endpoint}
        ...  json=${body}
        ...  headers=${headers}
        ...  expected_status=any        
    ELSE IF  $method.upper() == 'PATCH'
        ${response}  PATCH
        ...  url=${link}${endpoint}
        ...  json=${body}
        ...  headers=${headers}
        ...  expected_status=any
    ELSE IF  $method.upper() == 'DELETE'
        ${response}  DELETE
        ...  url=${link}${endpoint}
        ...  headers=${headers}
        ...  expected_status=any
    ELSE
        IF  ${body} != None
            ${response}  GET
            ...  url=${link}${endpoint}
            ...  json=${body}
            ...  headers=${headers}
            ...  expected_status=any
        ELSE
            ${response}  GET
            ...  url=${link}${endpoint}
            ...  headers=${headers}
            ...  expected_status=any
        END
    END
    Set Suite Variable    ${response}
    #Sleep  10
    [Return]  ${response}


Authorization Headers
    [Arguments]  ${token}  ${content_type}=application/json

    &{headers}  Create Dictionary
    ...  Authorization=${token}
    ...  Content-Type=${content_type}
    [Return]  ${headers}