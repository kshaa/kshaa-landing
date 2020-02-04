<template>
  <v-app id="app">
    <v-container class="fill-height align-start flex-column justify-stretch pa-5">
      <v-container class="d-flex justify-center nav">
        <router-link class="my-2 mx-5" to="/"><FontAwesomeIcon icon="home" /></router-link>

        <router-link v-if="!isAdmin" class="my-2 mx-5" to="/guestbook/write">
          <FontAwesomeIcon icon="paper-plane" />
        </router-link>
        <router-link v-if="isAdmin" class="my-2 mx-5" to="/guestbook/read">
          <FontAwesomeIcon icon="paper-plane" />
        </router-link>

        <router-link v-if="!isAuthenticated" class="my-2 mx-5" to="/auth">
          <FontAwesomeIcon icon="key" />
        </router-link>
        <a v-if="isAuthenticated" class="my-2 mx-5" href="/api/auth/logout">
          <FontAwesomeIcon icon="sign-out-alt" />
        </a>
      </v-container>
      <router-view class="app-content"
        v-bind:isAuthenticated="isAuthenticated"
        v-bind:checkAuthentication="checkAuthentication"
        v-bind:isAdmin="isAdmin" />
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
    this.checkAuthentication();
  }

  checkAuthentication() {
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
// Let views decide their own layout
.app-content {
  width: 100%;
}

// Default FontAwesome icon styling
.svg-inline--fa {
  font-size: 30px;
}

// Link hover color effect
#app a,
#app a * {
  color: #aaa;
  transition: 0.15s;
  text-decoration: none;
}

#app a:hover,
#app a:active,
#app a:hover *,
#app a:active * {
  color: #fff;
}

// Footer
.elegant-emptiness {
  min-height: 10em
}
</style>
