export interface StatusResponse {
    data : {
        success : boolean
        errorMessage? : string
    }
}

export interface LoginResponse extends StatusResponse {}
export interface RegistrationResponse extends StatusResponse {}
