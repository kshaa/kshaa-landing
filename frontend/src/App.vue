<template>
  <v-app id="app">
    <v-container class="fill-height align-start justify-center pa-5">
      <v-container v-if="isAuthenticated" class="nav logged-in">
        <router-link class="fa my-2 mx-5" to="/"><FontAwesomeIcon icon="home" /></router-link>
        <router-link class="fa my-2 mx-5" to="/guestbook/write"><FontAwesomeIcon icon="paper-plane" /></router-link>
        <a class="fa my-2 mx-5" href="/api/auth/logout"><FontAwesomeIcon icon="sign-out-alt" /></a>
      </v-container>
      <v-container v-else-if="isAdmin" class="nav logged-in">
        <router-link class="fa my-2 mx-5" to="/"><FontAwesomeIcon icon="home" /></router-link>
        <router-link class="fa my-2 mx-5" to="/guestbook/read"><FontAwesomeIcon icon="paper-plane" /></router-link>
        <a class="fa my-2 mx-5" href="/api/auth/logout"><FontAwesomeIcon icon="sign-out-alt" /></a>
      </v-container>
      <v-container v-else class="nav logged-out pa-7">
        <router-link class="fa my-2 mx-5" to="/"><FontAwesomeIcon icon="home" /></router-link>
        <router-link class="fa my-2 mx-5" to="/guestbook/write"><FontAwesomeIcon icon="paper-plane" /></router-link>
        <router-link class="fa my-2 mx-5" to="/login"><FontAwesomeIcon icon="key" /></router-link>
      </v-container>
      <router-view v-bind:isAuthenticated="isAuthenticated" v-bind:isAdmin="isAdmin" />
      <v-container class="elegant-emptiness">
      </v-container>
    </v-container>
  </v-app>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component({
  metaInfo: {
    title: 'Brought to you by',
    titleTemplate: '%s - Krišjānis Veinbahs',
  },
})
export default class Home extends Vue {
  isAdmin?: boolean | null
  isAuthenticated?: false | null
  error?: string | null

  data() {
    return {
      isAdmin: false,
      isAuthenticated: this.isAuthenticated || false,
      error: this.error || null,
    };
  }

  created() {
    this.fetchData();
  }

  fetchData() {
    this.error = null;
    this.isAuthenticated = false;
    fetch('/api/auth').then(response => response.json().then((status) => {
      this.isAuthenticated = status.isAuthenticated;
      this.isAdmin = status.isAdmin;
      this.error = null;
    }).catch((e) => {
      this.error = "Couldn't parse API server response.";
      this.isAuthenticated = false;
      this.isAdmin = false;
    })).catch((e) => {
      this.error = "Couldn't contact API server.";
      this.isAuthenticated = false;
      this.isAdmin = false;
    });
  }
}
</script>

<style lang="scss">
// Navigation container
#app .nav {
  display: flex;
  justify-content: center;
}

// Default FontAwesome icon styling
#app a.fa {
  border: none;
}

#app a.fa svg.svg-inline--fa {
  font-size: 30px;
}

#app a:hover,
#app a:active {
  color: #fff;
  border-color: transparent;
}

#app a {
  color: #aaa;
  border-bottom: solid 2px #aaa;
  transition: 0.15s;
}

// Footer
.elegant-emptiness {
  min-height: 10em
}
</style>
