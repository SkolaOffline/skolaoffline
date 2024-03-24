import { APIRoute, GetToken, GetUserData, RenewToken } from "./APIRoutes";
import {useRouter} from 'expo-router';

export class APIError extends Error{}


export class HTTPError extends APIError{
    constructor(message,response){
        super(message);
        this.response = response;
    }

}

const router = useRouter();

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

        return await fetch(request.url,{
            method:request.method,
            headers:request.headers,
            body:request.query_params.string,
        }).then(response =>{
            if(!response.ok) {
                // Handle error responses (non-2xx status codes)
                throw new HTTPError(`An HTTP error occured. Status:${response.status}.`,response.json());
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

        router.navigate('(home)/home')

        //TODO: save the refresh token at a safe place

    },

    RefreshToken: async function(){
        this.TryRequest(new RenewToken())
        .catch(error=>{


        })
        //TODO: Add request for login when refresh token expires. 
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