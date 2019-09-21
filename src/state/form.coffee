import {toFixed} from '../util'

export default ()=>
  values: {}
  updates: {}

  _:
    readNumberAndAdjust: (field)=>(adjust)=>(decimals)=>({target}, state)=>
      {values} = state
      if value = values[field] = target.value and parseFloat target.value
        if (field is 'price limit' and adjust is 'total' and values.amount) or
            (field is 'amount' and adjust is 'total' and values['price limit'])
          state.updates.total = values['price limit'] * values.amount
          state._ {} # trigger render
        else if field is 'total' and adjust is 'amount' and values['price limit']
          state.updates.amount = values.total / values['price limit']
          state._ {}
      return


    updateInputValue: (field)=>(decimals)=>(target, state)=>
      if (update = state.updates[field])?
        target.value = toFixed state.values[field] = update, decimals
        # silent mutation, don't trigger rerender
        state._().updates = `{
          ...state.updates,
          [field]: undefined
        }`
      return
