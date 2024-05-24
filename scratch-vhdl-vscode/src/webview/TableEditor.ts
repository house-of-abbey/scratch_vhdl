import { Button } from '@vscode/webview-ui-toolkit';

export class Canceled extends Error {}

export default function TableEditor<
  T extends Record<string, string | string[]>
>(cols: string[], rows: T): Promise<T> {
  return new Promise((resolve, reject) => {
    const modal = document.createElement('dialog');
    document.body.appendChild(modal);
    modal.style.display = 'grid';
    modal.style.gap = '0.25em 1em';
    modal.style.padding = '1em';
    modal.style.gridTemplateAreas = '"t t" "a a" "c s"';
    modal.innerHTML = /* html */ `
<style>
  #table {
    grid-area: t;
  }

  #add {
    grid-area: a;
  }
  #cancel {
    grid-area: c;
  }
  #save {
    grid-area: s;
  }
</style>
<table id="table"></table>
<vscode-button id="add">+</vscode-button>
<vscode-button appearance="secondary" id="cancel">Cancel</vscode-button>
<vscode-button id="save">Save</vscode-button>`;

    const table = modal.querySelector('#table') as HTMLTableElement;

    const thead = document.createElement('thead');
    table.appendChild(thead);
    const thead_tr = document.createElement('tr');
    thead.appendChild(thead_tr);
    for (const col of cols) {
      const th = document.createElement('th');
      th.innerText = col;
      thead_tr.appendChild(th);
    }

    const tbody = document.createElement('tbody');
    table.appendChild(tbody);
    for (const row in rows) {
      const tr = document.createElement('tr');
      tbody.appendChild(tr);
      const tr_td = document.createElement('td');
      const tr_td_input = document.createElement('input');
      tr_td_input.value = row;
      tr_td.appendChild(tr_td_input);
      tr.appendChild(tr_td);
      for (const cell of rows[row]) {
        const td = document.createElement('td');
        const td_input = document.createElement('input');
        td_input.value = cell;
        td.appendChild(td_input);
        tr.appendChild(td);
      }
      const tr_minus = document.createElement('td');
      const tr_minus_button = document.createElement(
        'vscode-button'
      ) as Button;
      tr_minus_button.style.marginLeft = '1em';
      tr_minus_button.innerText = '-';
      tr_minus.appendChild(tr_minus_button);
      tr_minus_button.addEventListener('click', () => {
        tr.remove();
      });
      tr.appendChild(tr_minus);
    }

    const add = modal.querySelector('#add') as Button;
    const save = modal.querySelector('#save') as Button;
    const cancel = modal.querySelector('#cancel') as Button;
    add.addEventListener('click', () => {
      const tr = document.createElement('tr');
      tbody.appendChild(tr);
      const tr_td = document.createElement('td');
      const tr_td_input = document.createElement('input');
      tr_td.appendChild(tr_td_input);
      tr.appendChild(tr_td);
      for (let i = 0; i < cols.length - 1; i++) {
        const td = document.createElement('td');
        const td_input = document.createElement('input');
        td.appendChild(td_input);
        tr.appendChild(td);
      }
      const tr_minus = document.createElement('td');
      const tr_minus_button = document.createElement(
        'vscode-button'
      ) as Button;
      tr_minus_button.style.marginLeft = '1em';
      tr_minus_button.innerText = '-';
      tr_minus.appendChild(tr_minus_button);
      tr_minus_button.addEventListener('click', () => {
        tr.remove();
      });
      tr.appendChild(tr_minus);
    });
    modal.addEventListener('close', () => {
      modal.remove();
    });
    save.addEventListener('click', () => {
      modal.close();
      resolve(
        Object.fromEntries(
          [...tbody.querySelectorAll('tr')]
            .map((r) =>
              [...r.querySelectorAll('input')].map((c) => c.value)
            )
            .map(([n, ...r]) => [n, r])
        ) as T
      );
    });
    cancel.addEventListener(
      'click',
      () => (modal.close(), reject(new Canceled()))
    );
    modal.showModal();
  });
}
