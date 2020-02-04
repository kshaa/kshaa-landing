<template>
  <v-content>
    <v-container class="guestbook px-1 fill-height flex-column justify-center" fluid>
      <h2 class="headline font-weight-bold">Guestbook submissions</h2>
      <p>Read messages from the guestbook</p>
      <div class="list">
        <div class="entry" v-for="entry in pageEntries" v-bind:key="entry.id">
          <div class="message">{{ entry.message }}</div>
          <div class="meta">
            <span class="os">
              {{ entry.parsedAgent.os.name || 'Unknown OS' }}
            </span>
            <span class="separator"> | </span>
            <span class="browser">
              {{ entry.parsedAgent.browser.name || 'Unknown browser' }}
            </span>
            <span class="separator"> | </span>
            <span class="ipAddress">
              {{ entry.ipAddress }}
            </span>
            <span class="separator"> | </span>
            <span class="createdAt">
              {{ entry.formattedCreatedAt }}
            </span>
          </div>
        </div>
        <p class="error" v-if="error">{{error}} :(</p>
      </div>
    </v-container>
  </v-content>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';

interface PageEntry {
  userAgent?: {}
  parsedAgent: {
    os?: {
      name: string
    }
    browser?: {
      name: string
    }
  },
  ipAddress : string
  createdAt? : string
  formattedCreatedAt : string
  message : string
}

// @ts-ignore
const uaParser = require('ua-parser-js');

@Component({
  metaInfo: {
    title: 'Guestbook - Read messages',
  },
})
export default class GuestbookReader extends Vue {
  pageEntries?: Array<PageEntry>|null

  loading?: boolean

  error?: string | null

  static data() {
    return {
      loading: false,
      error: null,
      pageEntries: [],
    };
  }

  created() {
    // fetch the data when the view is created and the data is
    // already being observed
    this.fetchData();
  }

  fetchData(this: GuestbookReader) {
    this.error = null;
    this.pageEntries = [];
    this.loading = true;
    Vue.axios.get('/api/guestbook/read').then((response: any) => {
      this.error = null;
      this.pageEntries = [];

      const srcPageEntries = response.data.pageEntries as Array<PageEntry>;
      srcPageEntries.forEach(function formatPageEntry(this: GuestbookReader, srcEntry) {
        // Formatted agent data
        let parsedAgent = {};
        try {
          parsedAgent = uaParser(srcEntry.userAgent);
        } catch (error) {
          /* eslint-disable no-console */
          console.warn('Failed parsing a user agent for a guestbook entry.', srcEntry, error);
          /* eslint-enable no-console */
        }
        // Formatted date
        let formattedCreatedAt = '';
        try {
          const dateLV = (new Date(srcEntry.createdAt || 0)).toLocaleString('lv-LV');
          formattedCreatedAt = `${dateLV} LV`;
        } catch (error) {
          /* eslint-disable no-console */
          console.warn('Failed parsing a date for a guestbook entry.', srcEntry, error);
          /* eslint-enable no-console */
        }

        const entry : PageEntry = {
          parsedAgent,
          formattedCreatedAt,
          ipAddress: srcEntry.ipAddress,
          message: srcEntry.message,
        };

        // Exclamation means "I know 'this.pageEntries' won't be null or undefined"
        this.pageEntries!.push(entry);
      });
    }).catch((e) => {
      if (e.response.status === 401) {
        this.error = 'You are not authorized to view guestbook messages.';
      } else {
        this.error = 'Failed fetching guestbook messages.';
      }
      this.pageEntries = null;
    });
  }
}
</script>

<style lang="scss" scoped>
.title {
  color: white;
}

.message {
  font-size: 18px;
  margin-bottom: 10px;
  white-space: pre-wrap;
}

.error {
  color: red;
}

.entry {
  word-break: break-word;
  margin: 20px 5px;
  padding: 10px;
  text-align: left;
  background: white;
  color: #333;
  border-radius: 3px;

  .meta {
    color: #666;
  }
}
</style>
