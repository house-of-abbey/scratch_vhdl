import path = require('path');
import { TextDecoder, TextEncoder } from 'util';
import * as vscode from 'vscode';
import { Disposable, disposeAll } from './dispose';

interface ScratchVHDLDocumentDelegate {
    getFileData(): Promise<string>;
    getScratchData(): Promise<string>;
}

/**
 * Define the document (the data model) used for vhdl files.
 */
class ScratchVHDLDocument extends Disposable implements vscode.CustomDocument {
    static async create(
        uri: vscode.Uri,
        backupId: string | undefined,
        delegate: ScratchVHDLDocumentDelegate
    ): Promise<ScratchVHDLDocument | PromiseLike<ScratchVHDLDocument>> {
        // If we have a backup, read that. Otherwise read the resource from the workspace
        return new ScratchVHDLDocument(
            uri,
            await ScratchVHDLDocument.readFile(uri),
            (await ScratchVHDLDocument.readFile(
                vscode.Uri.parse(uri.toString() + '.sbd', true)
            )) || '{}',
            (await ScratchVHDLDocument.readFile(
                vscode.Uri.parse(uri.toString() + '.sbe', true)
            )) || '{"entity":{}}',
            delegate
        );
    }

    private static async readFile(uri: vscode.Uri): Promise<string> {
        if (uri.scheme === 'untitled') {
            return '';
        }
        return new TextDecoder().decode(
            await vscode.workspace.fs.readFile(uri)
        );
    }

    readLocalFile(p: string): Promise<string> {
        return ScratchVHDLDocument.readFile(
            vscode.Uri.parse(
                'file:///' + path.resolve(path.dirname(this.uri.fsPath), p),
                true
            )
        );
    }

    private readonly _uri: vscode.Uri;

    private _documentData: string;
    private _scratchData: string;
    private _entityData: string;

    private readonly _delegate: ScratchVHDLDocumentDelegate;

    private constructor(
        uri: vscode.Uri,
        initialContent: string,
        initialData: string,
        initialEntity: string,
        delegate: ScratchVHDLDocumentDelegate
    ) {
        super();
        this._uri = uri;
        this._documentData = initialContent;
        this._scratchData = initialData;
        this._entityData = initialEntity;
        this._delegate = delegate;
    }

    public get uri() {
        return this._uri;
    }

    public get documentData(): string {
        return this._documentData;
    }

    public get scratchData(): string {
        return this._scratchData;
    }

    public set entityData(d: string) {
        this._entityData = d;
    }

    public get entityData(): string {
        return this._entityData;
    }

    private readonly _onDidDispose = this._register(
        new vscode.EventEmitter<void>()
    );
    /**
     * Fired when the document is disposed of.
     */
    public readonly onDidDispose = this._onDidDispose.event;

    private readonly _onDidChangeDocument = this._register(
        new vscode.EventEmitter<{
            scratchData: string;
        }>()
    );
    /**
     * Fired to notify webviews that the document has changed.
     */
    public readonly onDidChangeContent = this._onDidChangeDocument.event;

    private readonly _onDidChange = this._register(
        new vscode.EventEmitter<void>()
    );
    /**
     * Fired to tell VS Code that an edit has occurred in the document.
     *
     * This updates the document's dirty indicator.
     */
    public readonly onDidChange = this._onDidChange.event;

    /**
     * Called by VS Code when there are no more references to the document.
     *
     * This happens when all editors for it have been closed.
     */
    dispose(): void {
        this._onDidDispose.fire();
        super.dispose();
    }

    /**
     * Called when the user edits the document in a webview.
     *
     * This fires an event to notify VS Code that the document has been edited.
     */
    update(scratchData: string) {
        this._scratchData = scratchData;
        this._onDidChangeDocument.fire({
            scratchData,
        });
        this._onDidChange.fire();
    }

    /**
     * Called by VS Code when the user saves the document.
     */
    async save(cancellation: vscode.CancellationToken): Promise<void> {
        await this.saveAs(this.uri, cancellation);
    }

    /**
     * Called by VS Code when the user saves the document to a new location.
     */
    async saveAs(
        targetResource: vscode.Uri,
        cancellation: vscode.CancellationToken
    ): Promise<void> {
        this._documentData = await this._delegate.getFileData();
        this._scratchData = await this._delegate.getScratchData();
        if (cancellation.isCancellationRequested) {
            return;
        }
        await vscode.workspace.fs.writeFile(
            targetResource,
            new TextEncoder().encode(this._documentData)
        );
        await vscode.workspace.fs.writeFile(
            vscode.Uri.parse(targetResource.toString() + '.sbd'),
            new TextEncoder().encode(this._scratchData)
        );
        await vscode.workspace.fs.writeFile(
            vscode.Uri.parse(targetResource.toString() + '.sbe'),
            new TextEncoder().encode(this._entityData)
        );
    }

