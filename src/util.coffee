export toFixed = (number, decimals)=>
  decimals or= 8 # TODO maybe remove
  decimals = Math.min decimals, 8
  if (not number and number != 0) or isNaN number
    ''
  else
    number.toFixed decimals

export toBigString = (number)=>
  number.toLocaleString 'en', useGrouping: false, maximumFractionDigits: 0


