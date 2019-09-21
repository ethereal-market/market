import coffeescript from 'rollup-plugin-coffee-script'
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs'
import buble from 'rollup-plugin-buble'
import globals from 'rollup-plugin-node-globals'
import builtins from 'rollup-plugin-node-builtins'
import json from 'rollup-plugin-json';
import { terser } from 'rollup-plugin-terser'


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
    terser()
  ],
  output: {
    file: 'public/bundle.js',
    name: 'APP',
    format: 'iife',
    sourcemap: true
  }
};
