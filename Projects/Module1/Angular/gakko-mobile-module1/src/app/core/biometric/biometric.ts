import { Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root',
})
export class Biometric {

    public isAvailable(): boolean {
        return typeof window != 'undefined' && !!window.PublicKeyCredential;
    }

    public async performBiometricAuthentication(): Promise<boolean> {
        try {
            const publicKeyCredentialRequestOptions: PublicKeyCredentialRequestOptions = {
                challenge: new Uint8Array(32),
                timeout: 60000,
                userVerification: "required"
            };

            return !!(await navigator.credentials.get({
                publicKey: publicKeyCredentialRequestOptions
            }));
        } catch (err) {
            console.log(err);
            return false;
        }
    }
}
