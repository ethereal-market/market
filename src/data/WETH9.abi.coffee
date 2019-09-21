# https://github.com/0xProject/0x-monorepo/blob/0c9daa693/packages/abi-gen-wrappers/src/generated-wrappers/weth9.ts#L1355

export default [
  {
    constant: true,
    inputs: [],
    name: 'name',
    outputs: [
      {
        name: '',
        type: 'string',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: false,
    inputs: [
      {
        name: 'guy',
        type: 'address',
      },
      {
        name: 'wad',
        type: 'uint256',
      },
    ],
    name: 'approve',
    outputs: [
      {
        name: '',
        type: 'bool',
      },
    ],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    constant: true,
    inputs: [],
    name: 'totalSupply',
    outputs: [
      {
        name: '',
        type: 'uint256',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: false,
    inputs: [
      {
        name: 'src',
        type: 'address',
      },
      {
        name: 'dst',
        type: 'address',
      },
      {
        name: 'wad',
        type: 'uint256',
      },
    ],
    name: 'transferFrom',
    outputs: [
      {
        name: '',
        type: 'bool',
      },
    ],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    constant: false,
    inputs: [
      {
        name: 'wad',
        type: 'uint256',
      },
    ],
    name: 'withdraw',
    outputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    constant: true,
    inputs: [],
    name: 'decimals',
    outputs: [
      {
        name: '',
        type: 'uint8',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: true,
    inputs: [
      {
        name: 'index_0',
        type: 'address',
      },
    ],
    name: 'balanceOf',
    outputs: [
      {
        name: '',
        type: 'uint256',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: true,
    inputs: [],
    name: 'symbol',
    outputs: [
      {
        name: '',
        type: 'string',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: false,
    inputs: [
      {
        name: 'dst',
        type: 'address',
      },
      {
        name: 'wad',
        type: 'uint256',
      },
    ],
    name: 'transfer',
    outputs: [
      {
        name: '',
        type: 'bool',
      },
    ],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    constant: false,
    inputs: [],
    name: 'deposit',
    outputs: [],
    payable: true,
    stateMutability: 'payable',
    type: 'function',
  },
  {
    constant: true,
    inputs: [
      {
        name: 'index_0',
        type: 'address',
      },
      {
        name: 'index_1',
        type: 'address',
      },
    ],
    name: 'allowance',
    outputs: [
      {
        name: '',
        type: 'uint256',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    outputs: [],
    payable: true,
    stateMutability: 'payable',
    type: 'fallback',
  },
  {
    anonymous: false,
    inputs: [
      {
        name: '_owner',
        type: 'address',
        indexed: true,
      },
      {
        name: '_spender',
        type: 'address',
        indexed: true,
      },
      {
        name: '_value',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Approval',
    outputs: [],
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        name: '_from',
        type: 'address',
        indexed: true,
      },
      {
        name: '_to',
        type: 'address',
        indexed: true,
      },
      {
        name: '_value',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Transfer',
    outputs: [],
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        name: '_owner',
        type: 'address',
        indexed: true,
      },
      {
        name: '_value',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Deposit',
    outputs: [],
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        name: '_owner',
        type: 'address',
        indexed: true,
      },
      {
        name: '_value',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Withdrawal',
    outputs: [],
    type: 'event',
  },
]
