import path = require('path');
import { TextDecoder, TextEncoder } from 'util';
import * as vscode from 'vscode';

export class ScratchVHDLEditorProvider
  implements vscode.CustomTextEditorProvider
{
  private static newScratchVHDLFileId = 1;

  public static register(context: vscode.ExtensionContext): vscode.Disposable {
    vscode.commands.registerCommand(
      'scratch-vhdl-vscode.scratchVHDL.new',
      () => {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (!workspaceFolders) {
          vscode.window.showErrorMessage(
            'Creating new Scratch VHDL files currently requires opening a workspace'
          );
          return;
        }

        const uri = vscode.Uri.joinPath(
          workspaceFolders[0].uri,
          `new-${ScratchVHDLEditorProvider.newScratchVHDLFileId++}.vhdl`
        ).with({ scheme: 'untitled' });

        vscode.commands.executeCommand(
          'vscode.openWith',
          uri,
          ScratchVHDLEditorProvider.viewType
        );
      }
    );

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
    webviewPanel.webview.html = this.getHtmlForWebview(webviewPanel.webview);

    async function readFile(uri: vscode.Uri): Promise<string> {
      if (uri.scheme === 'untitled') {
        return '';
      }
      return new TextDecoder().decode(await vscode.workspace.fs.readFile(uri));
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

    const updateWebview = () => {
      webviewPanel.webview.postMessage({
        type: 'entity',
        body: entityDocument.getText(),
        file_name: path.basename(document.uri.fsPath).split('.')[0],
      });
    };

    // Hook up event handlers so that we can synchronize the webview with the text document.
    //
    // The text document acts as our model, so we have to sync change in the document to our
    // editor and sync changes in the editor back to the document.
    //
    // Remember that a single text document can also be shared between multiple custom
    // editors (this happens for example when you split a custom editor)

    let acceptChanges = true;
    const changeDocumentSubscription = vscode.workspace.onDidChangeTextDocument(
      (e) => {
        if (
          acceptChanges &&
          [
            document.uri.toString(),
            scratchDocument.uri.toString(),
            entityDocument.uri.toString(),
          ].includes(e.document.uri.toString())
        ) {
          updateWebview();
        }
      }
    );

    const saveDocumentSubscription = vscode.workspace.onDidSaveTextDocument(
      async (e) => {
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
      }
    );

    // Make sure we get rid of the listener when our editor is closed.
    webviewPanel.onDidDispose(() => {
      changeDocumentSubscription.dispose();
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
    webviewPanel.webview.onDidReceiveMessage((message) => {
      switch (message.type) {
        // case 'response': {
        //     const callback = callbacks.get(message.requestId);
        //     callback?.(message.body);
        //     return;
        // }

        case 'update':
          acceptChanges = false;
          Promise.all([
            this.updateTextDocument(scratchDocument, message.body[0]),
            this.updateTextDocument(document, message.body[1]),
          ]).then(() => (acceptChanges = true));
          return;

        case 'requestEntity':
          webviewPanel.webview.postMessage({
            type: 'entity',
            body: entityDocument.getText(),
            file_name: path.basename(document.uri.fsPath).split('.')[0],
          });
          return;

        case 'updateEntity':
          this.updateTextDocument(entityDocument, message.body);
          webviewPanel.webview.postMessage({
            type: 'entity',
            body: message.body,
            file_name: path.basename(document.uri.fsPath).split('.')[0],
          });
          return;

        case 'requestUpdate':
          webviewPanel.webview.postMessage({
            type: 'contentUpdate',
            body: scratchDocument.getText(),
          });
          return;

        case 'code':
          vscode.commands.executeCommand(
            'vscode.openWith',
            document.uri,
            'default'
          );
          return;

        case 'cmd': {
          const terminal = vscode.window.createTerminal('Build');
          terminal.show();
          terminal.sendText('cd ' + path.dirname(entityDocument.uri.fsPath));
          terminal.sendText(message.cmd);
          return;
        }

        case 'getFile':
          readLocalFile(message.path).then((value) =>
            webviewPanel.webview.postMessage({
              type: 'getFile',
              id: message.id,
              body: value,
            })
          );
          return;

        case 'alert':
          vscode.window.showInformationMessage(message.body);
          return;

        case 'prompt':
          vscode.window
            .showInputBox({
              prompt: message.body,
              value: message.default,
            })
            .then((value) =>
              webviewPanel.webview.postMessage({
                type: 'prompt',
                id: message.id,
                body: value,
              })
            );
          return;

        case 'confirm':
          vscode.window
            .showInformationMessage(message.body, 'Ok', 'Cancel')
            .then((value) =>
              webviewPanel.webview.postMessage({
                type: 'confirm',
                id: message.id,
                body: value == 'Ok',
              })
            );
          return;

        case 'select':
          vscode.window
            .showQuickPick(message.body, {
              canPickMany: false,
            })
            .then((value) =>
              webviewPanel.webview.postMessage({
                type: 'select',
                id: message.id,
                body: value,
              })
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
                  body: path.relative(
                    path.dirname(document.uri.fsPath),
                    fileUri[0].fsPath
                  ),
                });
              else
                webviewPanel.webview.postMessage({
                  type: 'selectFile',
                  id: message.id,
                  body: undefined,
                });
            });
          return;
        }

        case 'setState':
          this.context.globalState.setKeysForSync([message.key]);
          this.context.globalState.update(message.key, message.value).then(() =>
            webviewPanel.webview.postMessage({
              type: 'setState',
              id: message.id,
            })
          );
          return;

        case 'getState':
          webviewPanel.webview.postMessage({
            type: 'getState',
            id: message.id,
            value: this.context.globalState.get<any>(message.key, message.a),
          });
          return;
      }
    });

    updateWebview();
  }

  /**
   * Get the static html used for the editor webviews.
   */
  private getHtmlForWebview(webview: vscode.Webview): string {
    // Local path to script for the webview
    const scriptUri = webview.asWebviewUri(
      vscode.Uri.joinPath(this.context.extensionUri, 'media', 'main.js')
    );

    const scriptBlocklyBackpackUri = webview.asWebviewUri(
      vscode.Uri.joinPath(
        this.context.extensionUri,
        'node_modules',
        '@blockly',
        'workspace-backpack',
        'dist',
        'index.js'
      )
    );

    const scriptBlocklyUri = webview.asWebviewUri(
      vscode.Uri.joinPath(
        this.context.extensionUri,
        'node_modules',
        'blockly',
        'blockly.min.js'
      )
    );

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

                        /* Properties */
                        :root {
                            --container-paddding: 20px;
                            --input-padding-vertical: 6px;
                            --input-padding-horizontal: 4px;
                            --input-margin-vertical: 4px;
                            --input-margin-horizontal: 0;
                        }

                        dialog  {
                            padding: var(--container-paddding) 0;
                            color: var(--vscode-foreground);
                            font-size: var(--vscode-font-size);
                            font-weight: var(--vscode-font-weight);
                            font-family: var(--vscode-font-family);
                            background-color: var(--vscode-editor-background);
                            border-color: var(--vscode-menu-selectionBackground);
                            flex-direction: row;
                            justify-items: center;
                            display: flex;
                            justify-content: space-evenly;
                            flex-wrap: wrap;
                        }

                        dialog ol,
                        dialog ul {
                            padding-left: var(--container-paddding);
                        }

                        dialog > *,
                        dialog form > * {
                            margin-block-start: var(--input-margin-vertical);
                            margin-block-end: var(--input-margin-vertical);
                        }

                        dialog *:focus {
                            outline-color: var(--vscode-focusBorder) !important;
                        }

                        dialog a {
                            color: var(--vscode-textLink-foreground);
                        }

                        dialog a:hover,
                        dialog a:active {
                            color: var(--vscode-textLink-activeForeground);
                        }

                        dialog code {
                            font-size: var(--vscode-editor-font-size);
                            font-family: var(--vscode-editor-font-family);
                        }

                        dialog button {
                            border: none;
                            padding: var(--input-padding-vertical) var(--input-padding-horizontal);
                            width: 100%;
                            max-width: 10em;
                            min-width: 2em;
                            text-align: center;
                            outline: 1px solid transparent;
                            outline-offset: 2px !important;
                            color: var(--vscode-button-foreground);
                            background: var(--vscode-button-background);
                            box-shadow: 3px 3px 10px rgba(0 0 0 / 0.5);
                            border-radius: 2px;
                        }

                        dialog button:hover {
                            cursor: pointer;
                            background: var(--vscode-button-hoverBackground);
                        }

                        dialog button:focus {
                            outline-color: var(--vscode-focusBorder);
                        }

                        dialog button.secondary {
                            color: var(--vscode-button-secondaryForeground);
                            background: var(--vscode-button-secondaryBackground);
                        }

                        dialog button.secondary:hover {
                            background: var(--vscode-button-secondaryHoverBackground);
                        }

                        dialog input:not([type='checkbox']),
                        dialog textarea {
                            display: block;
                            width: 100%;
                            border: none;
                            font-family: var(--vscode-font-family);
                            padding: var(--input-padding-vertical) var(--input-padding-horizontal);
                            color: var(--vscode-input-foreground);
                            outline-color: var(--vscode-input-border);
                            background-color: var(--vscode-input-background);
                        }

                        dialog input::placeholder,
                        dialog textarea::placeholder {
                            color: var(--vscode-input-placeholderForeground);
                        }
                    </style>
                </head>
                <body>
                    <div id="root"></div>

                    <script src="${scriptBlocklyUri}"></script>
                    <script src="${scriptBlocklyBackpackUri}"></script>
                    <script src="${scriptUri}"></script>
                </body>
			</html>`;
  }

  /**
   * Write out the text to a given document.
   */
  private updateTextDocument(document: vscode.TextDocument, text: any) {
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
