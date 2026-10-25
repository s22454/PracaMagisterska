import { Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { Auth } from '../../core/auth/auth';
import { HttpErrorResponse } from '@angular/common/http';
import { Biometric } from '../../core/biometric/biometric';

@Component({
  selector: 'app-login',
  imports: [ReactiveFormsModule],
  templateUrl: './login.html',
  styleUrl: './login.scss',
})
export class Login {
    private readonly router = inject(Router);
    private readonly authService = inject(Auth);
    private readonly biometricService = inject(Biometric);
    private readonly formBuilder = inject(FormBuilder);

    protected signinForm: FormGroup = this.formBuilder.group({
        email: ['', [Validators.required, Validators.email]],
        password: ['', [Validators.required, Validators.minLength(6)]]
    })

    protected isLoading = signal<boolean>(false);
    protected errorMessage = signal<string | null>(null);

    protected hasSavedToken = signal<boolean>(this.authService.isAuthenticated());

    protected signin(): void {

        if (this.signinForm.invalid){
            this.signinForm.markAllAsTouched();

            const errors: string[] = [];
            const emailCtrl = this.signinForm.get('email');
            const passwordCtrl = this.signinForm.get('password');

            if (emailCtrl?.hasError('required')) {
                errors.push('E-mail is required');
            } else if (emailCtrl?.hasError('email')) {
                errors.push('Invalid email format');
            }

            if (passwordCtrl?.hasError('required')) {
                errors.push('Password is required');
            } else if (passwordCtrl?.hasError('minlength')) {
                errors.push('Password has to be at least 8 characters long');
            }

            this.errorMessage.set(errors.join('\n'));
            return;
        }

        this.isLoading.set(true);
        this.errorMessage.set(null);
        this.signinForm.disable();

        this.authService.signin(this.signinForm.value).subscribe({
            next: () => {
                this.isLoading.set(false);
                this.signinForm.enable();
                this.router.navigate(['/home']);
            },
            error: (err: HttpErrorResponse) => {
                this.isLoading.set(false);
                this.signinForm.enable();
                this.errorMessage.set('Sign in error, wrong email or password \n' + err.status);
            }
        });
    }

    protected async signinWithBiometrics(): Promise<void> {
        if (!this.authService.isAuthenticated()) {
            this.errorMessage.set('Can\'t sign in with biometric \n because user isn\'t authenticated');
            return;
        }

        if (!this.biometricService.isAvailable()) {
            this.errorMessage.set('Biometric authentication is unavailable!');
            return;
        }

        try {
            var authenticated = await this.biometricService.performBiometricAuthentication();
            if (authenticated) {
                this.router.navigate(['/home']);
                return;
            }

            this.errorMessage.set('Biometric authentication failed');
        } catch (err) {
            console.log(err);
            this.errorMessage.set('Unexpected error occurred!');
        }
    }
}
