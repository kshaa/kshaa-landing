<template>
  <div class="kshaa-about text-center">
    <h2 class="headline font-weight-bold">Krišjānis Veinbahs</h2>
    <p class="motd my-4">{{ shortDescription }}</p>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class KshaaLanding extends Vue {
  @Prop() private shortDescription!: string;
}
</script>
