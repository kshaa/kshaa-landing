const exportData = {
  devServer: {
    disableHostCheck: true,
  },
  configureWebpack: {
    // For breakpoint-debugging Vue from VSCode
    devtool: 'source-map',
  },
  transpileDependencies: [
    'vuetify',
  ],
};

if (process.env.OUTPUT_DIR) {
  exportData.outputDir = process.env.OUTPUT_DIR;
}

if (process.env.API_URL_PREFIX && process.env.BACKEND_HOST) {
  exportData.devServer.proxy = {};
  exportData.devServer.proxy[`^${process.env.API_URL_PREFIX}`] = {
    target: process.env.BACKEND_HOST,
    prependPath: false,
    changeOrigin: true,
  };
}

module.exports = exportData;
