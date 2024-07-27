import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/rsvp',
      name: 'rsvp',
      component: () => import('../views/RsvpView.vue')
    },
    {
      path: '/ourstory',
      name: 'ourstory',
      component: () => import('../views/OurStoryView.vue')
    },
    {
      path: '/gallery',
      name: 'gallery',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/GalleryView.vue')
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('../views/AdminView.vue'),
      beforeEnter: (to, from, next) => {
        if (isAuthenticated()) {
          next();
        } else {
          const username = prompt("Enter username:");
          const password = prompt("Enter password:");
          if (checkCredentials(username, password)) {
            sessionStorage.setItem('authenticated', 'true');
            next();
          } else {
            alert('Authentication failed');
            next('/');
          }
        }
      }
    }
  ]
})

function isAuthenticated() {
  return sessionStorage.getItem('authenticated') === 'true';
}

function checkCredentials(username, password) {
  const validUsername = import.meta.env.VITE_API_USERNAME;
  const validPassword = import.meta.env.VITE_API_PASSWORD;
  return username === validUsername && password === validPassword;
}

export default router

