/* eslint-disable @typescript-eslint/no-var-requires */
/* global require __dirname */

const tsj = require('ts-json-schema-generator');
const path = require('path');
const fs = require('fs');

fs.writeFileSync(
  path.join(__dirname, './sbe.schema.json'),
  JSON.stringify(
    tsj
      .createGenerator({
        path: path.join(__dirname, './src/types.ts'),
        tsconfig: path.join(__dirname, './tsconfig.json'),
        type: 'Entity',
      })
      .createSchema('Entity'),
    null,
    2
  )
);
