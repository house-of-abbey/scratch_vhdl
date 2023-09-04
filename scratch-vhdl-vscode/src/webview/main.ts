import {
  DataGrid,
  DataGridCell,
  provideVSCodeDesignSystem,
  vsCodeDataGrid,
  vsCodeDataGridCell,
  vsCodeDataGridRow,
  vsCodeButton,
  Button,
} from '@vscode/webview-ui-toolkit';
import * as Blockly from 'blockly';
import { Entity } from '../types';
import { toolbox } from './toolbox';
import './ProcessBlock';
import VHDLGenerator from './VHDLGenerator';
import {
  editContent,
  editEntity,
  getFile,
  prompt,
  getEntity,
  getContent,
  runCmd,
  viewCode,
} from './message';

async function updateEntity(data: { entity: Entity; filename: string }) {
  entity = data.entity;
  filename = data.filename;

  // reset toolbox
  const tb = structuredClone(toolbox);

  Blockly.defineBlocksWithJsonArray([
    {
      type: 'constant',
      message0: '%1',
      args0: [
        {
          type: 'field_dropdown',
          name: 'NAME',
          options: Object.keys(entity.constants).map((a) => [a, a]),
        },
      ],
      colour: 250,
      inputsInline: true,
      output: null,
    },
  ]);
  tb.contents = [
    ...tb.contents,
    {
      kind: 'category',
      colour: '250',
      contents: Object.keys(entity.constants).map((a) => ({
        kind: 'block',
        type: 'constant',
        fields: {
          NAME: a,
        },
      })),
      name: 'Constants',
    },
  ];

  const libraryDef = (
    def: {
      block: { type: string } & Record<string, unknown>;
      generator: (block: Blockly.Block) => string;
    }[]
  ) => {
    Blockly.defineBlocksWithJsonArray(def.map((a) => a.block));
    def.forEach(
      (a) => (VHDLGenerator.forBlock[a.block.type] = a.generator)
    );
    return def.map((a) => ({
      kind: 'block',
      type: a.block.type,
    }));
  };

  const categories: Blockly.utils.toolbox.StaticCategoryInfo[] = [];

  for (const a in entity.libraries) {
    const c: Blockly.utils.toolbox.StaticCategoryInfo[] = [];
    const colour = (
      (Array.from(a)
        .slice(0, 10)
        .map((x) => parseInt(x, 36) - 10)
        .reduce((x, y) => x + y, 0) *
        Math.min(a.length, 10)) /
      10
    ).toString();
    for (const lib in entity.libraries[a]) {
      if (entity.libraries[a][lib] === null) continue;
      c.push({
        categorystyle: undefined,
        id: undefined,
        cssconfig: undefined,
        hidden: undefined,
        kind: 'category',
        colour,
        contents: libraryDef(
          Function(
            'colour',
            'generator',
            await getFile(entity.libraries[a][lib]!)
          )(colour, VHDLGenerator).blocks
        ),
        name: lib,
      });
    }
    if (c.length > 0)
      categories.push({
        categorystyle: undefined,
        id: undefined,
        cssconfig: undefined,
        hidden: undefined,
        kind: 'category',
        colour,
        contents: c,
        name: a,
      });
  }

  tb.contents = [
    ...tb.contents,
    {
      kind: 'sep',
    },
    ...categories,
  ];

  ws.updateToolbox(tb);

  ws.getAllBlocks(false).forEach((b) =>
    b.inputList.forEach((c) =>
      c.fieldRow.forEach(
        (d) => d instanceof FieldVar && d.refreshVariableName()
      )
    )
  );
}

async function main() {
  const [_, content] = await Promise.all([
    getEntity().then(updateEntity),
    getContent(),
  ]);

  Blockly.Events.disable();
  Blockly.serialization.workspaces.load(content, ws, {
    recordUndo: false,
  });
  Blockly.Events.enable();
}

provideVSCodeDesignSystem().register(
  vsCodeDataGrid(),
  vsCodeDataGridCell(),
  vsCodeDataGridRow(),
  vsCodeButton()
);

