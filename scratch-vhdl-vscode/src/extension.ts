/* eslint-disable no-control-regex */
import * as vscode from 'vscode';
import { ScratchVHDLEditorProvider } from './scratchVHDLEditor';
import cp = require('child_process');
import path = require('path');

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

  const assemble = (document: vscode.TextDocument) => {
    document.save();
    let output = cp.execSync(
      `${path.join(
        vscode.workspace.workspaceFile?.fsPath ?? '',
        '..',
        configuration
          .get<string>('scratch-vhdl-vscode.asm_compile_path')
          ?.replace(/\//g, '\\') ?? ''
      )} ${document.uri.fsPath}`,
      {
        encoding: 'utf-8',
      }
    );
    output = output.replace(
      / --> ([a-zA-Z]:[\\\/](?:[^\\\/<>:"|?*\s]+[\\\/])*(?:[^\\\/<>:"|?*\s]+\.asm)):\x1b\[0m\x1b\[90m(\d+):(\d+)/g,
      (_, file, line, column) =>
        ` --> ${file}:<button class="a" onclick="window.goto("${file}",${
          line - 1
        },${column - 1})">${line}:${column}</button>`
    );

    output = output.replace(
      / --> ([a-zA-Z]:[\\\/](?:[^\\\/<>:"|?*\s]+[\\\/])*(?:[^\\\/<>:"|?*\s]+\.asm)):\x1b\[0m\x1b\[90m(\d+):(\d+)/g,
      (_, file, line, column) =>
        ` --> ${file}:<button class="a" onclick="window.goto("${file}",${
          line - 1
        },${column - 1})">${line}:${column}</button>`
    );
    output = output.replace(
      /\x1b\[90m/g,
      "</span><span style='color:var(--vscode-disabledForeground);'>"
    );
    output = output.replace(
      /\x1b\[91m/g,
      "</span><span style='color:var(--vscode-errorForeground);'>"
    );
    output = output.replace(/\x1b\[93m/g, "</span><span style='color:#f80;'>");
    output = output.replace(/\x1b\[96m/g, "</span><span style='color:#08f;'>");
    output = output.replace(
      /\x1b\[97m/g,
      "</span><span style='color:var(--vscode-foreground);'>"
    );
    output = output.replace(
      /\x1b\[1m/g,
      "</span><span style='font-weight:bold;'>"
    );
    output = output.replace(
      /\x1b\[0m/g,
      "</span><span style='color:var(--vscode-foreground);'>"
    );

    output =
      "<span style='color:var(--vscode-foreground);'>" + output + '</span>';

    return output;
  };

  context.subscriptions.push(
    vscode.commands.registerTextEditorCommand(
      'scratch-vhdl-vscode.asm_compile',
      (editor) => {
        const panel = vscode.window.createWebviewPanel(
          'customasm',
          `Customasm`,
          vscode.ViewColumn.Beside,
          {
            enableScripts: true,
          }
        );

        panel.webview.onDidReceiveMessage(
          async (message) => {
            switch (message.command) {
              case 'goto': {
                const a = message.text.split(',');
                const f = a[0];
                const b = message.text.split(' ');
                const l = parseInt(b[0]);
                const c = parseInt(b[1]);

                const doc = await vscode.workspace.openTextDocument(
                  vscode.Uri.parse(f)
                );
                const e = await vscode.window.showTextDocument(doc);

                e.revealRange(
                  new vscode.Range(
                    new vscode.Position(l, c),
                    new vscode.Position(l, c)
                  )
                );
                e.selection = new vscode.Selection(l, 0, l, 999);
                break;
              }
            }
          },
          undefined,
          context.subscriptions
        );

        panel.webview.html = `<!DOCTYPE html>
                            <html lang="en">
                                <head>
                                    <title>customasm</title>
                                    <meta charset="utf-8">
                                    <style>
                                        #output {
                                            width: 100px;
                                            height: 100px;
                                            font-family: Consolas, monospace;
                                            white-space: pre;
                                        }

                                        button.a {
                                            background: none!important;
                                            border: none;
                                            padding: 0!important;
                                            font-family: inherit;
                                            color: var(--vscode-textLink-foreground);
                                            cursor: pointer;
                                        }

                                        button.a:hover {
                                            text-decoration: underline;
                                        }
                                    </style>
                                </head>
                                <body>
                                    <script>
                                        window.vscode = acquireVsCodeApi();
                                        window.goto = (f, l, c) => window.vscode.postMessage({ command: "goto", text: f+","+l+" "+c });
                                    </script>
                                    <div id="output">${assemble(
                                      editor.document
                                    )}</div>
                                </body>
                            </html>`;
      }
    )
  );
}
