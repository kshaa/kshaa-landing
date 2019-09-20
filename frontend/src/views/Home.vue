<template>
  <div class="home">
    <div class="card">
      <KshaaAbout shortDescription="DevOps / Student @ LU / Cyclist"/>
      <KshaaSocial/>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import KshaaAbout from '@/components/KshaaAbout.vue'; // @ is an alias to /src
import KshaaSocial from '@/components/KshaaSocial.vue'; // @ is an alias to /src

@Component({
  components: {
    KshaaAbout,
    KshaaSocial,
  },
  metaInfo: {
    title: 'Home',
  },
})
export default class Home extends Vue {}
</script>

<style lang="scss" scoped>
.home {
  max-width: 600px;
  margin: 15vh auto 0 auto;
}
</style>