    /**
     * Called by VS Code when the user calls `revert` on a document.
     */
    async revert(_cancellation: vscode.CancellationToken): Promise<void> {
        this._documentData = await ScratchVHDLDocument.readFile(this.uri);
        this._scratchData = await ScratchVHDLDocument.readFile(
            vscode.Uri.parse(this.uri.toString() + '.sbd')
        );
        this._entityData = await ScratchVHDLDocument.readFile(
            vscode.Uri.parse(this.uri.toString() + '.sbe')
        );
        this._onDidChangeDocument.fire({
            scratchData: this._scratchData,
        });
    }

    /**
     * Called by VS Code to backup the edited document.
     *
     * These backups are used to implement hot exit.
     */
    async backup(
        destination: vscode.Uri,
        cancellation: vscode.CancellationToken
    ): Promise<vscode.CustomDocumentBackup> {
        await this.saveAs(destination, cancellation);

        return {
            id: destination.toString(),
            delete: async () => {
                try {
                    await vscode.workspace.fs.delete(destination);
                } catch {
                    // noop
                }
            },
        };
    }
}

/**
 * Provider for vhdl editors.
 *
 * VHDL editors are used for `.vhdl` files, which are just `.png` files with a different file extension.
 *
 * This provider demonstrates:
 *
 * - How to implement a custom editor for binary files.
 * - Setting up the initial webview for a custom editor.
 * - Loading scripts and styles in a custom editor.
 * - Communication between VS Code and the custom editor.
 * - Using CustomDocuments to store information that is shared between multiple custom editors.
 * - Implementing save, undo, redo, and revert.
 * - Backing up a custom editor.
 */
