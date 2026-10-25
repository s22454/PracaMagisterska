import { Routes } from '@angular/router';

import { Home } from './features/home/home';
import { Login } from './features/login/login';

export const routes: Routes = [
    {
        path: '',
        redirectTo: "signin",
        pathMatch: 'full'
    },
    {
        path: "home",
        component: Home
    },
    {
        path: "signin",
        component: Login
    }
];
