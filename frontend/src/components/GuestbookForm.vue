<template>
  <v-content>
    <v-container :class="guestbookContainerClasses" fluid>
      <h2 class="headline font-weight-bold pb-4">Guestbook</h2>
      <p class="font-italic">Leave a message in the guestbook</p>
      <p class="font-italic">The guestbook is visible only to me (Veinbahs)</p>
      <v-form class="guestbook-form" @submit.prevent="guestbookSubmit">
        <v-card class="message-card d-flex flex-column">
          <v-textarea class="message mx-4 mt-2" name="message"
            v-model="message" placeholder="Message">
          </v-textarea>
          <v-btn class="mx-4 mb-6 align-self-end" type="submit">Send</v-btn>
        </v-card>
      </v-form>
    </v-container>
  </v-content>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component({
  metaInfo: {
    title: 'Guestbook - Send message',
  },
})
export default class GuestbookForm extends Vue {
  message!: string | null

  guestbookContainerClasses =
        'guestbook-write fill-height align-stretch '
        + 'justify-center text-center d-flex flex-column px-1';

  data() {
    return {
      message: null,
    };
  }

  guestbookSubmit = function guestbookSubmit(this: GuestbookForm, e: any) {
    /* eslint-disable no-alert */
    e.preventDefault();

    if (!this.message || (this.message && this.message.trim().length === 0)) {
      alert('This message looks pretty empty');

      return;
    }

    this.axios.post('/api/guestbook/write', {
      message: this.message,
    })
      .then((response) => {
        if (!response.data.success) {
          alert('There was a problem sending the message');
        } else if (response.data.infoMessage) {
          alert(response.data.infoMessage);
        } else {
          alert('Message sent succesfully');
        }
        // Clear form
        this.message = null;
      })
      .catch((error) => {
        alert(error.message);
      });
    /* eslint-enable no-alert */
  }
}
</script>

<style lang="scss">
@import '@/styles/variables.scss';

.guestbook-write {
  width: $mini-component-size;
}

.guestbook-form {
  max-width: 100%;
}

.message-card {
  max-width: 100%;
}

.message textarea {
  height: 200px;
  min-height: 200px;
  max-height: 350px;
}
</style>
