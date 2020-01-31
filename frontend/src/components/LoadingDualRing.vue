<!-- Sourced from https://loading.io/css/ -->
<template>
    <div class="lds-dual-ring" v-bind:class="{ active: active }"></div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class LoadingDualRing extends Vue {
    @Prop() public active!: string;
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.lds-dual-ring {
  display: inline-block;
  width: 60px;
  height: 60px;
  opacity: 0;
  transition: 0.5s;
}
.lds-dual-ring.active {
    opacity: 1;
}
.lds-dual-ring:after {
  content: " ";
  display: block;
  width: 64px;
  height: 64px;
  margin: 8px;
  border-radius: 50%;
  border: 6px solid #fff;
  border-color: #fff transparent #fff transparent;
  animation: lds-dual-ring 1.2s linear infinite;
}
@keyframes lds-dual-ring {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
