import Vue from 'vue';
import Router from 'vue-router';
import Home from './views/Home.vue';
import Login from './views/Login.vue';
import Guestbook from './views/Guestbook.vue';
import GuestbookReader from './components/GuestbookReader.vue';
import GuestbookForm from './components/GuestbookForm.vue';
import NotFound from './views/404.vue';

Vue.use(Router);

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home,
    },
    {
      path: '/login',
      name: 'login',
      component: Login,
    },
    {
      path: '/guestbook',
      name: 'guestbook',
      component: Guestbook,
      children: [
        {
          path: 'read',
          name: 'guestbookreader',
          component: GuestbookReader,
        },
        {
          path: 'write',
          name: 'guestbookform',
          component: GuestbookForm,
        },
      ],
    },
    {
      path: '*',
      component: NotFound,
    },
  ],
});
