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
      beforeEnter: async () => {
        let password = sessionStorage.getItem('adminPassword');
        if (password && await verifyAdminPassword(password)) return true;

        sessionStorage.removeItem('adminPassword');
        password = prompt('Enter the admin password:');
        if (!password) return '/';

        if (await verifyAdminPassword(password)) {
          sessionStorage.setItem('adminPassword', password);
          return true;
        }

        alert('Authentication failed');
        return '/';
      }
    }
  ]
})

async function verifyAdminPassword(password) {
  const apiHost = import.meta.env.VITE_API_HOST || '';
  try {
    const response = await fetch(`${apiHost}/api/auth/check`, {
      headers: { Authorization: `Basic ${btoa(`admin:${password}`)}` }
    });
    return response.ok;
  } catch {
    return false;
  }
}

export default router

