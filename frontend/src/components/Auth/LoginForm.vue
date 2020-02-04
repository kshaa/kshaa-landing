<template>
  <v-form class="d-flex flex-column" @submit.prevent="login">
    <v-text-field v-model="username" label="Username"
      :rules="[rules.isRequired]">
    </v-text-field>
    <v-text-field v-model="password" type="password"
      label="Password" :rules="[rules.isRequired]">
    </v-text-field>
    <v-btn type="submit">Login</v-btn>
  </v-form>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import { LoginResponse } from '../../types';

@Component({
  props: {
    checkAuthentication: Function,
  },
})
export default class LoginForm extends Vue {
  username!: string;

  password!: string;

  checkAuthentication!: () => Promise<void>;

  rules = {
    isRequired: (v: string) => !!v || 'Value is required',
  };

  data() {
    return {
      username: '',
      password: '',
    };
  }

  login = function requestLogin(this: LoginForm) {
    var self = this;
    return this.axios.post('/api/auth/local/login', {
      username: this.username,
      password: this.password,
    })
      .then(function onLogin(this: LoginForm, result : LoginResponse) {
        if (result.data.success === false) {
          if (result.data.errorMessage) {
            alert(result.data.errorMessage);
          } else {
            alert('There was a problem logging in');
          }
        } else {
          self.$router.push('/');
          self.checkAuthentication();
        }
      })
      .catch((e : Error) => {
        alert('There was a problem logging in');
      });
  }
}
</script>
