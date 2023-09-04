import * as Blockly from 'blockly';
import { ProcessBlock } from './ProcessBlock';
import { mergeDeep } from '../utilities/mergeDeep';
import { Entity } from '../types';

const Order = {
  ATOMIC: 0,
  FUNCTION_CALL: 1,
  INDEX: 1.1,
  CONCAT: 2,
  MUL: 3.0,
  DIV: 3.1,
  SUB: 4.1,
  ADD: 4.2,
  NOT: 5,
  COMPARE: 6,
  LOGIC: 7,
  NONE: 99,
} as const;

const VHDLGenerator: Blockly.Generator & {
  Order?: typeof Order;
} = new Blockly.Generator('VHDL');

VHDLGenerator.Order = Order;

//@ts-expect-error it is private but i want to
VHDLGenerator.scrub_ = function (block, code, opt_thisOnly) {
  let commentCode = '';
  // Only collect comments for blocks that aren't inline.
  if (
    !block.outputConnection ||
    !block.outputConnection.targetConnection
  ) {
    // Collect comment for this block.
    let comment = block.getCommentText();
    if (comment) {
      comment = Blockly.utils.string.wrap(
        comment,
        VHDLGenerator.COMMENT_WRAP - 3
      );
      commentCode += VHDLGenerator.prefixLines(comment, '-- ') + '\n';
    }
    // Collect comments for all value arguments.
    // Don't collect comments for nested statements.
    for (let i = 0; i < block.inputList.length; i++) {
      if (block.inputList[i].type === Blockly.inputTypes.VALUE) {
        const childBlock = block.inputList[i].connection?.targetBlock();
        if (childBlock) {
          comment = VHDLGenerator.allNestedComments(childBlock);
          if (comment) {
            commentCode += VHDLGenerator.prefixLines(comment, '-- ');
          }
        }
      }
    }
  }
  const nextBlock =
    block.nextConnection && block.nextConnection.targetBlock();
  const nextCode = opt_thisOnly
    ? ''
    : VHDLGenerator.blockToCode(nextBlock);
  return commentCode + code + nextCode;
};

//@ts-expect-error it will be a process block
VHDLGenerator.forBlock['process'] = function (block: ProcessBlock) {
  return (
    '\n  process' +
    ((a) => (a.length > 0 ? '(' + a + ')' : ''))(
      block.all_
        ? 'all'
        : block.inputList[0].fieldRow
            .filter((a) => a instanceof Blockly.FieldVariable)
            .map((a) => a.getText())
            .join(', ')
    ) +
    '\n  begin\n  ' +
    VHDLGenerator.statementToCode(block, 'body').replace(/\n/g, '\n  ') +
    'end process;'
  );
};

VHDLGenerator.forBlock['process_wait'] = function (block) {
  return 'wait;\n';
};

VHDLGenerator.forBlock['process_direct_set'] = function (block) {
  return (
    '\n  ' +
    block.getField('VAR')?.getText() +
    ' <= ' +
    VHDLGenerator.valueToCode(block, 'VALUE', Order.NONE) +
    ';'
  );
};

VHDLGenerator.forBlock['controls_if'] = function (block) {
  let n = 0;
  let code = '';
  while (block.getInput('IF' + n)) {
    const conditionCode =
      VHDLGenerator.valueToCode(block, 'IF' + n, Order.NONE) || 'false';
    const branchCode = VHDLGenerator.statementToCode(block, 'DO' + n);
    code +=
      (n > 0 ? 'els' : '') +
      'if ' +
      conditionCode +
      ' then\n' +
      branchCode;
    n++;
  }

  if (block.getInput('ELSE')) {
    const branchCode = VHDLGenerator.statementToCode(block, 'ELSE');
    code += 'else\n' + branchCode;
  }
  return code + 'end if;\n';
};

