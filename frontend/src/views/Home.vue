<template>
  <v-content>
    <v-container class="fill-height justify-center" fluid>
      <div class="card">
        <KshaaAbout shortDescription="DevOps / Student @ LU / Cyclist"/>
        <KshaaSocial/>
      </div>
    </v-container>
  </v-content>
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
@import '@/styles/variables.scss';
.card {
  width: $mini-component-size;
}
</style>
