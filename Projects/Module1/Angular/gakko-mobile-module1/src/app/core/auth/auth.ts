import { HttpClient } from '@angular/common/http';
import { Token } from './token';
import { inject, Injectable } from '@angular/core';
import { LoginRequest } from '../../shared/models/login-request.model';
import { Observable, tap } from 'rxjs';
import { AuthResponse } from '../../shared/models/auth-response.model';

@Injectable({
  providedIn: 'root',
})
export class Auth {
    private readonly http = inject(HttpClient);
    private readonly tokenService = inject(Token);

    private readonly apiUrl = 'https://manor-armhole-wolf.ngrok-free.dev';
    private readonly signinEndpoint = '/api/auth/login';

    public signin(credentials: LoginRequest): Observable<AuthResponse> {
        return this.http.post<AuthResponse>(this.apiUrl + this.signinEndpoint, credentials).pipe(
            tap((response) => {
                if (response && response.token) {
                    this.tokenService.saveToken(response.token);
                }
            }));
    }

    public isAuthenticated(): boolean {
        if (!this.tokenService.hasToken() || !this.tokenService.getToken()) {
            console.log(this.tokenService.getToken())
            return false;
        }

        return true;
    }

    public logout(): void {
        this.tokenService.removeToken();
    }
}
