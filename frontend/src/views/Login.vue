<template>
  <div class="login">
    <div class="card">
      <div>
        <h2 class="title">Login</h2>
        <p>Only Github social login is supported</p>
        <p><i>Note that logging in has an effect only if I've invited you!</i></p>
        <p><i>Otherwise nothing will change.</i></p>
        <div class="social-logins links">
          <a href="/api/auth/github">
            <FontAwesomeIcon :icon="['fab', 'github']" />
            <p>Github OAuth</p>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component({
  metaInfo: {
    title: 'Login',
  },
})
export default class Login extends Vue {}
</script>

<style lang="scss" scoped>
.login {
  text-align: center;
  max-width: 600px;
  margin: 15vh auto 0 auto;
}

.title {
  color: white;
}

.links {
  display: flex;
  justify-content: left;
  flex-direction: column;
  align-items: center;
  opacity: 0.85;
  color: #fff;
  margin-top: 40px;
}
.links a {
  display: flex;
  justify-content: left;
  align-items: center;
  text-decoration: none;
}
.links a * {
  transition: 0.15s;
  color: #aaa
}
.links svg {
  margin: 0 15px 0 0;
  font-size: 30px;
}
.links a:hover * {
  color: #fff
}
</style>
