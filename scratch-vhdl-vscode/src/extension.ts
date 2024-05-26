import * as vscode from 'vscode';
import { ScratchVHDLEditorProvider } from './editors/ScratchVHDLEditor';
import path = require('path');
// import { AssemblePanelProvider } from './panels/AssemblePanelProvider';

export function activate(context: vscode.ExtensionContext) {
  // add custom file nesting rules
  const configuration = vscode.workspace.getConfiguration();
  configuration.update(
    'explorer.fileNesting.patterns',
    {
      '*.vhdl':
        '${capture}.vhdl.sbd, ${capture}.vhdl.sbe, ${capture}.vhdl.sbi',
      ...configuration.get('explorer.fileNesting.patterns', {}),
    },
    true
  );
  // Register our custom editor providers
  context.subscriptions.push(ScratchVHDLEditorProvider.register(context));
  // context.subscriptions.push(AssemblePanelProvider.register(context));

  context.subscriptions.push(
    vscode.commands.registerTextEditorCommand(
      'scratch-vhdl-vscode.asm_compile',
      async (editor) => {
        const configuration = vscode.workspace.getConfiguration();
        vscode.tasks.executeTask(
          new vscode.Task(
            { type: 'build' },
            vscode.TaskScope.Workspace,
            'Assemble',
            'ScratchVHDL',
            new vscode.ShellExecution(
              `echo "y" | ${path.join(
                vscode.workspace.workspaceFile?.fsPath ?? '',
                '..',
                configuration
                  .get<string>('scratch-vhdl-vscode.asm_compile_path')
                  ?.replace(/\//g, '\\') ?? ''
              )} ${editor.document.uri.fsPath}`
            )
          )
        );
      }
    )
  );
}
