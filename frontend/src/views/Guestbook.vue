<template>
  <v-content>
    <v-container v-if="isAdmin" class="guestbook-nav text-center logged-in">
      <router-link class="my-2 mx-5" to="/guestbook/write">
        <FontAwesomeIcon icon="pen" />
      </router-link>
      <router-link class="my-2 mx-5" to="/guestbook/read">
        <FontAwesomeIcon icon="book" />
      </router-link>
    </v-container>
    <v-container class="guestbook px-1 fill-height justify-space-between" fluid>
      <router-view class="guestbook-view" />
    </v-container>
  </v-content>
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
