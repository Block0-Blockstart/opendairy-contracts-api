module.exports = {
  plugins: [],
  extends: [],
  root: true,
  env: {
    es6: true,
    node: true,
    jest: true,
  },
  rules: {
    'arrow-parens': [2, 'as-needed'],
    'camelcase': ['error', {
      'properties': 'always',
      'allow':['_']
     }],
    'comma-dangle': ['error', {
      'arrays': 'always-multiline',
      'objects': 'always-multiline',
      'exports': 'always-multiline',
      'functions': 'only-multiline',
    }],
    'comma-spacing': ['error', {
      'before': false,
      'after': true
    }],
    'dot-notation': ['error', {
      'allowKeywords': true,
      'allowPattern': ''
    }],
    'eol-last': ['error', 'always'],
    'eqeqeq': ['error', 'smart'],
    'generator-star-spacing': ['error', 'before'],
    'indent': ['error', 2],
    'linebreak-style': ['error', 'unix'],
    'max-len': ['error', 120, 2],
    'no-debugger': 'off',
    'no-dupe-args': 'error',
    'no-dupe-keys': 'error',
    'no-mixed-spaces-and-tabs': ['error', 'smart-tabs'],
    'no-redeclare': ['error', {'builtinGlobals': true}],
    'no-trailing-spaces': ['error', { 'skipBlankLines': false }],
    'no-undef': 'error',
    'no-use-before-define': 'off',
    'no-var': 'error',
    'object-curly-newline': 'off',
    'object-curly-spacing': ['error', 'always'],
    'prefer-const': 'error',
    'quotes': ['error', 'single'],
    'semi': ['error', 'always'],
    'space-before-blocks': ['error', 'always'],
    'space-before-function-paren': ['error', {
      'anonymous': 'always',
      'named': 'never',
      'anonymous': 'always'
    }],
    'strict': ['error', 'global']
  },
};