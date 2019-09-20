const exportData = {
  devServer: {
    disableHostCheck: true,
  },
};

if (process.env.OUTPUT_DIR) {
  exportData.outputDir = process.env.OUTPUT_DIR;
}

module.exports = exportData;
