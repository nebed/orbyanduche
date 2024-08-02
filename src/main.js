import './assets/scss/custom.scss'
import './assets/main.css'
import '~vue-tel-input/dist/vue-tel-input.css';

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import VueLazyload from 'vue-lazyload';
import VueTelInput from 'vue-tel-input';

const app = createApp(App)

app.use(router)
app.use(VueLazyload, {
    preLoad: 1.3,
    error: 'dist/error.png',
    loading: 'dist/loading.gif',
    attempt: 1,
  });
app.use(VueTelInput);

app.mount('#app')