export class ScratchVHDLEditorProvider
    implements vscode.CustomEditorProvider<ScratchVHDLDocument>
{
    private static newScratchVHDLFileId = 1;

    public static register(
        context: vscode.ExtensionContext
    ): vscode.Disposable {
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

    /**
     * Tracks all known webviews
     */
    private readonly webviews = new WebviewCollection();

    constructor(private readonly _context: vscode.ExtensionContext) {}

    //#region CustomEditorProvider

    async openCustomDocument(
        uri: vscode.Uri,
        openContext: { backupId?: string },
        _token: vscode.CancellationToken
    ): Promise<ScratchVHDLDocument> {
        const document: ScratchVHDLDocument = await ScratchVHDLDocument.create(
            uri,
            openContext.backupId,
            {
                getFileData: async () => {
                    const webviewsForDocument = Array.from(
                        this.webviews.get(document.uri)
                    );
                    if (!webviewsForDocument.length) {
                        throw new Error('Could not find webview to save for');
                    }
                    const panel = webviewsForDocument[0];
                    const response = await this.postMessageWithResponse<string>(
                        panel,
                        'getFileData',
                        {}
                    );
                    return response;
                },
                getScratchData: async () => {
                    const webviewsForDocument = Array.from(
                        this.webviews.get(document.uri)
                    );
                    if (!webviewsForDocument.length) {
                        throw new Error('Could not find webview to save for');
                    }
                    const panel = webviewsForDocument[0];
                    const response = await this.postMessageWithResponse<string>(
                        panel,
                        'getScratchData',
                        {}
                    );
                    return response;
                },
            }
        );

        const listeners: vscode.Disposable[] = [];

        listeners.push(
            document.onDidChange((e) => {
                // Tell VS Code that the document has been edited by the use.
                this._onDidChangeCustomDocument.fire({
                    document,
                    undo: () => undefined,
                    redo: () => undefined,
                });
            })
        );

        listeners.push(
            document.onDidChangeContent((e) => {
                // Update all webviews when the document changes
                // for (const webviewPanel of this.webviews.get(document.uri)) {
                //     this.postMessage(
                //         webviewPanel,
                //         'contentUpdate',
                //         e.scratchData
                //     );
                // }
            })
        );

        document.onDidDispose(() => disposeAll(listeners));

        return document;
    }

    async resolveCustomEditor(
        document: ScratchVHDLDocument,
        webviewPanel: vscode.WebviewPanel,
        _token: vscode.CancellationToken
    ): Promise<void> {
        // Add the webview to our internal set of active webviews
        this.webviews.add(document.uri, webviewPanel);

        // Setup initial content for the webview
        webviewPanel.webview.options = {
            enableScripts: true,
        };
        webviewPanel.webview.html = this.getHtmlForWebview(
            webviewPanel.webview
        );

        webviewPanel.webview.onDidReceiveMessage((e) =>
            this.onMessage(document, webviewPanel, e)
        );
    }

    private readonly _onDidChangeCustomDocument = new vscode.EventEmitter<
        vscode.CustomDocumentEditEvent<ScratchVHDLDocument>
    >();
    public readonly onDidChangeCustomDocument =
        this._onDidChangeCustomDocument.event;

    public saveCustomDocument(
        document: ScratchVHDLDocument,
        cancellation: vscode.CancellationToken
    ): Thenable<void> {
        return document.save(cancellation);
    }

    public saveCustomDocumentAs(
        document: ScratchVHDLDocument,
        destination: vscode.Uri,
        cancellation: vscode.CancellationToken
    ): Thenable<void> {
        return document.saveAs(destination, cancellation);
    }

    public revertCustomDocument(
        document: ScratchVHDLDocument,
        cancellation: vscode.CancellationToken
    ): Thenable<void> {
        return document.revert(cancellation);
    }

    public backupCustomDocument(
        document: ScratchVHDLDocument,
        context: vscode.CustomDocumentBackupContext,
        cancellation: vscode.CancellationToken
    ): Thenable<vscode.CustomDocumentBackup> {
        return document.backup(context.destination, cancellation);
    }

    //#endregion

    /**
     * Get the static HTML used for in our editor's webviews.
     */
    private getHtmlForWebview(webview: vscode.Webview): string {
        // Local path to script for the webview
        const scriptUri = webview.asWebviewUri(
            vscode.Uri.joinPath(this._context.extensionUri, 'media', 'main.js')
        );

        const scriptBlocklyUri = webview.asWebviewUri(
            vscode.Uri.joinPath(
                this._context.extensionUri,
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
                    </style>
                </head>
                <body>
                    <div id="root"></div>

                    <script src="${scriptBlocklyUri}"></script>
                    <script src="${scriptUri}"></script>
                </body>
			</html>`;
    }

    private _requestId = 1;
    private readonly _callbacks = new Map<number, (response: any) => void>();

    private postMessageWithResponse<R = unknown>(
        panel: vscode.WebviewPanel,
        type: string,
        body: any
    ): Promise<R> {
        const requestId = this._requestId++;
        const p = new Promise<R>((resolve) =>
            this._callbacks.set(requestId, resolve)
        );
        panel.webview.postMessage({ type, requestId, body });
        return p;
    }

    private postMessage(
        panel: vscode.WebviewPanel,
        type: string,
        body: any
    ): void {
        panel.webview.postMessage({ type, body });
    }

    private onMessage(
        document: ScratchVHDLDocument,
        panel: vscode.WebviewPanel,
        message: any
    ) {
        switch (message.type) {
            case 'response': {
                const callback = this._callbacks.get(message.requestId);
                callback?.(message.body);
                return;
            }

            case 'update':
                document.update(message.body);
                return;

            case 'requestEntity':
                panel.webview.postMessage({
                    type: 'entity',
                    body: document.entityData,
                    file_name: path.basename(document.uri.fsPath).split('.')[0],
                });
                return;

            case 'updateEntity':
                document.entityData = message.body;
                panel.webview.postMessage({
                    type: 'entity',
                    body: document.entityData,
                    file_name: path.basename(document.uri.fsPath).split('.')[0],
                });
                return;

            case 'requestUpdate':
                panel.webview.postMessage({
                    type: 'contentUpdate',
                    body: document.scratchData,
                });
                return;

            case 'code':
                vscode.commands.executeCommand(
                    'vscode.openWith',
                    document.uri,
                    'default'
                );
                return;

            case 'getFile':
                document.readLocalFile(message.path).then((value) =>
                    panel.webview.postMessage({
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
                    .showInputBox({ prompt: message.body })
                    .then((value) =>
                        panel.webview.postMessage({
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
                        panel.webview.postMessage({
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
                        panel.webview.postMessage({
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
                            panel.webview.postMessage({
                                type: 'selectFile',
                                id: message.id,
                                body: path.relative(
                                    path.dirname(document.uri.fsPath),
                                    fileUri[0].fsPath
                                ),
                            });
                        else
                            panel.webview.postMessage({
                                type: 'selectFile',
                                id: message.id,
                                body: undefined,
                            });
                    });
                return;
            }
        }
    }
}

/**
 * Tracks all webviews.
 */
class WebviewCollection {
    private readonly _webviews = new Set<{
        readonly resource: string;
        readonly webviewPanel: vscode.WebviewPanel;
    }>();

    /**
     * Get all known webviews for a given uri.
     */
    public *get(uri: vscode.Uri): Iterable<vscode.WebviewPanel> {
        const key = uri.toString();
        for (const entry of this._webviews) {
            if (entry.resource === key) {
                yield entry.webviewPanel;
            }
        }
    }

    /**
     * Add a new webview to the collection.
     */
    public add(uri: vscode.Uri, webviewPanel: vscode.WebviewPanel) {
        const entry = { resource: uri.toString(), webviewPanel };
        this._webviews.add(entry);

        webviewPanel.onDidDispose(() => {
            this._webviews.delete(entry);
        });
    }
}
