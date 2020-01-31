import Vue from 'vue';
import VueMeta from 'vue-meta';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faHome, faKey, faSignOutAlt, faPaperPlane, faPen, faBook,
} from '@fortawesome/free-solid-svg-icons';
import { faLinkedin, faGithub } from '@fortawesome/free-brands-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import axios from 'axios';
import VueAxios from 'vue-axios';
// @ts-ignore
import Vuetify from 'vuetify/lib';
import App from './App.vue';
import router from './router';

/* Axios for easier AJAX requests */
Vue.use(VueAxios, axios);

/* Plugin for managing <head>'s <meta> tags */
Vue.use(VueMeta, {
  refreshOnceOnNavigation: true,
});

/* Install FontAwesome */
library.add({
  faHome, faKey, faLinkedin, faGithub, faSignOutAlt, faPaperPlane, faPen, faBook,
});
Vue.component('FontAwesomeIcon', FontAwesomeIcon);

/* Install Vuetify */
Vue.use(Vuetify);
const vuetify = new Vuetify({
  theme: {
    dark: true,
  }
});

Vue.config.productionTip = false;

new Vue({
  router,
  // @ts-ignore
  vuetify,
  render: h => h(App),
}).$mount('#app');
