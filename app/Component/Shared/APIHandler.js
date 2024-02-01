import { APIRoute, GetToken, GetUserData } from "./APIRoutes";

class APIError extends Error{}

class AuthError extends Error{}
class HTTPError extends APIError{
    constructor(message,response){
        super(message);
        this.response = response;
    }

}

export const APIHandler = {


    token:'',
    refresh_token:'',
    user_data:{student_id:0},

    //Tries to send request but does not guarantee delivery, will throw an error if token is not working.
    TryRequest: async function(request) {

            if(!(request instanceof APIRoute)) throw new APIError('Request is not of type APIRoute');

            try{

                request.Populate(this.token,this.user_data.student_id, this.refresh_token).Build();

            }
            catch(error){
                throw new APIError(`Invalid Request.(${error.message})`);
            }

            console.log(request.query_params.string);

        return await fetch(request.url,{
            method:request.method,
            headers:request.headers,
            body:request.query_params.string,
        }).then(response =>{
            if(!response.ok) {
                // Handle error responses (non-2xx status codes)
                console.log(response.message)
                throw new HTTPError(`An HTTP error occured. Status:${response.status}.`,response);
            }
            else{
                return response.json();
            }
        });

    },

    //Used to retrieve tokens using login information. Inicializes the whole handler. 
    Authenticate: async function(username, password) {

        let response = await this.TryRequest(new GetToken(username, password));

        this.token = response.access_token;
        this.refresh_token = response.refresh_token;
        
        this.user_data = await this.TryRequest(new GetUserData());
        console.log('Vítám tě '.concat(this.user_data.firstName,'. '))

    },

    RefreshToken: async function(){
        //TODO:Write this bad boy. 
    },

    //Handles expired tokens automatically. Use instead of APITrySendRequest wherever possible. 
    Request: async function(request){
        let response = await this.TryRequest(request)
        .catch(error => {
            if(error instanceof HTTPError && error.response.status === 401){
                console.log()
                this.RefreshToken();
                return this.TryRequest(request);
            }
            else{
                console.error(`API:${error.message}`);
            }

        });
        return response;
    },

}