VHDLGenerator.forBlock['controls_case'] = function (block) {
  return (
    'case ' +
    VHDLGenerator.valueToCode(block, 'ON', Order.NONE) +
    ' is\n' +
    VHDLGenerator.statementToCode(block, 'body') +
    'end case;\n'
  );
};

VHDLGenerator.forBlock['controls_when'] = function (block) {
  return (
    'when ' +
    VHDLGenerator.valueToCode(block, 'TEST', Order.NONE) +
    ' =>\n' +
    VHDLGenerator.statementToCode(block, 'body') +
    '\n'
  );
};

VHDLGenerator.forBlock['logic_others'] = function (block) {
  return ['others', Order.ATOMIC];
};

VHDLGenerator.forBlock['others_to'] = function (block) {
  return [
    '(others => ' +
      VHDLGenerator.valueToCode(block, 'INPUT', Order.NONE) +
      ')',
    Order.ATOMIC,
  ];
};

VHDLGenerator.forBlock['logic_or'] = function (block) {
  return [
    VHDLGenerator.valueToCode(block, 'A', Order.NONE) +
      ' | ' +
      VHDLGenerator.valueToCode(block, 'B', Order.NONE),
    Order.ATOMIC,
  ];
};

VHDLGenerator.forBlock['logic_rising_edge'] = function (block) {
  return [
    'rising_edge(' + block.getField('dep')?.getText() + ')',
    Order.FUNCTION_CALL,
  ];
};

VHDLGenerator.forBlock['logic_not'] = function (block) {
  return [
    'not ' + VHDLGenerator.valueToCode(block, 'INPUT', Order.NOT),
    Order.NOT,
  ];
};

VHDLGenerator.forBlock['logic_boolean'] = function (block) {
  return [block.getFieldValue(''), Order.ATOMIC];
};

VHDLGenerator.forBlock['logic_operation'] = function (block) {
  return [
    VHDLGenerator.valueToCode(block, 'A', Order.LOGIC) +
      ' ' +
      block.getFieldValue('OPERATION') +
      ' ' +
      VHDLGenerator.valueToCode(block, 'B', Order.LOGIC),
    Order.LOGIC,
  ];
};

VHDLGenerator.forBlock['logic_operation_vector'] = function (block) {
  return [
    block.getFieldValue('OPERATION') +
      '(' +
      VHDLGenerator.valueToCode(block, 'LIST', Order.NONE) +
      ')',
    Order.FUNCTION_CALL,
  ];
};

VHDLGenerator.forBlock['logic_compare'] = function (block) {
  const OPERATORS = {
    EQ: '=',
    NEQ: '/=',
    LT: '<',
    LTE: '<=',
    GT: '>',
    GTE: '>=',
  };
  return [
    VHDLGenerator.valueToCode(block, 'A', Order.COMPARE) +
      ' ' +
      OPERATORS[block.getFieldValue('OP')] +
      ' ' +
      VHDLGenerator.valueToCode(block, 'B', Order.COMPARE),
    Order.COMPARE,
  ];
};

VHDLGenerator.forBlock['variables_get'] = function (block) {
  return [block.getField('VAR')?.getText() ?? '', Order.ATOMIC];
};

VHDLGenerator.forBlock['constant'] = function (block) {
  return [block.getFieldValue('NAME'), Order.ATOMIC];
};

VHDLGenerator.forBlock['variables_set'] = function (block) {
  return (
    block.getField('VAR')?.getText() +
    ' <= ' +
    VHDLGenerator.valueToCode(block, 'VALUE', Order.NONE) +
    ';\n'
  );
};

VHDLGenerator.forBlock['variables_set_index'] = function (block) {
  return (
    block.getField('VAR')?.getText() +
    '(' +
    VHDLGenerator.valueToCode(block, 'INDEX', Order.NONE) +
    ') <= ' +
    VHDLGenerator.valueToCode(block, 'VALUE', Order.NONE) +
    ';\n'
  );
};

