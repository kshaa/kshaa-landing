<template>
  <div class="card">
    <h2 class="title">Guestbook</h2>
    <p class="info">Leave a message in the guestbook</p>
    <p><i class="notice">The guestbook is visible only to me (Veinbahs)</i></p>
    <p><i class="notice">Your IP and user agent may be logged</i></p>
    <p><i class="notice">Feel free to send memes, but don't spam</i></p>
    <form method="POST" action="/api/guestbook/write" @submit="formSubmit">
      <div class="messageForm">
        <textarea class="message" name="message" v-model="message" placeholder="Be creative">
        </textarea>
        <button class="submit" type="submit">Send</button>
      </div>
    </form>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component({
  metaInfo: {
    title: 'Guestbook - Send message',
  },
})
export default class GuestbookForm extends Vue {
  message?: string|null

  data() {
    return {
      message: null,
    };
  }

  formSubmit(e: any) {
    /* eslint-disable no-alert */
    e.preventDefault();
    const currentObj = this;

    if (!this.message || (this.message && this.message.trim().length === 0)) {
      alert('This message looks pretty empty');

      return;
    }

    this.axios.post('/api/guestbook/write', {
      message: this.message,
    })
      .then((response) => {
        if (!response.data.success) {
          throw new Error('There was a problem sending the message');
        }

        this.message = null;
        alert('Message sent succesfully');
      })
      .catch((error) => {
        alert(error.message);
      });
    /* eslint-enable no-alert */
  }
}
</script>

<style lang="scss" scoped>
.title {
  color: white;
}

.messageForm {
  width: 100%;
  max-width: 300px;
  margin: 10px auto 0;

  .message {
    box-sizing: border-box;
    display: block;
    width: 100%;
    min-height: 100px;
  }

  .submit {
    background: #333;
    color: white;
    font-size: 20px;
    font-weight: bold;
    padding: 15px;
    border: 0;
    box-sizing: border-box;
    text-transform: uppercase;
    width: 100%;
  }
}
</style>
