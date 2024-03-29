const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    'window.$': 'jquery/src/jquery',
    jquery: 'jquery/src/jquery',
    'window.jQuery': 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    Popper: ['popper.js', 'default'],
  })
)

module.exports = environment
