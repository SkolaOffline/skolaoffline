
export class URLParams{
    constructor(){
        this.string=''
    }
    append(parameter,value){
        if((parameter instanceof String|| typeof parameter ==='string') && (value instanceof String|| typeof parameter ==='string')){
            if(this.string===''){
                this.string=this.string.concat(parameter,'=',value)
            }
            else{
                this.string= this.string.concat('&',parameter,'=',value)
            }
        }
        else{
            throw Error('Appended parameter is not a string!')
        }
    }
}

export class APIRoute{
    // Parameters that are selected by other code should be passed over here.
    constructor(){
        this.headers = new Headers();
        this.query_params = new URLParams();
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
    
    this.url = 'https://aplikace.skolaonline.cz/solapi/api/connect/token';

    this.method='POST';


    this.query_params.append('grant_type','password');
    this.query_params.append('username',this.username);
    this.query_params.append('password',this.password);
    this.query_params.append('client_id','test_client');
    this.query_params.append('scope','openid offline_access profile sol_api');

    this.headers.append('Content-Type','application/x-www-form-urlencoded');

    }
}

export class RenewToken extends APIRoute{
    Build(){
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/connect/token'

        this.method = 'POST'

        this.headers.append('Content-Type','application/x-www-form-urlencoded');

        this.query_params.append('grant_type','refresh_token');
        this.query_params.append('client_id','test_client');
        this.query_params.append('refresh_token',this.refresh_token);
    }
}


export class GetUserData extends APIRoute{


    Build(){

    this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/user';

    this.method ='GET';

    this.headers.append('Authorization',`Bearer ${this.auth_token}`);

    return this;

    }
}

export class GetNotifications extends APIRoute{


    Build(){

    this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/user/notifications';

    this.method ='GET';

    this.headers.append('Authorization',`Bearer ${this.auth_token}`);

    return this;

    }
}

export class GetTimetableInfo extends APIRoute {
    Build() {
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/timeTable/codeLists';

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);
        
        return this;
    }
}

export class GetTimetable extends APIRoute{
    Build(){
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/timeTable'

        this.method = 'GET'

        this.headers.append('Authorization',`Bearer ${this.auth_token}`);

        this.query_params.append('StudentId', this.student_id);
        this.query_params.append('DateFrom', this.date_from);
        this.query_params.append('DateTo', this.date_to);
        this.query_params.append('SchoolYearId', this.semester_id);

        return this;
    }
}

export class GetGrades extends APIRoute {
    Build() {
        this.url = `https://aplikace.skolaonline.cz/solapi/api/v1/students/${this.student_id}/marks/list`;

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        this.query_params.append('SigningFilter', this.signing_filter || 'all');
        this.query_params.append('Pagination.PageNumber', this.page_number || 1);
        this.query_params.append('Pagination.PageSize', this.page_size || 10);
        this.query_params.append('SemesterId', this.semester_id);
        if (this.subject_id) {
            this.query_params.append('SubjectId', this.subject_id);
        }
        
        return this;
    }
}

export class GetGrade extends APIRoute{
    Build(){
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/student/marks/' + this.grade_id

        this.method = 'GET'

        this.headers.append('Authorization',`Bearer ${this.auth_token}`);

        this.query_params.append('StudentId', this.student_id);

        return this;
    }
}

export class GetCertificates extends APIRoute {
    Build() {
        this.url = `https://aplikace.skolaonline.cz/solapi/api/v1/students/${this.student_id}/marks/final`;

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        return this;
    }
}

export class GetHomework extends APIRoute {
    Build() {
        this.url = `https://aplikace.skolaonline.cz/solapi/api/v1/students/${this.student_id}/homeworks`;

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        this.query_params.append('Pagination.PageNumber', this.page_number || 1);
        this.query_params.append('Pagination.PageSize', this.page_size || 10);
        this.query_params.append('Filter', this.filter || 'active');

        return this;
    }
}

export class GetBehaviors extends APIRoute {
    Build() {
        this.url = `https://aplikace.skolaonline.cz/solapi/api/v1/students/${this.student_id}/behaviors`;

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        this.query_params.append('Pagination.PageNumber', this.page_number || 1);
        this.query_params.append('Pagination.PageSize', this.page_size || 10);
        this.query_params.append('RecordsFilter', this.records_filter || 'all');

        return this;
    }
}

export class GetMessageSettings extends APIRoute {
    Build() {
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/messages/settings';

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        return this;
    }
}

export class MarkMessageAsRead extends APIRoute {
    Build() {
        this.url = `https://aplikace.skolaonline.cz/solapi/api/v1/messages/${this.message_id}/mark-as-read`;

        this.method = 'PUT';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        return this;
    }
}

export class GetMessages extends APIRoute {
    Build() {
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/messages/received';

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        this.query_params.append('Pagination.PageNumber', this.page_number || 1);
        this.query_params.append('Pagination.PageSize', this.page_size || 10);

        return this;
    }
}

export class GetMarksCodeLists extends APIRoute {
    Build() {
        this.url = 'https://aplikace.skolaonline.cz/solapi/api/v1/marks/codeLists';

        this.method = 'GET';

        this.headers.append('Authorization', `Bearer ${this.auth_token}`);

        this.query_params.append('StudentId', this.student_id);
        
        return this;
    }
}