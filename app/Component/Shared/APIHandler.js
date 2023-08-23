import { GetToken, GetUserData } from "./APIRoutes";

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
    user_data:{},

    //Tries to send request but does not guarantee delivery, will throw an error if token is not working.
    TryRequest: async function(request) {

        try{
            request.Populate(this.token,this.user_data.student_id, this.refresh_token).Build();
        }
        catch(error){
            throw new APIError(`Invalid Request.(${error.message})`);
        }

        let result = await fetch(request.url,{
            method:request.method,
            headers:request.headers.toString(),
            body:request.query_params.toString(),
        }).then(response =>{
            if(!response.ok) {
                // Handle error responses (non-2xx status codes)
                throw new HTTPError(`An HTTP error occured. Status:${response.status}.`,response);
            }
            else{
                return response.json();

            }
        });


        return result;
    },

    //Used to retrieve tokens using login information. Inicializes the whole handler. 
    Authenticate: async function(username, password) {

        let response = await this.TryRequest(new GetToken(username, password))
        .catch(error=>{
            if(error instanceof APIError){
                if(error instanceof HTTPError) throw error;
                console.error(`API: ${error.message}`);
            }
            else{
                console.error(error.message);
            }

        });

        this.token = response.access_token;
        this.refresh_token = response.refresh_token;
        
        this.user_data = await this.TryRequest(new GetUserData())
        .catch(error =>{
            if(error instanceof APIError){
                if(error instanceof HTTPError) throw error;
                console.error(`API: ${error.message}`);
            }
            else{
                console.error(error.message);
            }
        });

        console.log(`${this.user_data.firstName} has sucessfully logged in.`)

    },

    RefreshToken: async function(){
        //TODO:Write this bad boy. 
    },

    //Handles expired tokens automatically. Use instead of APITrySendRequest whenever possible. 
    Request: async function(request){
        let response = await this.TryRequest(request)
        .catch(error => {
            if(error instanceof HTTPError && error.response.status === 401){
                this.RefreshToken();
                return this.TryRequest(request);
            }
            else throw error;
        });
        return response;
    },

}