function editable(grid: DataGrid, columns: string[], data: string[][]) {
  // Make a given cell editable
  function setCellEditable(cell: DataGridCell) {
    cell.setAttribute('contenteditable', 'true');
    const selection = window.getSelection();
    if (selection) {
      const range = document.createRange();
      range.selectNodeContents(cell);
      selection.removeAllRanges();
      selection.addRange(range);
    }
  }

  // Make a given cell non-editable
  function unsetCellEditable(cell: DataGridCell) {
    cell.setAttribute('contenteditable', 'false');
    const selection = window.getSelection();
    if (selection) {
      selection.removeAllRanges();
    }
  }

  // Syncs changes made in an editable cell with the
  // underlying data structure of a vscode-data-grid
  function syncCellChanges(cell: DataGridCell) {
    const column = cell.columnDefinition;
    const row = cell.rowData;

    if (column && row) {
      const originalValue = row[column.columnDataKey];
      const newValue = cell.innerText;

      if (originalValue !== newValue) {
        row[column.columnDataKey] = newValue;
      }
    }
  }

  grid.rowsData = data;
  grid.columnDefinitions = columns.map((x, i) => ({
    columnDataKey: i.toString(),
    title: x,
  }));

  grid?.addEventListener('cell-focused', (e: Event) => {
    const cell = e.target as DataGridCell;
    // Do not continue if `cell` is undefined/null or is not a grid cell
    if (!cell || cell.role !== 'gridcell') {
      return;
    }
    // Do not allow data grid header cells to be editable
    if (cell.className === 'column-header') {
      return;
    }

    // Note: Need named closures in order to later use removeEventListener
    // in the handleBlurClosure function
    const handleKeydownClosure = (e: KeyboardEvent) => {
      if (
        !cell.hasAttribute('contenteditable') ||
        cell.getAttribute('contenteditable') === 'false'
      ) {
        if (e.key === 'Enter') {
          e.preventDefault();
          setCellEditable(cell);
        }
      } else {
        if (e.key === 'Enter' || e.key === 'Escape') {
          e.preventDefault();
          syncCellChanges(cell);
          unsetCellEditable(cell);
        }
      }
    };
    const handleClickClosure = () => {
      setCellEditable(cell);
    };
    const handleBlurClosure = () => {
      syncCellChanges(cell);
      unsetCellEditable(cell);
      // Remove the blur, keydown, and click event listener _only after_
      // the cell is no longer focused
      cell.removeEventListener('blur', handleBlurClosure);
      cell.removeEventListener('keydown', handleKeydownClosure);
      cell.removeEventListener('click', handleClickClosure);
    };

    cell.addEventListener('keydown', handleKeydownClosure);
    // Run the click listener once so that if a cell's text is clicked a
    // second time the cursor will move to the given position in the string
    // (versus reselecting the cell text again)
    cell.addEventListener('click', handleClickClosure, { once: true });
    cell.addEventListener('blur', handleBlurClosure);
  });
}

const theme = Blockly.Theme.defineTheme('vscode', {
  name: 'vscode',
  base: Blockly.Themes.Classic,
  componentStyles: {
    workspaceBackgroundColour: 'var(--vscode-editor-background)',
    toolboxBackgroundColour: 'var(--vscode-editorWidget-background)',
    toolboxForegroundColour: 'var(--vscode-editorWidget-foreground)',
    flyoutBackgroundColour: 'var(--vscode-editorWidget-background)',
    flyoutForegroundColour: 'var(--vscode-editorWidget-foreground)',
    flyoutOpacity: 0.8,
    scrollbarColour: '#797979',
    insertionMarkerColour: '#fff',
    insertionMarkerOpacity: 0.3,
    scrollbarOpacity: 0.4,
    cursorColour: '#d0d0d0',
  },
});

const ws = Blockly.inject('root', {
  toolbox: structuredClone(toolbox),
  grid: {
    spacing: 25,
    length: 3,
    colour: '#ccc',
    snap: true,
  },
  zoom: {
    controls: true,
    wheel: true,
    startScale: 1.0,
    maxScale: 3,
    minScale: 0.3,
    scaleSpeed: 1.2,
    pinch: true,
  },
  theme,
  renderer: 'zelos',
});

