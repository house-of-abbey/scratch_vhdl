import * as Blockly from 'blockly';

export const toolbox: Blockly.utils.toolbox.ToolboxInfo = {
  kind: 'categoryToolbox',
  contents: [
    {
      kind: 'category',
      name: 'Literals',
      colour: '30',
      contents: [
        {
          kind: 'block',
          type: 'logic_boolean',
        },
        {
          kind: 'block',
          type: 'math_number',
          gap: 32,
          fields: {
            NUM: 123,
          },
        },
        {
          kind: 'block',
          type: 'value_std_logic',
        },
        {
          kind: 'block',
          type: 'value_std_logic_vector',
        },
        {
          kind: 'block',
          type: 'others_to',
        },
      ],
    },
    {
      kind: 'category',
      name: 'Logic',
      categorystyle: 'logic_category',
      contents: [
        {
          kind: 'block',
          type: 'controls_if',
        },
        {
          kind: 'block',
          type: 'controls_case',
        },
        {
          kind: 'block',
          type: 'controls_when',
        },
        {
          kind: 'block',
          type: 'logic_others',
        },
        {
          kind: 'block',
          type: 'logic_or',
        },
        {
          kind: 'block',
          type: 'logic_compare',
        },
        {
          kind: 'block',
          type: 'logic_operation',
        },
        {
          kind: 'block',
          type: 'logic_operation_vector',
        },
        {
          kind: 'block',
          type: 'logic_not',
        },
        {
          kind: 'block',
          type: 'logic_rising_edge',
        },
        {
          kind: 'block',
          type: 'report',
        },
      ],
    },
    // {
    //     'kind': 'category',
    //     'name': 'Loops',
    //     'categorystyle': 'loop_category',
    //     'contents': [
    //     ],
    // },
    {
      kind: 'category',
      name: 'Operations',
      categorystyle: 'math_category',
      contents: [
        {
          kind: 'block',
          type: 'math_arithmetic',
          inputs: {
            A: {
              shadow: {
                type: 'math_number',
                fields: {
                  NUM: 1,
                },
              },
            },
            B: {
              shadow: {
                type: 'math_number',
                fields: {
                  NUM: 1,
                },
              },
            },
          },
        },
        // {
        //     'kind': 'block',
        //     'type': 'math_number_property',
        //     'inputs': {
        //         'NUMBER_TO_CHECK': {
        //             'shadow': {
        //                 'type': 'math_number',
        //                 'fields': {
        //                     'NUM': 0,
        //                 },
        //             },
        //         },
        //     },
        // },
        {
          kind: 'block',
          type: 'list_index',
          inputs: {
            INDEX: {
              shadow: {
                type: 'math_number',
                fields: {
                  NUM: 0,
                },
              },
            },
          },
        },
        {
          kind: 'block',
          type: 'list_range',
        },
        {
          kind: 'block',
          type: 'list_concat',
        },
      ],
    },
    // {
    //     'kind': 'category',
    //     'name': 'Text',
    //     'categorystyle': 'text_category',
    //     'contents': [
    //         {
    //             'kind': 'block',
    //             'type': 'text',
    //         },
    //         {
    //             'kind': 'block',
    //             'type': 'text_multiline',
    //         },
    //         {
    //             'kind': 'label',
    //             'text': 'Input/Output:',
    //             'web-class': 'ioLabel',
    //         },
    //         {
    //             'kind': 'block',
    //             'type': 'text_print',
    //             'inputs': {
    //                 'TEXT': {
    //                     'shadow': {
    //                         'type': 'text',
    //                         'fields': {
    //                             'TEXT': 'abc',
    //                         },
    //                     },
    //                 },
    //             },
    //         },
    //         {
    //             'kind': 'block',
    //             'type': 'text_prompt_ext',
    //             'inputs': {
    //                 'TEXT': {
    //                     'shadow': {
    //                         'type': 'text',
    //                         'fields': {
    //                             'TEXT': 'abc',
    //                         },
    //                     },
    //                 },
    //             },
    //         },
    //     ],
    // },
    {
      kind: 'sep',
    },
    {
      kind: 'category',
      name: 'Signals',
      categorystyle: 'variable_category',
      contents: [
        {
          kind: 'block',
          type: 'variables_get',
        },
        {
          kind: 'block',
          type: 'variables_set',
        },
        {
          kind: 'block',
          type: 'variables_set_index',
          inputs: {
            INDEX: {
              shadow: {
                type: 'math_number',
                fields: {
                  NUM: 0,
                },
              },
            },
          },
        },
      ],
    },
    // {
    //     "kind": "category",
    //     "name": "Functions & Procedures",
    //     'categorystyle': 'procedure_category',
    //     "custom": "PROCEDURE"
    // },
    {
      kind: 'category',
      name: 'Processes',
      colour: '190',
      contents: [
        {
          kind: 'block',
          type: 'process',
        },
        {
          kind: 'block',
          type: 'process_wait',
        },
        {
          kind: 'block',
          type: 'process_direct_set',
        },
      ],
    },
  ],
};

