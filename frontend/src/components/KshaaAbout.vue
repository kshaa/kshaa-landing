<template>
  <div class="kshaa-about">
    <h2 class="title">Krišjānis Veinbahs</h2>
    <p class="motd">{{ shortDescription }}</p>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class KshaaLanding extends Vue {
  @Prop() private shortDescription!: string;
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.kshaa-about {
  text-align: center;
}

.title {
  color: white;
}
</style>
