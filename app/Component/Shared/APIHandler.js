
export const APIHandler = {

    token:null,
    refresh_token:null,
    user_data:null,

    loginUser: function(username,password) {
        let query =  new URLSearchParams({
            grant_type:'password',
            username,
            password,
            client_id:'test_client',
            scope:'openid offline_access profile sol_api'
            });
        fetch('https://aplikace.skolaonline.cz/SOLAPI/api/connect/token', {
    method: 'POST',
    headers:{
        'Content-Type':'application/x-www-form-urlencoded',
    },
    body:query.toString()
    })
    .then(response => response.json())
    .then(data => {
        if('error_description' in data){
            console.log(data.error_description)
        }
        else {
            this.token = data.access_token;
            this.refresh_token = data.refresh_token;
            fetch('https://aplikace.skolaonline.cz/SOLAPI/api/v1/user',{
                method:'GET',
                headers: {
                    'Authorization':`Bearer ${data.access_token}`,
                },
            })
            .then(response => response.json())
            .then(data => {
                this.user_data = data;
                console.log(`Welcome ${data.firstName}`)
            })
            .catch(error => console.error(error));
        }
    })
    .catch(error => console.error(error));
    
    },   
    

}