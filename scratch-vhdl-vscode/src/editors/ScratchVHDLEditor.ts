import path = require('path');
import { TextDecoder, TextEncoder } from 'util';
import * as vscode from 'vscode';
import {
  WebviewToBackMessageResponse,
  WebviewToBackMessage,
} from '../types';
import { getNonce } from '../utilities/getNonce';
import { getUri } from '../utilities/getUri';

export class ScratchVHDLEditorProvider
  implements vscode.CustomTextEditorProvider
{
  public static register(
    context: vscode.ExtensionContext
  ): vscode.Disposable {
    vscode.commands.registerCommand(
      'scratch-vhdl-vscode.scratchVHDL.newFrom',
      () => {
        const config = vscode.workspace.getConfiguration();
        const templates =
          config.get<{ [key: string]: object }>(
            'scratch-vhdl-vscode.templates'
          ) || {};

        vscode.window
          .showQuickPick(Object.keys(templates), {
            canPickMany: false,
          })
          .then(async (value) => {
            if (!value) return;
            const workspaceFolders = vscode.workspace.workspaceFolders;
            if (!workspaceFolders) {
              vscode.window.showErrorMessage(
                'Creating new Scratch VHDL files currently requires opening a workspace'
              );
              return;
            }

            const uri = await vscode.window.showSaveDialog({
              filters: { VHDL: ['vhdl'] },
              saveLabel: 'Create',
              title: 'Where',
            });

            if (!uri) return;

            await vscode.workspace.fs.writeFile(
              uri,
              new TextEncoder().encode('')
            );
            await vscode.workspace.fs.writeFile(
              vscode.Uri.parse(uri.toString() + '.sbd'),
              new TextEncoder().encode('{}')
            );
            await vscode.workspace.fs.writeFile(
              vscode.Uri.parse(uri.toString() + '.sbe'),
              new TextEncoder().encode(JSON.stringify(templates[value]))
            );

            vscode.commands.executeCommand(
              'vscode.openWith',
              uri,
              ScratchVHDLEditorProvider.viewType
            );
          });
      }
    );

    return vscode.window.registerCustomEditorProvider(
      ScratchVHDLEditorProvider.viewType,
      new ScratchVHDLEditorProvider(context),
      {
        // For this demo extension, we enable `retainContextWhenHidden` which keeps the
        // webview alive even when it is not visible. You should avoid using this setting
        // unless is absolutely required as it does have memory overhead.
        webviewOptions: {
          retainContextWhenHidden: true,
        },
        supportsMultipleEditorsPerDocument: false,
      }
    );
  }

  private static readonly viewType = 'scratch-vhdl-vscode.scratchVHDL';

  constructor(private readonly context: vscode.ExtensionContext) {}

  /**
   * Called when our custom editor is opened.
   *
   *
   */
  public async resolveCustomTextEditor(
    document: vscode.TextDocument,
    webviewPanel: vscode.WebviewPanel,
    _token: vscode.CancellationToken
  ): Promise<void> {
    // Setup initial content for the webview
    webviewPanel.webview.options = {
      enableScripts: true,
    };
    webviewPanel.webview.html = this.getHtmlForWebview(
      webviewPanel.webview
    );

    async function readFile(uri: vscode.Uri): Promise<string> {
      if (uri.scheme === 'untitled') {
        return '';
      }
      return new TextDecoder().decode(
        await vscode.workspace.fs.readFile(uri)
      );
    }

    function readLocalFile(p: string) {
      return readFile(
        vscode.Uri.parse(
          'file:///' + path.resolve(path.dirname(document.uri.fsPath), p),
          true
        )
      );
    }

    try {
      await vscode.workspace.fs.stat(
        vscode.Uri.parse(document.uri.toString() + '.sbd', true)
      );
      await vscode.workspace.fs.stat(
        vscode.Uri.parse(document.uri.toString() + '.sbe', true)
      );
    } catch {
      vscode.commands.executeCommand('workbench.action.closeActiveEditor');
      vscode.commands.executeCommand(
        'vscode.openWith',
        document.uri,
        'default'
      );
      return;
    }

    let scratchDocument = await vscode.workspace.openTextDocument(
      vscode.Uri.parse(document.uri.toString() + '.sbd', true)
    );
    let entityDocument = await vscode.workspace.openTextDocument(
      vscode.Uri.parse(document.uri.toString() + '.sbe', true)
    );

    // Hook up event handlers so that we can synchronize the webview with the text document.
    //
    // The text document acts as our model, so we have to sync change in the document to our
    // editor and sync changes in the editor back to the document.
    //
    // Remember that a single text document can also be shared between multiple custom
    // editors (this happens for example when you split a custom editor)

    let acceptChanges = true;
    // const changeDocumentSubscription =
    //   vscode.workspace.onDidChangeTextDocument((e) => {
    //     if (
    //       acceptChanges &&
    //       [
    //         scratchDocument.uri.toString(),
    //         entityDocument.uri.toString(),
    //       ].includes(e.document.uri.toString())
    //     ) {
    //       webviewPanel.webview.postMessage({
    //         type: 'entity',
    //         body: entityDocument.getText(),
    //         file_name: path.basename(document.uri.fsPath).split('.')[0],
    //       });
    //     }
    //   });

    const saveDocumentSubscription =
      vscode.workspace.onDidSaveTextDocument(async (e) => {
        if (document.uri.toString() === e.uri.toString()) {
          if (scratchDocument.isClosed) {
            scratchDocument = await vscode.workspace.openTextDocument(
              vscode.Uri.parse(document.uri.toString() + '.sbd', true)
            );
          }
          scratchDocument.save();
          if (entityDocument.isClosed) {
            entityDocument = await vscode.workspace.openTextDocument(
              vscode.Uri.parse(document.uri.toString() + '.sbe', true)
            );
          }
          entityDocument.save();
        }
      });

    // Make sure we get rid of the listener when our editor is closed.
    webviewPanel.onDidDispose(() => {
      // changeDocumentSubscription.dispose();
      saveDocumentSubscription.dispose();
    });

    // let _requestId = 1;
    // const callbacks = new Map<number, (response: any) => void>();
    // function postMessageWithResponse<R = unknown>(
    //     panel: vscode.WebviewPanel,
    //     type: string,
    //     body: any
    // ): Promise<R> {
    //     const requestId = _requestId++;
    //     const p = new Promise<R>((resolve) =>
    //         callbacks.set(requestId, resolve)
    //     );
    //     panel.webview.postMessage({ type, requestId, body });
    //     return p;
    // }

    // Receive message from the webview.
    webviewPanel.webview.onDidReceiveMessage(
      (message: WebviewToBackMessage) => {
        switch (message.type) {
          // case 'response': {
          //     const callback = callbacks.get(message.requestId);
          //     callback?.(message.body);
          //     return;
          // }

          case 'editContent':
            acceptChanges = false;
            Promise.all([
              this.updateTextDocument(scratchDocument, message.sbd),
              this.updateTextDocument(document, message.code),
            ]).then(() => (acceptChanges = true));
            return;

          case 'editEntity':
            this.updateTextDocument(entityDocument, message.sbe);
            return;

          case 'getContent':
            webviewPanel.webview.postMessage({
              type: 'getContent',
              id: message.id,
              value: scratchDocument.getText(),
            } satisfies WebviewToBackMessageResponse);
            return;

          case 'getEntity':
            webviewPanel.webview.postMessage({
              type: 'getEntity',
              value: {
                sbe: entityDocument.getText(),
                filename: path.basename(document.uri.fsPath).split('.')[0],
              },
              id: message.id,
            } satisfies WebviewToBackMessageResponse);
            return;

          case 'code':
            vscode.commands.executeCommand(
              'vscode.openWith',
              document.uri,
              'default'
            );
            return;

          case 'cmd': {
            document.save();
            vscode.tasks.executeTask(
              new vscode.Task(
                { type: 'build' },
                vscode.TaskScope.Workspace,
                'Build',
                'ScratchVHDL',
                new vscode.ShellExecution(message.cmd, {
                  cwd: path.dirname(entityDocument.uri.fsPath),
                })
              )
            );
            // const terminal = vscode.window.createTerminal('Build');
            // terminal.show();
            // terminal.sendText(
            //   'cd ' + path.dirname(entityDocument.uri.fsPath)
            // );
            // terminal.sendText(message.cmd);
            return;
          }

          case 'getFile':
            readLocalFile(message.path).then((value) =>
              webviewPanel.webview.postMessage({
                type: 'getFile',
                id: message.id,
                value,
              } satisfies WebviewToBackMessageResponse)
            );
            return;

          case 'alert':
            vscode.window.showInformationMessage(message.message);
            return;

          case 'prompt':
            vscode.window
              .showInputBox({
                prompt: message.message,
                value: message.default,
              })
              .then((value) =>
                webviewPanel.webview.postMessage({
                  type: 'prompt',
                  id: message.id,
                  value: value ?? '',
                } satisfies WebviewToBackMessageResponse)
              );
            return;

          case 'confirm':
            vscode.window
              .showInformationMessage(message.message, 'Ok', 'Cancel')
              .then((value) =>
                webviewPanel.webview.postMessage({
                  type: 'confirm',
                  id: message.id,
                  value: value == 'Ok',
                } satisfies WebviewToBackMessageResponse)
              );
            return;

          case 'select':
            vscode.window
              .showQuickPick(message.options, {
                canPickMany: false,
              })
              .then((value) =>
                webviewPanel.webview.postMessage({
                  type: 'select',
                  id: message.id,
                  value: value ?? '',
                } satisfies WebviewToBackMessageResponse)
              );
            return;

          case 'selectFile': {
            vscode.window
              .showOpenDialog({
                canSelectMany: false,
                openLabel: 'Select',
                canSelectFiles: true,
                canSelectFolders: false,
              })
              .then((fileUri) => {
                if (fileUri)
                  webviewPanel.webview.postMessage({
                    type: 'selectFile',
                    id: message.id,
                    value: path.relative(
                      path.dirname(document.uri.fsPath),
                      fileUri[0].fsPath
                    ),
                  } satisfies WebviewToBackMessageResponse);
                else
                  webviewPanel.webview.postMessage({
                    type: 'selectFile',
                    id: message.id,
                  } satisfies WebviewToBackMessageResponse);
              });
            return;
          }
        }
      }
    );
  }

  /**
   * Get the static html used for the editor webviews.
   */
  private getHtmlForWebview(webview: vscode.Webview): string {
    const webviewUri = getUri(webview, this.context.extensionUri, [
      'out',
      'webview.js',
    ]);
    const nonce = getNonce();

    return /* html */ `
			<!DOCTYPE html>
			<html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">

          <style>
            html,
            body {
              margin: 0;
            }
            #root {
              display: flex;
              flex-direction: column;
              height: 100vh;
              background: #ECEFF1;
              margin: 0;
              line-height: 1.5;
            }

            .vscode-theme .blocklyContextMenu {
              background-color: var(--vscode-menu-background);
            }
            .vscode-theme .blocklyContextMenu .blocklyMenuItem.blocklyMenuItemDisabled > .blocklyMenuItemContent {
              color: var(--vscode-disabledForeground);
            }
            .vscode-theme .blocklyContextMenu .blocklyMenuItem:not(.blocklyMenuItemDisabled) > .blocklyMenuItemContent {
              color: var(--vscode-menu-foreground);
            }

            :modal {
              background-color: var(--vscode-editor-background);
            }
            ::backdrop {
              background-color: #0004;
              backdrop-filter: blur(1px);
            }
          </style>
        </head>
        <body>
          <div id="root"></div>
          <script type="module" nonce="${nonce}" src="${webviewUri}"></script>
        </body>
			</html>`;
  }

  /**
   * Write out the text to a given document.
   */
  private updateTextDocument(document: vscode.TextDocument, text: string) {
    const edit = new vscode.WorkspaceEdit();

    // Just replace the entire document every time for this example extension.
    // A more complete extension should compute minimal edits instead.
    edit.replace(
      document.uri,
      new vscode.Range(0, 0, document.lineCount, 0),
      text
    );

    return vscode.workspace.applyEdit(edit);
  }
}
