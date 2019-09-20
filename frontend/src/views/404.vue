<template>
  <div class="page-not-found">
    <div class="card">
      <h2 class="title">404 Page not found</h2>
      <p class="motd">I couldn't find the page you're looking for :(</p>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

@Component({
  metaInfo: {
    title: '404 Page not found',
  },
})
export default class NotFound extends Vue {}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.page-not-found {
  max-width: 600px;
  margin: 15vh auto 0 auto;
}

.card {
  text-align: center;
}

.title {
  color: white;
}
</style>
