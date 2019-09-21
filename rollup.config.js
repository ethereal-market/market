import coffeescript from 'rollup-plugin-coffee-script'
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs'
import buble from 'rollup-plugin-buble'
import serve from 'rollup-plugin-serve'
import livereload from 'rollup-plugin-livereload'
import globals from 'rollup-plugin-node-globals'
import builtins from 'rollup-plugin-node-builtins'
import json from 'rollup-plugin-json';


export default {
  input: './src/app.coffee',
  plugins: [
    json({
      compact: true
    }),
    coffeescript(),
    buble( {jsx: 'h', target: {chrome: 71}}),
    globals(),
    builtins(),
    resolve(),
    commonjs({extensions: ['.js', '.coffee']}),
    serve({host: '0.0.0.0', contentBase:'public', headers: {
      'Access-Control-Allow-Origin': '*'
    }}),
    livereload({watch: 'public'})
  ],
  output: {
    file: 'public/bundle.js',
    name: 'APP',
    format: 'iife',
    sourcemap: true
  },
  watch: {
    include: ['src/**', 'build/contracts/**']
  }
};
