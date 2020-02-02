<template>
  <div class="kshaa-social links">
    <a class="my-2 mx-5" href="https://github.com/kshaa">
      <FontAwesomeIcon :icon="['fab', 'github']" />
    </a>
    <a class="my-2 mx-5" href="https://linkedin.com/in/kveinbahs">
      <FontAwesomeIcon :icon="['fab', 'linkedin']" />
    </a>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class KshaaAbout extends Vue {
  @Prop() private shortDescription!: string;
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.links {
  display: flex;
  justify-content: center;
  opacity: 0.85;
  color: #fff;
  margin-top: 40px;
}
</style>
