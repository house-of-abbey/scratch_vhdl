export type WebviewToBackMessage =
  | ((
      | { type: 'getContent' }
      | { type: 'getEntity' }
      | { type: 'getFile'; path: string }
      | { type: 'prompt'; message: string; default: string | undefined }
      | { type: 'confirm'; message: string }
      | { type: 'select'; options: string[] }
      | { type: 'selectFile' }
    ) & { id: number })
  | { type: 'alert'; message: string }
  | { type: 'code' }
  | { type: 'cmd'; cmd: string }
  | { type: 'editContent'; sbd: string; code: string }
  | { type: 'editEntity'; sbe: string };
export type WebviewToBackMessageResponse = (
  | { type: 'getContent'; value: string }
  | { type: 'getEntity'; value: { sbe: string; filename: string } }
  | { type: 'getFile'; value: string }
  | { type: 'prompt'; value: string }
  | { type: 'confirm'; value: boolean }
  | { type: 'select'; value: string }
  | { type: 'selectFile'; value?: string }
) & { id: number; value?: unknown };

export interface Entity {
  name?: string;
  entity: Record<string, [string, string]>;
  signals: Record<string, [string, string]>;
  constants: Record<string, [string, string]>;
  aliases: Record<string, string>;
  command?: string;
  libraries: Record<string, Record<string, string | null>>;
}
