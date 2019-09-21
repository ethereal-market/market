import {h, sync} from '@playframe/playframe'

export default ({rainbow})=>
  rainbow._.init()
  <div class="rainbow"
       style={rainbow.style} />
