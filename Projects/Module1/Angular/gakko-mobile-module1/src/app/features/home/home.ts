import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { Auth } from '../../core/auth/auth';

@Component({
  selector: 'app-home',
  imports: [],
  templateUrl: './home.html',
  styleUrl: './home.scss',
})
export class Home {
    private readonly router = inject(Router);
    private readonly authService = inject(Auth);

    protected logout(): void {
        this.authService.logout();
        this.router.navigate(['/signin']);
    }
}
