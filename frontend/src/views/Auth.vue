<template>
  <v-content>
    <v-container class="fill-height justify-center align-center flex-column" fluid>
      <h2 class="headline font-weight-bold pb-4">Authentication</h2>
      <div>
        <v-tabs
          class="login-tabs"
          background-color="transparent"
          color="grey lighten-4"
          :centered="true">
          <v-tab key="login"  class="font-weight-bold">
            Login
          </v-tab>
          <v-tab key="register" class="font-weight-bold">
            Register
          </v-tab>
          <v-tab key="social" class="font-weight-bold">
            Social
          </v-tab>
          <v-tab-item key="login">
            <LoginForm v-bind:checkAuthentication="checkAuthentication" class="pt-4"></LoginForm>
          </v-tab-item>
          <v-tab-item key="register">
            <RegisterForm v-bind:checkAuthentication="checkAuthentication" class="pt-4"></RegisterForm>
          </v-tab-item>
          <v-tab-item key="social">
            <div class="d-flex justify-center pt-6">
              <a class="fa d-inline-flex align-center" href="/api/auth/github">
                <FontAwesomeIcon :icon="['fab', 'github']" />
                <span class="ml-4 ma-0">Github</span>
              </a>
            </div>
          </v-tab-item>
        </v-tabs>
      </div>
    </v-container>
  </v-content>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import LoginForm from '@/components/Auth/LoginForm.vue';
import RegisterForm from '@/components/Auth/RegisterForm.vue';

@Component({
  components: {
    LoginForm,
    RegisterForm,
  },
  props: {
    checkAuthentication : Function,
  },
  metaInfo: {
    title: 'Login',
  },
})
export default class Login extends Vue {}
</script>

<style lang="scss">
@import '@/styles/variables.scss';
.login-tabs {
  width: $mini-component-size;
  max-width: 100%;
}
.login-tabs .v-item-group {
  background-color: transparent;
}
</style>
