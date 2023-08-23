
export class APIRoute{
    // Parameters that are selected by other code should be passed over here.
    constructor(){
        this.headers = new Headers();
        this.query_params = new URLSearchParams();
        this.url='';
        this.method='';
    }

    //Passes all the API related parameters over to the class. 
    Populate(auth_token,student_id,refresh_token){
        this.auth_token = auth_token;
        this.student_id = student_id;
        this.refresh_token=refresh_token;

        return this;
    }
    //Builds the actual request.
    Build(){

    }
}


//Each class refers to a specific request that can be sent to the API. 


export class GetToken extends APIRoute{
    constructor(username, password){
        super();

        this.username=username;
        this.password=password;
    }

    Build(){
    
    this.url = 'https://aplikace.skolaonline.cz/SOLAPI/api/connect/token';

    this.method='POST';

    this.query_params.append('grant_type','password');
    this.query_params.append('username',this.username);
    this.query_params.append('password',this.password);
    this.query_params.append('client_id','test_client');
    this.query_params.append('scope','openid offline_access profile sol_api');

    this.headers.append('Content-Type','application/x-www-form-urlencoded');

    }
}


export class GetUserData extends APIRoute{


    Build(){

    this.url = 'https://aplikace.skolaonline.cz/SOLAPI/api/v1/user';

    this.method ='GET';

    headers.append('Authorization',`Bearer ${data.access_token}`);

    }
}