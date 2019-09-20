<template>
  <div id="app">
    <div v-if="isAdmin" class="nav logged-in">
      <router-link to="/"><FontAwesomeIcon icon="home" /></router-link>
      <router-link to="/guestbook/read"><FontAwesomeIcon icon="paper-plane" /></router-link>
      <a href="/api/auth/logout"><FontAwesomeIcon icon="sign-out-alt" /></a>
    </div>
    <div v-else class="nav logged-out">
      <router-link to="/"><FontAwesomeIcon icon="home" /></router-link>
      <router-link to="/guestbook/write"><FontAwesomeIcon icon="paper-plane" /></router-link>
      <router-link to="/login"><FontAwesomeIcon icon="key" /></router-link>
    </div>
    <router-view v-bind:isAuthenticated="isAuthenticated" v-bind:isAdmin="isAdmin" />
  </div>
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
  loading?: boolean

  isAdmin?: boolean | null

  isAuthenticated?: false | null

  error?: string | null

  static data() {
    return {
      loading: false,
      isAuthenticated: false,
      error: null,
    };
  }

  created() {
    // fetch the data when the view is created and the data is
    // already being observed
    this.fetchData();
  }

  watch = {
    // call again the method if the route changes
    $route: 'fetchData',
  }

  fetchData() {
    this.error = null;
    this.isAuthenticated = false;
    this.loading = true;
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
body {
  margin: 0;
  background: black;
}

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #ddd;
  padding: 20px;
}

.nav {
  padding: 30px;
  display: flex;
  justify-content: center;
}

.nav a {
  font-size: 30px;
  margin: 10px 30px;
  text-decoration: none;
  transition: 0.15s;
  color: #aaa
}

.nav a:hover,
.nav a:active {
  color: #fff
}
</style>