Blockly.defineBlocksWithJsonArray([
  {
    kind: 'block',
    type: 'process_wait',
    message0: 'wait',
    args0: [],
    previousStatement: null,
    nextStatement: null,
    colour: 190,
    tooltip: 'A VHDL wait statement',
  },
  {
    type: 'process_direct_set',
    message0: 'directly set %1 to %2',
    colour: '%{BKY_VARIABLES_HUE}',
    args0: [
      {
        type: 'field_var',
        name: 'VAR',
        variable: 'clk',
      },
      {
        type: 'input_value', // This expects an input of any type
        name: 'VALUE',
      },
    ],
    tooltip:
      'Create a process that is sensitive to all that does `let <= VALUE`',
  },
  {
    kind: 'block',
    type: 'value_std_logic',
    colour: 30,
    message0: "'%1'",
    args0: [
      {
        type: 'field_number',
        name: 'VALUE',
        min: 0,
        max: 1,
        precision: 1,
        value: 1,
      },
    ],
    output: null,
    tooltip: 'STD_LOGIC input',
  },
  {
    kind: 'block',
    type: 'value_std_logic_vector',
    colour: 30,
    message0: '"%1"',
    args0: [
      {
        type: 'field_input',
        name: 'VALUE',
      },
    ],
    output: null,
    tooltip: 'STD_LOGIC_VECTOR input',
  },
  {
    kind: 'block',
    type: 'logic_operation_vector',
    message0: '%1 %2',
    args0: [
      {
        type: 'field_dropdown',
        name: 'OPERATION',
        options: [
          ['AND', 'and'],
          ['OR', 'or'],
          ['XOR', 'xor'],
          ['NOR', 'nor'],
          ['NAND', 'nand'],
          ['XNOR', 'xnor'],
        ],
      },
      {
        type: 'input_value',
        name: 'LIST',
      },
    ],
    output: 'Boolean',
    inputsInline: true,
    style: 'logic_blocks',
    tooltip: 'Do a logic operation with the bits of the vector as input.',
  },
  {
    kind: 'block',
    type: 'logic_not',
    message0: 'not %1',
    args0: [
      {
        type: 'input_value',
        name: 'INPUT',
      },
    ],
    output: 'Boolean',
    inputsInline: true,
    style: 'logic_blocks',
    tooltip: 'Inverts input',
  },
  {
    kind: 'block',
    type: 'others_to',
    message0: 'others => %1',
    args0: [
      {
        type: 'input_value',
        name: 'INPUT',
      },
    ],
    output: null,
    inputsInline: true,
    colour: '%{BKY_MATH_HUE}',
    tooltip: 'Creates a list of inferred length',
  },
  {
    kind: 'block',
    type: 'logic_operation',
    message0: '%1 %2 %3',
    args0: [
      {
        type: 'input_value',
        name: 'A',
      },
      {
        type: 'field_dropdown',
        name: 'OPERATION',
        options: [
          ['AND', 'and'],
          ['OR', 'or'],
          ['XOR', 'xor'],
          ['NOR', 'nor'],
          ['NAND', 'nand'],
          ['XNOR', 'xnor'],
        ],
      },
      {
        type: 'input_value',
        name: 'B',
      },
    ],
    output: 'Boolean',
    style: 'logic_blocks',
    inputsInline: true,
    tooltip: 'Do a logic operation with A and B as inputs',
  },
  {
    kind: 'block',
    type: 'list_index',
    message0: '%1 %2',
    colour: '%{BKY_MATH_HUE}',
    args0: [
      {
        type: 'input_value',
        name: 'LIST',
      },
      {
        type: 'input_value',
        name: 'INDEX',
      },
    ],
    output: null,
    inputsInline: true,
    tooltip: 'List index',
  },
  {
    kind: 'block',
    type: 'list_range',
    message0: '%1 %2 %3 %4',
    colour: '%{BKY_MATH_HUE}',
    args0: [
      {
        type: 'input_value',
        name: 'LIST',
      },
      {
        type: 'field_number',
        name: 'FROM',
        min: 0,
        value: 0,
      },
      {
        type: 'field_dropdown',
        name: 'ORDER',
        options: [
          ['to', 'to'],
          ['downto', 'downto'],
        ],
      },
      {
        type: 'field_number',
        name: 'TO',
        min: 0,
        value: 0,
      },
    ],
    output: null,
    tooltip: 'Logic range',
  },
  {
    kind: 'block',
    type: 'list_concat',
    message0: '%1 & %2',
    colour: '%{BKY_MATH_HUE}',
    args0: [
      {
        type: 'input_value',
        name: 'A',
      },
      {
        type: 'input_value',
        name: 'B',
      },
    ],
    output: null,
    inputsInline: true,
    tooltip: 'Join 2 lists together',
  },
  {
    type: 'variables_set',
    message0: 'set %1 to %2',
    colour: '%{BKY_VARIABLES_HUE}',
    args0: [
      {
        type: 'field_var',
        name: 'VAR',
        variable: 'clk',
      },
      {
        type: 'input_value', // This expects an input of any type
        name: 'VALUE',
      },
    ],
    inputsInline: true,
    previousStatement: null,
    nextStatement: null,
    tooltip: 'Set a signal',
  },
  {
    type: 'variables_get',
    message0: '%1',
    colour: '%{BKY_VARIABLES_HUE}',
    args0: [
      {
        type: 'field_var',
        name: 'VAR',
        variable: 'clk',
      },
    ],
    inputsInline: true,
    output: null,
    tooltip: 'Get a signal',
  },
  {
    type: 'variables_set_index',
    message0: 'set %1 %2 to %3',
    colour: '%{BKY_VARIABLES_HUE}',
    args0: [
      {
        type: 'field_var',
        name: 'VAR',
        variable: 'clk',
      },
      {
        type: 'input_value',
        name: 'INDEX',
      },
      {
        type: 'input_value', // This expects an input of any type
        name: 'VALUE',
      },
    ],
    inputsInline: true,
    previousStatement: null,
    nextStatement: null,
    tooltip: 'Set an index of a  signal',
  },
  {
    kind: 'block',
    type: 'logic_rising_edge',
    message0: 'rising_edge %1',
    args0: [
      {
        type: 'field_var',
        name: 'dep',
        variable: 'clk',
      },
    ],
    output: 'Boolean',
    style: 'logic_blocks',
    tooltip: 'Goes high in the rising edge of the variable',
  },
  {
    kind: 'block',
    type: 'report',
    message0: 'report %1',
    args0: [
      {
        type: 'field_input',
        name: 'S',
      },
    ],
    previousStatement: null,
    nextStatement: null,
    tooltip: 'print a message in the simulator (does not synthesise)',
  },
  {
    kind: 'block',
    type: 'controls_case',
    message0: 'case %1 is',
    args0: [
      {
        type: 'input_value',
        name: 'ON',
      },
    ],
    message1: '%1',
    args1: [
      {
        type: 'input_statement',
        name: 'body',
        check: ['controls_when'],
      },
    ],
    colour: '%{BKY_LOGIC_HUE}',
    previousStatement: null,
    nextStatement: null,
    inputsInline: true,
    tooltip: 'case',
  },
  {
    kind: 'block',
    type: 'controls_when',
    message0: 'when %1',
    args0: [
      {
        type: 'input_value',
        name: 'TEST',
      },
    ],
    message1: '%1',
    args1: [{ type: 'input_statement', name: 'body' }],
    colour: '%{BKY_LOGIC_HUE}',
    previousStatement: 'controls_when',
    nextStatement: 'controls_when',
    tooltip: 'when',
  },
  {
    kind: 'block',
    type: 'logic_others',
    message0: 'others',
    colour: '%{BKY_LOGIC_HUE}',
    args0: [],
    output: null,
    tooltip:
      "The pattern for anything that doesn't match any other patterns",
  },
  {
    kind: 'block',
    type: 'logic_or',
    message0: '%1 | %2',
    colour: '%{BKY_LOGIC_HUE}',
    args0: [
      {
        type: 'input_value',
        name: 'A',
      },
      {
        type: 'input_value',
        name: 'B',
      },
    ],
    inputsInline: true,
    output: null,
    tooltip: 'The pattern that matches both of the patterns supplied',
  },
]);
