import * as vscode from 'vscode';
import { ScratchVHDLEditorProvider } from './scratchVHDLEditor';

export function activate(context: vscode.ExtensionContext) {
    // add custom file nesting rules
    const configuration = vscode.workspace.getConfiguration();
    configuration.update(
        'explorer.fileNesting.patterns',
        {
            '*.vhdl': '${capture}.vhdl.sbd, ${capture}.vhdl.sbe, ${capture}.vhdl.sbi',
            ...configuration.get('explorer.fileNesting.patterns', {}),
        },
        true
    );
    // Register our custom editor providers
    context.subscriptions.push(ScratchVHDLEditorProvider.register(context));
}
