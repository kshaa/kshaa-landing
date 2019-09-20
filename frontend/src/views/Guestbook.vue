<template>
  <div class="guestbook">
    <div v-if="isAdmin" class="guestbook-nav logged-in">
      <router-link to="/guestbook/write"><FontAwesomeIcon icon="pen" /></router-link>
      <router-link to="/guestbook/read"><FontAwesomeIcon icon="book" /></router-link>
    </div>
    <div v-if="!isAdmin" class="guestbook-nav logged-out">
    </div>
    <router-view class="guestbook-view" />
  </div>
</template>

<script lang="ts">
import { Component, Vue, Prop } from 'vue-property-decorator';
import GuestbookForm from '@/components/GuestbookForm.vue';
import GuestbookReader from '@/components/GuestbookReader.vue';

@Component({
  components: {
    GuestbookForm,
    GuestbookReader,
  },
  metaInfo: {
    title: 'Guestbook',
  },
  props: {
    isAuthenticated: Boolean,
    isAdmin: Boolean,
  },
})
export default class Guestbook extends Vue {}
</script>

<style lang="scss" scoped>
.guestbook-view {
  text-align: center;
  max-width: 600px;
  margin: 8vh auto 0 auto;
}
.guestbook-nav {
  padding: 5px;
  display: flex;
  justify-content: center;
}

.guestbook-nav a {
  font-size: 30px;
  margin: 10px 30px;
  text-decoration: none;
  transition: 0.15s;
  color: #aaa
}

.guestbook-nav.logged-out {
  min-height: 54px;
}

.guestbook-nav a:hover,
.guestbook-nav a:active {
  color: #fff
}
</style>