let entity: Entity;
let filename: string;

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'View Code',
  preconditionFn() {
    return 'enabled';
  },
  callback() {
    viewCode();
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'viewCode',
  weight: -1,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Build',
  preconditionFn() {
    return entity.command ? 'enabled' : 'disabled';
  },
  callback() {
    runCmd(entity.command!);
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'run',
  weight: -0.8,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Change entity name',
  preconditionFn() {
    return 'enabled';
  },
  async callback() {
    const a = await prompt('New name: ', entity.name);
    if (a) {
      entity.name = a;
      editEntity(entity);
      editContent(ws, filename, entity);
    }
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'name',
  weight: -0.7,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Change run command',
  preconditionFn() {
    return 'enabled';
  },
  async callback() {
    const a = await prompt('New command: ', entity.command);
    if (a) {
      entity.command = a;
      editEntity(entity);
    }
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'cmd',
  weight: -0.6,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Edit ports',
  preconditionFn() {
    return 'enabled';
  },
  async callback() {
    const modal = document.createElement('dialog');
    modal.innerHTML = /* html */ `<vscode-data-grid id="grid"></vscode-data-grid>
                                    <div style="display: flex; justify-content: center; margin-top: 1em; gap: 1em">
                                      <vscode-button id="cancel">Cancel</vscode-button>
                                      <vscode-button id="save">Save</vscode-button>
                                    </div>`;
    document.body.appendChild(modal);

    const grid = modal.querySelector('#grid') as DataGrid;
    const save = modal.querySelector('#save') as Button;
    const cancel = modal.querySelector('#cancel') as Button;
    editable(
      grid,
      ['Name', 'Direction', 'Type'],
      Object.entries(entity.entity).map(([x, y]) => [x, ...y])
    );
    modal.addEventListener('close', () => {
      modal.remove();
    });
    save.addEventListener('click', () => {
      entity.entity = Object.fromEntries(
        (grid.rowsData as [string, string, string][]).map<
          [string, [string, string]]
        >(([x, ...y]) => [x, y])
      );
      modal.close();
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    });
    cancel.addEventListener('click', () => modal.close());
    modal.showModal();
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'edit_ports',
  weight: -0.5,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Edit signals',
  preconditionFn() {
    return 'enabled';
  },
  async callback() {
    const modal = document.createElement('dialog');
    modal.innerHTML = /* html */ `<vscode-data-grid id="grid"></vscode-data-grid>
                                    <div style="display: flex; justify-content: center; margin-top: 1em; gap: 1em">
                                      <vscode-button id="cancel">Cancel</vscode-button>
                                      <vscode-button id="save">Save</vscode-button>
                                    </div>`;
    document.body.appendChild(modal);

    const grid = modal.querySelector('#grid') as DataGrid;
    const save = modal.querySelector('#save') as Button;
    const cancel = modal.querySelector('#cancel') as Button;
    editable(
      grid,
      ['Name', 'Type', 'Initial'],
      Object.entries(entity.signals).map(([x, y]) =>
        y instanceof Array ? [x, ...y] : [x, y, '']
      )
    );
    modal.addEventListener('close', () => {
      modal.remove();
    });
    save.addEventListener('click', () => {
      entity.signals = Object.fromEntries(
        (grid.rowsData as [string, string, string][]).map<
          [string, [string, string]]
        >(([x, ...y]) => [x, y])
      );
      modal.close();
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    });
    cancel.addEventListener('click', () => modal.close());
    modal.showModal();
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'edit_signals',
  weight: -0.4,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Edit aliases',
  preconditionFn() {
    return 'enabled';
  },
  async callback() {
    const modal = document.createElement('dialog');
    modal.innerHTML = /* html */ `<vscode-data-grid id="grid"></vscode-data-grid>
                                    <div style="display: flex; justify-content: center; margin-top: 1em; gap: 1em">
                                      <vscode-button id="cancel">Cancel</vscode-button>
                                      <vscode-button id="save">Save</vscode-button>
                                    </div>`;
    document.body.appendChild(modal);

    const grid = modal.querySelector('#grid') as DataGrid;
    const save = modal.querySelector('#save') as Button;
    const cancel = modal.querySelector('#cancel') as Button;
    editable(grid, ['Name', 'Value'], Object.entries(entity.aliases));
    modal.addEventListener('close', () => {
      modal.remove();
    });
    save.addEventListener('click', () => {
      entity.aliases = Object.fromEntries(
        grid.rowsData as [string, string][]
      );
      modal.close();
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    });
    cancel.addEventListener('click', () => modal.close());
    modal.showModal();
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'edit_aliases',
  weight: -0.5,
});

Blockly.ContextMenuRegistry.registry.register({
  displayText: 'Edit constants',
  preconditionFn() {
    return 'enabled';
  },
  async callback() {
    const modal = document.createElement('dialog');
    modal.innerHTML = /* html */ `<vscode-data-grid id="grid"></vscode-data-grid>
                                    <div style="display: flex; justify-content: center; margin-top: 1em; gap: 1em">
                                      <vscode-button id="cancel">Cancel</vscode-button>
                                      <vscode-button id="save">Save</vscode-button>
                                    </div>`;
    document.body.appendChild(modal);

    const grid = modal.querySelector('#grid') as DataGrid;
    const save = modal.querySelector('#save') as Button;
    const cancel = modal.querySelector('#cancel') as Button;
    editable(
      grid,
      ['Name', 'Type', 'Value'],
      Object.entries(entity.constants).map(([x, y]) => [x, ...y])
    );
    modal.addEventListener('close', () => {
      modal.remove();
    });
    save.addEventListener('click', () => {
      entity.constants = Object.fromEntries(
        (grid.rowsData as [string, string, string][]).map<
          [string, [string, string]]
        >(([x, ...y]) => [x, y])
      );
      modal.close();
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    });
    cancel.addEventListener('click', () => modal.close());
    modal.showModal();
  },
  scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
  id: 'edit_constants',
  weight: -0.5,
});

export class FieldVar extends Blockly.FieldVariable {
  constructor(
    varName: string | null | typeof Blockly.Field.SKIP_SETUP,
    validator?: Blockly.FieldVariableValidator,
    variableTypes?: string[],
    defaultType?: string,
    config?: Blockly.FieldVariableConfig
  ) {
    super(varName, validator, variableTypes, defaultType, config);

    /**
     * An array of options for a dropdown list,
     * or a function which generates these options.
     */
    this.menuGenerator_ = FieldVar.dropdownCreate as Blockly.MenuGenerator;
  }

  static dropdownCreate(
    this: Blockly.FieldVariable
  ): Blockly.MenuOption[] {
    return super.dropdownCreate().slice(0, -2);
  }

  protected render_(): void {
    super.render_();
    if (!this.sourceBlock_) return;
    if (
      [
        'variables_get',
        'variables_set',
        'variables_set_index',
        'math_change',
        'process_direct_set',
      ].indexOf(this.sourceBlock_.type) !== -1
    ) {
      const v = this.getText();
      if (Object.keys(entity.entity).indexOf(v) !== -1)
        this.sourceBlock_.setColour(20);
      else if (Object.keys(entity.aliases).indexOf(v) !== -1)
        this.sourceBlock_.setColour(120);
      else this.sourceBlock_.setColour('%{BKY_VARIABLES_HUE}');
    }
  }
}
Blockly.fieldRegistry.register('field_var', FieldVar);

// window.addEventListener('message',
//     (message) => message.data.type == "getFileData" &&
//         vscode.postMessage({
//             type: 'response',
//             requestId: message.data.requestId,
//             body: VHDLGenerator.workspaceToCode(ws)
//         }));
// window.addEventListener('message',
//     (message) => message.data.type == "getScratchData" &&
//         vscode.postMessage({
//             type: 'response',
//             requestId: message.data.requestId,
//             body: JSON.stringify(Blockly.serialization.workspaces.save(ws))
//         }));
// window.addEventListener('message',
//     (message) => message.data.type == "getEntityData" &&
//         vscode.postMessage({
//             type: 'response',
//             requestId: message.data.requestId,
//             body: JSON.stringify(entity)
//         }));

ws.addChangeListener((e) => {
  if (e.isUiEvent) return;

  editContent(ws, filename, entity);
});

main();