VHDLGenerator.forBlock['math_change'] = function (block) {
  return (
    block.getField('VAR')?.getText() +
    ' <= ' +
    block.getField('VAR')?.getText() +
    ' + ' +
    VHDLGenerator.valueToCode(block, 'DELTA', Order.ADD) +
    ';\n'
  );
};

VHDLGenerator.forBlock['value_std_logic'] = function (block) {
  return ["'" + block.getFieldValue('VALUE') + "'", Order.ATOMIC];
};

VHDLGenerator.forBlock['value_std_logic_vector'] = function (block) {
  return ['"' + block.getFieldValue('VALUE') + '"', Order.ATOMIC];
};

VHDLGenerator.forBlock['math_number'] = function (block) {
  return [block.getFieldValue('NUM'), Order.ATOMIC];
};

VHDLGenerator.forBlock['math_arithmetic'] = function (block) {
  // Basic arithmetic operators, and power.
  const OPERATORS = {
    ADD: [' + ', Order.ADD],
    MINUS: [' - ', Order.SUB],
    MULTIPLY: [' * ', Order.MUL],
    DIVIDE: [' / ', Order.DIV],
  };
  const tuple = OPERATORS[block.getFieldValue('OP')];
  const order = tuple[1];
  return [
    (VHDLGenerator.valueToCode(block, 'A', order) || '0') +
      tuple[0] +
      (VHDLGenerator.valueToCode(block, 'B', order) || '0'),
    order,
  ];
};

VHDLGenerator.forBlock['list_index'] = function (block) {
  return [
    VHDLGenerator.valueToCode(block, 'LIST', Order.INDEX) +
      '(' +
      VHDLGenerator.valueToCode(block, 'INDEX', Order.NONE) +
      ')',
    ['list_index', 'list_range'].includes(block.getParent()?.type ?? '')
      ? Order.ATOMIC
      : Order.INDEX,
  ];
};

VHDLGenerator.forBlock['list_range'] = function (block) {
  return [
    VHDLGenerator.valueToCode(block, 'LIST', Order.INDEX) +
      '(' +
      block.getFieldValue('FROM') +
      ' ' +
      block.getFieldValue('ORDER') +
      ' ' +
      block.getFieldValue('TO') +
      ')',
    ['list_index', 'list_range'].includes(block.getParent()?.type ?? '')
      ? Order.ATOMIC
      : Order.INDEX,
  ];
};

VHDLGenerator.forBlock['list_concat'] = function (block) {
  return [
    VHDLGenerator.valueToCode(block, 'A', Order.CONCAT) +
      ' & ' +
      VHDLGenerator.valueToCode(block, 'B', Order.CONCAT),
    Order.CONCAT,
  ];
};

VHDLGenerator.forBlock['report'] = function (block) {
  return 'report ' + block.getFieldValue('S') + ';\n';
};

// TODO: finish
// VHDLGenerator.procedures_defreturn = function (block) {
//     // Define a procedure with a return value.
//     const funcName = block.getFieldValue("NAME");
//     let branch = VHDLGenerator.statementToCode(block, 'STACK');
//     let returnValue = VHDLGenerator.valueToCode(block, 'RETURN', VHDLGeneratorPrecedence.NONE) || '';
//     if (returnValue) {
//         returnValue = 'return ' + returnValue + '\n';
//     } else if (!branch) {
//         branch = '';
//     }
//     const args = [];
//     const variables = block.getVars();
//     for (let i = 0; i < variables.length; i++) {
//         args[i] = variables[i].name;
//     }
//     return 'function ' + funcName + '(' + args.join('; ') + ')\n' + branch + returnValue + 'end function;\n';
// };

// VHDLGenerator.procedures_defnoreturn = function (block) {
//     // Define a procedure with a return value.
//     const funcName = block.getFieldValue("NAME");
//     let branch = VHDLGenerator.statementToCode(block, 'STACK') || "";
//     const args = [];
//     const variables = block.getVars();
//     for (let i = 0; i < variables.length; i++) {
//         args[i] = variables[i].name;
//     }
//     return 'function ' + funcName + '(' + args.join(', ') + ')\n' + branch + returnValue + 'end\n';
// };

