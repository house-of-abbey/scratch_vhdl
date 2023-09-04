import * as Blockly from 'blockly';
import { FieldVar } from './main';

Blockly.defineBlocksWithJsonArray([
  {
    kind: 'block',
    type: 'process',
    message0: 'process %1',
    args0: [
      {
        type: 'field_var',
        name: '1',
        variable: 'clk',
      },
    ],
    message1: '%1',
    args1: [{ type: 'input_statement', name: 'body' }],
    colour: 190,
    mutator: 'process_mutator',
    tooltip: 'A VHDL process',
  },
]);

interface ProcessBlockState {
  depCount: number;
  all: boolean;
}

export type ProcessBlock = Blockly.Block & ProcessMixin;
interface ProcessMixin extends ProcessMixinType {
  depCount_: number;
  prevDepCount_: number;
  all_: boolean;
}
type ProcessMixinType = typeof PROCESS;

const PROCESS = {
  /**
   * Modify this block to have the correct number of inputs.
   */
  updateShape_: function (this: ProcessBlock) {
    if (this.all_) {
      if (this.prevDepCount_ > 0) {
        for (let i = this.prevDepCount_; i > 0; i--) {
          this.inputList[0].removeField(i.toString(), true);
        }
      }
      this.prevDepCount_ = 0;
      this.inputList[0].removeField('all', true);
      this.inputList[0].appendField(new Blockly.FieldLabel('all'), 'all');
    } else {
      this.inputList[0].removeField('all', true);
      if (this.prevDepCount_ < this.depCount_) {
        for (let i = this.prevDepCount_ + 1; i <= this.depCount_; i++) {
          this.inputList[0].appendField(
            new Blockly.FieldVariable(null),
            (i + 1).toString()
          );
        }
      } else if (this.prevDepCount_ > this.depCount_) {
        for (let i = this.prevDepCount_; i > this.depCount_; i--) {
          this.inputList[0].removeField((i + 1).toString());
        }
      }
      this.prevDepCount_ = this.depCount_;
    }
  },

  /**
   * Returns the state of this block as a JSON serializable object.
   *
   * @returns The state of this block, ie the item count.
   */
  saveExtraState: function (this: ProcessBlock): ProcessBlockState {
    return {
      depCount: this.depCount_,
      all: this.all_,
    };
  },
  /**
   * Applies the given state to this block.
   *
   * @param state The state to apply to this block, ie the item count.
   */
  loadExtraState: function (this: ProcessBlock, state: ProcessBlockState) {
    this.depCount_ = state.depCount;
    this.all_ = state.all;
    this.updateShape_();
  },

  /**
   * Populate the mutator's dialog with this block's components.
   *
   * @param workspace Mutator's workspace.
   * @returns Root block in mutator.
   */
  decompose: function (
    this: ProcessBlock,
    workspace: Blockly.Workspace
  ): ContainerBlock {
    const containerBlock = workspace.newBlock(
      'process_internal_container'
    ) as ContainerBlock;
    (containerBlock as Blockly.BlockSvg).initSvg();

    let connection = containerBlock.getInput('body')!.connection;
    for (let i = 0; i < this.depCount_; i++) {
      const itemBlock = workspace.newBlock(
        'process_internal_item'
      ) as ItemBlock;
      (itemBlock as Blockly.BlockSvg).initSvg();
      if (!itemBlock.previousConnection) {
        throw new Error('itemBlock has no previousConnection');
      }
      connection!.connect(itemBlock.previousConnection);
      connection = itemBlock.nextConnection;
    }

    if (this.all_) {
      const itemBlock = workspace.newBlock('process_internal_all');
      itemBlock.initModel();
      connection!.connect(itemBlock.previousConnection!);
    }

    return containerBlock;
  },

  /**
   * Reconfigure this block based on the mutator dialog's components.
   *
   * @param containerBlock Root block in mutator.
   */
  compose: function (this: ProcessBlock, containerBlock: Blockly.Block) {
    let itemBlock: ItemBlock | null = containerBlock.getInputTargetBlock(
      'body'
    ) as ItemBlock;

    const fields: string[] = [];
    let all = false;
    while (itemBlock) {
      if (itemBlock.isInsertionMarker()) {
        itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
        continue;
      }
      if (itemBlock.type === 'process_internal_item') {
        fields.push(itemBlock.value_!);
      } else if (itemBlock.type === 'process_internal_all') {
        all = true;
      }
      itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
    }

    this.depCount_ = fields.length;
    this.all_ = all;
    this.updateShape_();

    for (let i = 0; i < this.depCount_; i++) {
      this.getField((i + 1).toString())?.setValue(fields[i]);
    }
  },

  /**
   * Store pointers to any connected child blocks.
   *
   * @param containerBlock Root block in mutator.
   */
  saveConnections: function (
    this: ProcessBlock,
    containerBlock: Blockly.Block
  ) {
    let itemBlock: ItemBlock | null = containerBlock.getInputTargetBlock(
      'body'
    ) as ItemBlock;
    let i = 0;
    while (itemBlock) {
      if (itemBlock.isInsertionMarker()) {
        itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
        continue;
      }
      const input = this.getField((i + 1).toString()) as FieldVar;
      itemBlock.value_ = input?.getValue() ?? undefined;
      itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
      i++;
    }
  },
};

Blockly.Extensions.registerMutator(
  'process_mutator',
  PROCESS,
  function (this: ProcessBlock) {
    this.prevDepCount_ = 1;
    this.depCount_ = 1;
    this.all_ = false;
    this.updateShape_();
  },
  ['process_internal_item', 'process_internal_all']
);

/** Type for a 'lists_create_with_container' block. */
type ContainerBlock = Blockly.Block & typeof PROCESS_CONTAINER;
interface ContainerMutator extends ContainerMutatorType {}
type ContainerMutatorType = typeof PROCESS_CONTAINER;

const PROCESS_CONTAINER = {
  /**
   * Mutator block for list container.
   */
  init: function (this: ContainerBlock) {
    this.appendDummyInput().appendField('process');
    this.appendStatementInput('body');
    this.setColour(190);
    this.contextMenu = false;
  },
};

/** Type for a 'lists_create_with_item' block. */
type ItemBlock = Blockly.Block & ItemMutator;
interface ItemMutator extends ItemMutatorType {
  value_?: string;
}
type ItemMutatorType = typeof PROCESS_ITEM;

const PROCESS_ITEM = {
  /**
   * Mutator block for adding items.
   */
  init: function (this: ItemBlock) {
    this.appendDummyInput().appendField('dependency');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(190);
    this.contextMenu = false;
  },
};

/** Type for a 'lists_create_with_item' block. */
type AllBlock = Blockly.Block & AllMutator;
interface AllMutator extends AllMutatorType {
  value_?: Blockly.Connection;
}
type AllMutatorType = typeof PROCESS_ALL;

const PROCESS_ALL = {
  /**
   * Mutator block for adding items.
   */
  init: function (this: ItemBlock) {
    this.appendDummyInput().appendField('all');
    this.setPreviousStatement(true);
    this.setNextStatement(false);
    this.setColour(190);
    this.contextMenu = false;
  },
};

Blockly.Blocks['process_internal_container'] = PROCESS_CONTAINER;
Blockly.Blocks['process_internal_item'] = PROCESS_ITEM;
Blockly.Blocks['process_internal_all'] = PROCESS_ALL;
