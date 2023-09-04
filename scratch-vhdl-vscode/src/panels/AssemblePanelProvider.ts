/** @deprecated THIS FILE IS NOT CURRENTLY IN USE, instead trialing `vscode.tasks` for ths same purpose. */

/* eslint-disable no-control-regex */
import * as vscode from 'vscode';
import cp = require('child_process');
import path = require('path');

export async function assemble(document: vscode.TextDocument) {
  await document.save();
  const configuration = vscode.workspace.getConfiguration();
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
    / --> ([a-zA-Z]:[\\/](?:[^\\/<>:"|?*\s]+[\\/])*(?:[^\\/<>:"|?*\s]+\.asm)):\x1b\[0m\x1b\[90m(\d+):(\d+)/g,
    (_, file, line, column) =>
      ` --> ${file}:<button class="a" onclick="window.goto('${file.replace(
        /\\/g,
        '\\\\'
      )}',${line - 1},${column - 1})">${line}:${column}</button>`
  );

  output = output.replace(
    / --> ([a-zA-Z]:[\\/](?:[^\\/<>:"|?*\s]+[\\/])*(?:[^\\/<>:"|?*\s]+\.asm)):\x1b\[0m\x1b\[90m(\d+):(\d+)/g,
    (_, file, line, column) =>
      ` --> ${file}:<button class="a" onclick="window.goto('${file.replace(
        /\\/g,
        '\\\\'
      )}',${line - 1},${column - 1})">${line}:${column}</button>`
  );
  output = output.replace(
    /\x1b\[90m/g,
    "</span><span style='color:var(--vscode-disabledForeground);'>"
  );
  output = output.replace(
    /\x1b\[91m/g,
    "</span><span style='color:var(--vscode-errorForeground);'>"
  );
  output = output.replace(
    /\x1b\[93m/g,
    "</span><span style='color:#f80;'>"
  );
  output = output.replace(
    /\x1b\[96m/g,
    "</span><span style='color:#08f;'>"
  );
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
}

export class AssemblePanelProvider {
  static register(context: vscode.ExtensionContext) {
    return vscode.commands.registerTextEditorCommand(
      'scratch-vhdl-vscode.asm_compile',
      async (editor) => {
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
                const b = a[1].split(' ');
                const l = parseInt(b[0]);
                const c = parseInt(b[1]);

                const e = await vscode.window.showTextDocument(
                  await vscode.workspace.openTextDocument(
                    vscode.Uri.file(f)
                  ),
                  {
                    preview: true,
                    viewColumn: editor.viewColumn,
                  }
                );
                e.revealRange(
                  new vscode.Range(
                    new vscode.Position(l, c),
                    new vscode.Position(l, c)
                  )
                );
                e.selection = new vscode.Selection(
                  new vscode.Position(l, c),
                  new vscode.Position(l, c)
                );
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
                                  <div id="output">${await assemble(
                                    editor.document
                                  )}</div>
                                </body>
                            </html>`;
      }
    );
  }
}