// VHDLGenerator.procedures_callreturn = function (block) {
//     const funcName = block.getFieldValue('NAME');
//     const args = [];
//     const variables = block.getVars();
//     for (let i = 0; i < variables.length; i++) {
//         args[i] = Lua.valueToCode(block, 'ARG' + i, Lua.NONE) || 'nil';
//     }
//     const code = funcName + '(' + args.join(', ') + ')';
//     return [code, Lua.HIGH];
// };

// Lua['procedures_callnoreturn'] = function (block) {
//     // Call a procedure with no return value.
//     // Generated code is for a function call as a statement is the same as a
//     // function call as a value, with the addition of line ending.
//     const tuple = Lua['procedures_callreturn'](block);
//     return tuple[0] + '\n';
// };

// Lua['procedures_ifreturn'] = function (block) {
//     // Conditionally return value from a procedure.
//     const condition =
//         Lua.valueToCode(block, 'CONDITION', Lua.NONE) || 'false';
//     let code = 'if ' + condition + ' then\n';
//     if (Lua.STATEMENT_SUFFIX) {
//         // Inject any statement suffix here since the regular one at the end
//         // will not get executed if the return is triggered.
//         code +=
//             Lua.prefixLines(Lua.injectId(Lua.STATEMENT_SUFFIX, block), Lua.INDENT);
//     }
//     if (block.hasReturnValue_) {
//         const value = Lua.valueToCode(block, 'VALUE', Lua.NONE) || 'nil';
//         code += Lua.INDENT + 'return ' + value + '\n';
//     } else {
//         code += Lua.INDENT + 'return\n';
//     }
//     code += 'end\n';
//     return code;
// };

export default VHDLGenerator;

export function generate(
  ws: Blockly.Workspace,
  filename: string,
  entity: Entity
): string {
  function gen_signals(signals) {
    return Object.keys(signals)
      .map(
        (n) =>
          '\n  signal ' +
          n +
          ' : ' +
          (signals[n] instanceof Array
            ? signals[n][0] +
              (signals[n][1] && signals[n][1] != ''
                ? ' := ' + signals[n][1]
                : '')
            : signals[n]) +
          ';'
      )
      .join('');
  }
  const libraries = mergeDeep<Entity['libraries']>(
    {
      ieee: {
        std_logic_1164: null,
      },
    },
    entity.libraries
  );
  return (
    Object.keys(libraries)
      .map(
        (l) =>
          'library ' +
          l +
          ';' +
          Object.keys(libraries[l])
            .map((p) => '\n  use ' + l + '.' + p + '.all;')
            .join('')
      )
      .join('\n') +
    (!entity.name
      ? '\n\n' +
        'entity ' +
        filename +
        ' is\n  port(' +
        Object.keys(entity.entity)
          .map(
            (n) =>
              '\n    ' +
              n +
              ' : ' +
              entity.entity[n][0] +
              ' ' +
              entity.entity[n][1]
          )
          .join(';') +
        '\n  );\nend entity;'
      : '') +
    '\n\n\narchitecture scratch of ' +
    (entity.name || filename) +
    ' is\n' +
    Object.keys(entity.constants)
      .map(
        (n) =>
          '\n  constant ' +
          n +
          ' : ' +
          entity.constants[n][0] +
          ' := ' +
          entity.constants[n][1] +
          ';'
      )
      .join('') +
    '\n' +
    gen_signals(entity.signals) +
    '\n' +
    Object.keys(entity.aliases)
      .map((n) => '\n  alias ' + n + ' is ' + entity.aliases[n] + ';')
      .join('') +
    '\n\nbegin\n' +
    VHDLGenerator.workspaceToCode(ws) +
    '\n\nend architecture;\n'
  );
}
