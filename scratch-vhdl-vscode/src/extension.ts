import * as vscode from 'vscode';
import { ScratchVHDLEditorProvider } from './scratchVHDLEditor';

export function activate(context: vscode.ExtensionContext) {
	// Register our custom editor providers
	context.subscriptions.push(ScratchVHDLEditorProvider.register(context));
}
