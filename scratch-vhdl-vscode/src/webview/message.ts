import type {} from 'vscode-webview';
import * as Blockly from 'blockly';
import {
  Entity,
  WebviewToBackMessage,
  WebviewToBackMessageResponse,
} from '../types';
import { generate } from './VHDLGenerator';

const vscode = acquireVsCodeApi();

let rid = 0;
type RequestCallback = (
  value: WebviewToBackMessageResponse['value']
) => void;
const requests: RequestCallback[] = [];
window.addEventListener(
  'message',
  ({ data }: { data: WebviewToBackMessageResponse }) =>
    data.hasOwnProperty('id') && requests[data.id](data.value)
);

export const alert = (m: string) => {
  vscode.postMessage({
    type: 'alert',
    message: m,
  } satisfies WebviewToBackMessage);
};
export const prompt = (m: string, d?: string): Promise<string> => {
  vscode.postMessage({
    type: 'prompt',
    message: m,
    default: d,
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) => (requests[rid++] = resolve as RequestCallback)
  );
};
export const confirm = (m: string): Promise<boolean> => {
  vscode.postMessage({
    type: 'confirm',
    message: m,
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) => (requests[rid++] = resolve as RequestCallback)
  );
};
export const select = (o: string[]): Promise<string> => {
  vscode.postMessage({
    type: 'select',
    options: o,
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) => (requests[rid++] = resolve as RequestCallback)
  );
};
export const selectFile = (): Promise<string> => {
  vscode.postMessage({
    type: 'selectFile',
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) => (requests[rid++] = resolve as RequestCallback)
  );
};
export const getFile = (m: string): Promise<string> => {
  vscode.postMessage({
    type: 'getFile',
    path: m,
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) => (requests[rid++] = resolve as RequestCallback)
  );
};
export const getEntity = (): Promise<{
  entity: Entity;
  filename: string;
}> => {
  vscode.postMessage({
    type: 'getEntity',
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) =>
      (requests[rid++] = ((
        value: Extract<
          WebviewToBackMessageResponse,
          { type: 'getEntity' }
        >['value']
      ) =>
        resolve({
          entity: JSON.parse(value.sbe),
          filename: value.filename,
        })) as RequestCallback)
  );
};
export const getContent = (): Promise<Record<string, unknown>> => {
  vscode.postMessage({
    type: 'getContent',
    id: rid,
  } satisfies WebviewToBackMessage);
  return new Promise(
    (resolve) =>
      (requests[rid++] = ((value: string) =>
        resolve(JSON.parse(value))) as RequestCallback)
  );
};
export const editContent = (
  ws: Blockly.Workspace,
  filename: string,
  entity: Entity
) => {
  vscode.postMessage({
    type: 'editContent',
    sbd: JSON.stringify(Blockly.serialization.workspaces.save(ws)),
    code: generate(ws, filename, entity),
  } satisfies WebviewToBackMessage);
};
export const editEntity = (entity: Entity) => {
  vscode.postMessage({
    type: 'editEntity',
    sbe: JSON.stringify(entity),
  } satisfies WebviewToBackMessage);
};
export const viewCode = () => {
  vscode.postMessage({
    type: 'code',
  } satisfies WebviewToBackMessage);
};
export const runCmd = (cmd: string) => {
  vscode.postMessage({
    type: 'cmd',
    cmd,
  } satisfies WebviewToBackMessage);
};

Blockly.dialog.setAlert((m, cb) => (alert(m), cb && cb()));
Blockly.dialog.setPrompt((m, a, cb) => prompt(m).then((d) => cb(d ?? a)));
Blockly.dialog.setConfirm((m, cb) =>
  confirm(m).then((d) => cb(d ?? false))
);
