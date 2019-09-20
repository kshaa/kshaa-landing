<template>
  <div class="kshaa-social links">
    <a href="https://github.com/kshaa">
      <FontAwesomeIcon :icon="['fab', 'github']" />
    </a>
    <a href="https://linkedin.com/in/kveinbahs">
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
.links a {
  font-size: 30px;
  margin: 10px 30px;
  text-decoration: none;
  transition: 0.15s;
  color: #aaa
}
.links a:hover {
  color: #fff
}
</style>
