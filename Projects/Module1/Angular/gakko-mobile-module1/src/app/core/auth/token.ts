import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class Token {
    private readonly storageKey = 'auth_token'

    public saveToken(token: string): void {
        localStorage.setItem(this.storageKey, token);
    }

    public getToken(): string | null {
        return localStorage.getItem(this.storageKey);
    }

    public removeToken(): void {
        localStorage.removeItem(this.storageKey);
    }

    public hasToken(): boolean {
        return !!this.getToken();
    }
}
