<template>
  <v-form ref="form" class="d-flex flex-column" @submit.prevent="register">
    <v-text-field v-model="username" label="Username *" :rules="[rules.isRequired]"></v-text-field>
    <v-text-field v-model="password" type="password" label="Password *" :rules="[rules.isRequired]"></v-text-field>
    <v-text-field v-model="passwordRepeated" type="password" label="Repeat password *" :rules="[rules.isRequired, rules.passwordsEqual(password, passwordRepeated)]"></v-text-field>
    <v-text-field v-model="email" label="Email" :rules="[rules.isEmail]"></v-text-field>
    <v-text-field v-model="name" label="Name"></v-text-field>
    <v-text-field v-model="surname" label="Surname"></v-text-field>
    <v-btn type="submit">Register</v-btn>
  </v-form>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import { AxiosResponse } from 'axios';
import { HumanReadableError } from '../../lib/helpers';

@Component({
  props: {
    checkAuthentication : Function
  }
})
export default class RegisterForm extends Vue {
  error: string;
  username: string;
  password: string;
  passwordRepeated: string;
  email?: string;
  name?: string;
  surname?: string;
  checkAuthentication: () => Promise<void>;
  rules = {
    isRequired: (v) => !!v || 'Value is required',
    isEmail: (v) => {
      return v == '' // No email
        || !!v.match(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/)
        || 'Not a valid email';
    },
    passwordsEqual: (password, passwordRepeated) => {
      return () => password === passwordRepeated
        || "Passwords not equal";
    },
  };
  data() {
    return {
      error: '',
      username: '',
      password: '',
      passwordRepeated: '',
      email: '',
      name: '',
      surname: '',
    }
  };
  register = function(this: RegisterForm) {
    // Make sure form is valid
    var formElement : any = this.$refs['form'];
    if (!formElement.validate()) {
      return
    }
    var self = this;
    this.error = null;
    // Create request payload
    var payload : any = {
      username: this.username,
      password: this.password,
      name: this.name,
      surname: this.surname
    }
    // If email is empty, don't send it
    if (this.email !== '') {
      payload.email = this.email;
    }
    this.axios.post('/api/auth/local/register', payload)
      // Check if successful registration
      .then(function(response : Object) {
        if (response['data']['success'] !== true) {
          if (response['data']['errorMessage']) {
            throw new HumanReadableError('There was a problem while registering - ' + response['data']['errorMessage']);
          } else {
            throw new HumanReadableError('There was a problem while registering :(');
          }
        }
      })
      // Attempt to log in after registration
      .then(() => {
        return this.axios.post('/api/auth/local/login', {
          username: this.username,
          password: this.password
        })
          .catch((e) => {
            console.error('Post-registration log in error - ' + e.messsage);
            throw new HumanReadableError('Registration was succesful, but failed to automatically log in.');
          })
      })
      // Clean up passwords
      .then(() => {
        self.password = '---';
        self.passwordRepeated = '---';
      })
      // Trigger authentication check to render logged in view
      .then(() => {
        this.$router.push('/');
        this.checkAuthentication()
        alert('Registration successful');
      })
      .catch(function(e) {
        if (e instanceof HumanReadableError) {
          self.error = e.message;
        } else {
          self.error = 'There was a problem while registering :(';
          console.error(`Server error: ${e.message}`);
        }
        alert(self.error)
      });
  }
}
</script>
