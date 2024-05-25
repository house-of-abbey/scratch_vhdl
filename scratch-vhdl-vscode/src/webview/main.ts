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
import TableEditor, { Canceled } from './TableEditor';

import {
  provideVSCodeDesignSystem,
  vsCodeButton,
} from '@vscode/webview-ui-toolkit';

provideVSCodeDesignSystem().register(vsCodeButton());

async function updateEntity(data: { entity: Entity; filename: string }) {
  const oldEntity = entity;
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

  if (oldEntity) {
    const es = Object.keys(entity.entity);
    const oes = Object.keys(oldEntity.entity);
    for (const e in es) {
      const v = ws.getVariable(es[e]);
      if (!v) {
        if (oes[e]) {
          const ov = ws.getVariable(oes[e]);
          if (ov) {
            ws.renameVariableById(ov.getId(), es[e]);
          } else {
            ws.createVariable(es[e], null, null);
          }
        } else {
          ws.createVariable(es[e], null, null);
        }
      }
    }
    const as = Object.keys(entity.aliases);
    const oas = Object.keys(oldEntity.aliases);
    for (const a in as) {
      const v = ws.getVariable(as[a]);
      if (!v) {
        if (oas[a]) {
          const ov = ws.getVariable(oas[a]);
          if (ov) {
            ws.renameVariableById(ov.getId(), as[a]);
          } else {
            ws.createVariable(as[a], null, null);
          }
        } else {
          ws.createVariable(as[a], null, null);
        }
      }
    }
    const ss = Object.keys(entity.signals);
    const oss = Object.keys(oldEntity.signals);
    for (const s in ss) {
      const v = ws.getVariable(ss[s]);
      if (!v) {
        if (oss[s]) {
          const ov = ws.getVariable(oss[s]);
          if (ov) {
            ws.renameVariableById(ov.getId(), ss[s]);
          } else {
            ws.createVariable(ss[s], null, null);
          }
        } else {
          ws.createVariable(ss[s], null, null);
        }
      }
    }
  } else {
    const es = Object.keys(entity.entity);
    for (const e in es) {
      console.log(es[e]);
      const v = ws.getVariable(es[e]);
      console.log(v, !v);
      if (!v) {
        console.log(ws.createVariable(es[e], null, null));
      }
    }
    const as = Object.keys(entity.aliases);
    for (const a in as) {
      const v = ws.getVariable(as[a]);
      if (!v) {
        ws.createVariable(as[a], null, null);
      }
    }
    const ss = Object.keys(entity.signals);
    for (const s in ss) {
      const v = ws.getVariable(ss[s]);
      if (!v) {
        ws.createVariable(ss[s], null, null);
      }
    }
  }
  for (const v of ws.getAllVariables()) {
    if (
      !(
        v.name in entity.entity ||
        v.name in entity.aliases ||
        v.name in entity.signals
      )
    ) {
      ws.deleteVariableById(v.getId());
    }
  }

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
    try {
      entity.entity = await TableEditor(
        ['Name', 'Direction', 'Type'],
        entity.entity
      );
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    } catch (e) {
      if (!(e instanceof Canceled)) throw e;
    }
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
    try {
      entity.signals = await TableEditor(
        ['Name', 'Type', 'Initial'],
        entity.signals
      );
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    } catch (e) {
      if (!(e instanceof Canceled)) throw e;
    }
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
    try {
      entity.aliases = await TableEditor(
        ['Name', 'Value'],
        entity.aliases
      );
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    } catch (e) {
      if (!(e instanceof Canceled)) throw e;
    }
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
    try {
      entity.constants = await TableEditor(
        ['Name', 'Type', 'Value'],
        entity.constants
      );
      editEntity(entity);
      editContent(ws, filename, entity);
      updateEntity({ entity, filename });
    } catch (e) {
      if (!(e instanceof Canceled)) throw e;
    }
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
    const o = super.dropdownCreate();
    if (o.length > 2) return o.slice(0, -2);
    else return o;
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

setTimeout(() => updateEntity({ entity, filename }), 1000);
