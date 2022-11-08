/**
 * Simple object check.
 * @param item
 * @returns {boolean}
 */
function isObject(item) {
    return (item && typeof item === 'object' && !Array.isArray(item));
}

/**
 * Deep merge two objects.
 * @param target
 * @param ...sources
 */
function mergeDeep(target, ...sources) {
    if (!sources.length) return target;
    const source = sources.shift();

    if (isObject(target) && isObject(source)) {
        for (const key in source) {
            if (isObject(source[key])) {
                if (!target[key]) Object.assign(target, { [key]: {} });
                mergeDeep(target[key], source[key]);
            } else {
                Object.assign(target, { [key]: source[key] });
            }
        }
    }

    return mergeDeep(target, ...sources);
}

document.addEventListener('DOMContentLoaded', function () {
    const vscode = acquireVsCodeApi();

    let rid = 0;
    let requests = [];
    const alert = (m) => vscode.postMessage({
        type: "alert",
        body: m
    });
    window.addEventListener("message", (message) => message.data.type == "prompt" && requests[message.data.id](message.data.body));
    const prompt = (m) => {
        vscode.postMessage({
            type: "prompt",
            body: m,
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };
    window.addEventListener("message", (message) => message.data.type == "confirm" && requests[message.data.id](message.data.body));
    const confirm = (m) => {
        vscode.postMessage({
            type: "confirm",
            body: m,
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };
    window.addEventListener("message", (message) => message.data.type == "select" && requests[message.data.id](message.data.body));
    const select = (o) => {
        vscode.postMessage({
            type: "select",
            body: o,
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };
    window.addEventListener("message", (message) => message.data.type == "selectFile" && requests[message.data.id](message.data.body));
    const selectFile = () => {
        vscode.postMessage({
            type: "selectFile",
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };
    window.addEventListener("message", (message) => message.data.type == "getFile" && requests[message.data.id](message.data.body));
    const getFile = (m) => {
        vscode.postMessage({
            type: "getFile",
            path: m,
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };
    window.addEventListener("message", (message) => message.data.type == "getState" && requests[message.data.id](message.data.value));
    const getState = (key, a) => {
        vscode.postMessage({
            type: "getState",
            key,
            a,
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };
    window.addEventListener("message", (message) => message.data.type == "setState" && requests[message.data.id]());
    const setState = (key, value) => {
        vscode.postMessage({
            type: "setState",
            key,
            value,
            id: rid
        });
        return new Promise((resolve) => requests[rid++] = resolve);
    };

    //#region storage_backpack
    class StorageBackpack extends Backpack {
        open() {
            if (!this.isOpenable_()) {
                return;
            }
            getState("bp_contents", []).then((d) => (this.contents_ = d, super.open()));
        }
        onContentChange_() {
            super.onContentChange_();
            setState("bp_contents", this.contents_)
        }
    }
    //#endregion

    const builtinLibs = {};

    const toolbox = {
        'kind': 'categoryToolbox',
        'contents': [
            {
                'kind': 'category',
                'name': 'Literals',
                "colour": "30",
                'contents': [
                    {
                        'kind': 'block',
                        'type': 'logic_boolean',
                    },
                    {
                        'kind': 'block',
                        'type': 'math_number',
                        'gap': 32,
                        'fields': {
                            'NUM': 123,
                        },
                    },
                    {
                        'kind': 'block',
                        'type': 'value_std_logic',
                    },
                    {
                        'kind': 'block',
                        'type': 'value_std_logic_vector',
                    },
                    {
                        'kind': 'block',
                        'type': 'others_to',
                    },
                ]
            },
            {
                'kind': 'category',
                'name': 'Logic',
                'categorystyle': 'logic_category',
                'contents': [
                    {
                        'kind': 'block',
                        'type': 'controls_if',
                    },
                    {
                        'kind': 'block',
                        'type': 'controls_case',
                    },
                    {
                        'kind': 'block',
                        'type': 'controls_when',
                    },
                    {
                        'kind': "block",
                        'type': 'logic_others'
                    },
                    {
                        'kind': 'block',
                        'type': 'logic_or',
                    },
                    {
                        'kind': 'block',
                        'type': 'logic_compare',
                    },
                    {
                        'kind': 'block',
                        'type': 'logic_operation',
                    },
                    {
                        'kind': 'block',
                        'type': 'logic_operation_vector',
                    },
                    {
                        'kind': 'block',
                        'type': 'logic_not',
                    },
                    {
                        'kind': 'block',
                        'type': 'logic_rising_edge',
                    },
                    {
                        'kind': 'block',
                        'type': 'report',
                    },
                ],
            },
            // {
            //     'kind': 'category',
            //     'name': 'Loops',
            //     'categorystyle': 'loop_category',
            //     'contents': [
            //     ],
            // },
            {
                'kind': 'category',
                'name': 'Operations',
                'categorystyle': 'math_category',
                'contents': [
                    {
                        'kind': 'block',
                        'type': 'math_arithmetic',
                        'inputs': {
                            'A': {
                                'shadow': {
                                    'type': 'math_number',
                                    'fields': {
                                        'NUM': 1,
                                    },
                                },
                            },
                            'B': {
                                'shadow': {
                                    'type': 'math_number',
                                    'fields': {
                                        'NUM': 1,
                                    },
                                },
                            },
                        },
                    },
                    // {
                    //     'kind': 'block',
                    //     'type': 'math_number_property',
                    //     'inputs': {
                    //         'NUMBER_TO_CHECK': {
                    //             'shadow': {
                    //                 'type': 'math_number',
                    //                 'fields': {
                    //                     'NUM': 0,
                    //                 },
                    //             },
                    //         },
                    //     },
                    // },
                    {
                        'kind': 'block',
                        'type': 'list_index',
                        'inputs': {
                            'INDEX': {
                                'shadow': {
                                    'type': 'math_number',
                                    'fields': {
                                        'NUM': 0,
                                    },
                                },
                            }
                        }
                    },
                    {
                        'kind': 'block',
                        'type': 'list_range',
                    },
                    {
                        'kind': 'block',
                        'type': 'list_concat',
                    },
                ],
            },
            // {
            //     'kind': 'category',
            //     'name': 'Text',
            //     'categorystyle': 'text_category',
            //     'contents': [
            //         {
            //             'kind': 'block',
            //             'type': 'text',
            //         },
            //         {
            //             'kind': 'block',
            //             'type': 'text_multiline',
            //         },
            //         {
            //             'kind': 'label',
            //             'text': 'Input/Output:',
            //             'web-class': 'ioLabel',
            //         },
            //         {
            //             'kind': 'block',
            //             'type': 'text_print',
            //             'inputs': {
            //                 'TEXT': {
            //                     'shadow': {
            //                         'type': 'text',
            //                         'fields': {
            //                             'TEXT': 'abc',
            //                         },
            //                     },
            //                 },
            //             },
            //         },
            //         {
            //             'kind': 'block',
            //             'type': 'text_prompt_ext',
            //             'inputs': {
            //                 'TEXT': {
            //                     'shadow': {
            //                         'type': 'text',
            //                         'fields': {
            //                             'TEXT': 'abc',
            //                         },
            //                     },
            //                 },
            //             },
            //         },
            //     ],
            // },
            {
                'kind': 'sep',
            },
            {
                'kind': 'category',
                'name': 'Signals',
                'categorystyle': 'variable_category',
                "contents": [
                    {
                        "kind": "block",
                        "type": "variables_get"
                    },
                    {
                        "kind": "block",
                        "type": "variables_set"
                    },
                    {
                        'kind': 'block',
                        'type': 'variables_set_index',
                        'inputs': {
                            'INDEX': {
                                'shadow': {
                                    'type': 'math_number',
                                    'fields': {
                                        'NUM': 0,
                                    },
                                },
                            }
                        }
                    },
                    {
                        "kind": "block",
                        "type": "math_change"
                    }
                ]
            },
            // {
            //     "kind": "category",
            //     "name": "Functions & Procedures",
            //     'categorystyle': 'procedure_category',
            //     "custom": "PROCEDURE"
            // },
            {
                'kind': 'category',
                'name': 'Processes',
                "colour": 190,
                'contents': [
                    {
                        "kind": "block",
                        "type": "process"
                    },
                    {
                        "kind": "block",
                        "type": "process_wait"
                    },
                    {
                        "kind": "block",
                        "type": "process_direct_set"
                    }
                ],
            },
        ],
    };

    Blockly.defineBlocksWithJsonArray([
        {
            "kind": "block",
            "type": "process",
            "message0": "process %1",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "1",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                }
            ],
            "message1": "%1",
            "args1": [
                { "type": "input_statement", "name": "body" }
            ],
            "colour": 190,
            "mutator": "process_mutator",
            "tooltip": "A VHDL process"
        },
        {
            "kind": "block",
            "type": "process_internal_container",
            "message0": "process",
            "args0": [],
            "message1": "%1",
            "args1": [
                { "type": "input_statement", "name": "body" }
            ],
            "colour": 190
        },
        {
            "kind": "block",
            "type": "process_internal_item",
            "message0": "dependency",
            "args0": [],
            "previousStatement": null,
            "nextStatement": null,
            "colour": 190
        },
        {
            "kind": "block",
            "type": "process_internal_all",
            "message0": "all",
            "args0": [],
            "previousStatement": null,
            "colour": 190
        },
        {
            "kind": "block",
            "type": "process_wait",
            "message0": "wait",
            "args0": [],
            "previousStatement": null,
            "nextStatement": null,
            "colour": 190,
            "tooltip": "A VHDL wait statement"
        },
        {
            "type": "process_direct_set",
            "message0": "directly set %1 to %2",
            "colour": "%{BKY_VARIABLES_HUE}",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "VAR",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                },
                {
                    "type": "input_value",    // This expects an input of any type
                    "name": "VALUE"
                }
            ],
            "tooltip": "Create a process that is sensitive to all that does `VAR <= VALUE`"
        },
        {
            "kind": "block",
            "type": "value_std_logic",
            "colour": 30,
            "message0": "'%1'",
            "args0": [
                {
                    "type": "field_number",
                    "name": "VALUE",
                    "min": 0,
                    "max": 1,
                    "precision": 1,
                    "value": 1,
                }
            ],
            "output": null,
            "tooltip": "STD_LOGIC input"
        },
        {
            "kind": "block",
            "type": "value_std_logic_vector",
            "colour": 30,
            "message0": "\"%1\"",
            "args0": [
                {
                    "type": "field_input",
                    "name": "VALUE",
                }
            ],
            "output": null,
            "tooltip": "STD_LOGIC_VECTOR input"
        },
        {
            "kind": "block",
            "type": "logic_operation_vector",
            "message0": "%1 %2",
            "args0": [
                {
                    "type": "field_dropdown",
                    "name": "OPERATION",
                    "options": [
                        ["AND", "and"],
                        ["OR", "or"],
                        ["XOR", "xor"],
                        ["NOR", "nor"],
                        ["NAND", "nand"],
                        ["XNOR", "xnor"],
                    ]
                },
                {
                    "type": "input_value",
                    "name": "LIST",
                }
            ],
            "output": "Boolean",
            "inputsInline": true,
            "style": "logic_blocks",
            "tooltip": "Do a logic operation with the bits of the vector as input."
        },
        {
            "kind": "block",
            "type": "logic_not",
            "message0": "not %1",
            "args0": [
                {
                    "type": "input_value",
                    "name": "INPUT",
                }
            ],
            "output": "Boolean",
            "inputsInline": true,
            "style": "logic_blocks",
            "tooltip": "Inverts input"
        },
        {
            "kind": "block",
            "type": "others_to",
            "message0": "others => %1",
            "args0": [
                {
                    "type": "input_value",
                    "name": "INPUT",
                }
            ],
            "output": null,
            "inputsInline": true,
            "colour": "%{BKY_MATH_HUE}",
            "tooltip": "Creates a list of inferred length"
        },
        {
            "kind": "block",
            "type": "logic_operation",
            "message0": "%1 %2 %3",
            "args0": [
                {
                    "type": "input_value",
                    "name": "A",
                },
                {
                    "type": "field_dropdown",
                    "name": "OPERATION",
                    "options": [
                        ["AND", "and"],
                        ["OR", "or"],
                        ["XOR", "xor"],
                        ["NOR", "nor"],
                        ["NAND", "nand"],
                        ["XNOR", "xnor"],
                    ]
                },
                {
                    "type": "input_value",
                    "name": "B",
                }
            ],
            "output": "Boolean",
            "style": "logic_blocks",
            "inputsInline": true,
            "tooltip": "Do a logic operation with A and B as inputs"
        },
        {
            "kind": "block",
            "type": "list_index",
            "message0": "%1 %2",
            "colour": "%{BKY_MATH_HUE}",
            "args0": [
                {
                    "type": "input_value",
                    "name": "LIST"
                },
                {
                    "type": "input_value",
                    "name": "INDEX",
                }
            ],
            "output": null,
            "inputsInline": true,
            "tooltip": "List index"
        },
        {
            "kind": "block",
            "type": "list_range",
            "message0": "%1 %2 %3 %4",
            "colour": "%{BKY_MATH_HUE}",
            "args0": [
                {
                    "type": "input_value",
                    "name": "LIST"
                },
                {
                    "type": "field_number",
                    "name": "FROM",
                    "min": 0,
                    "value": 0,
                },
                {
                    "type": "field_dropdown",
                    "name": "ORDER",
                    "options": [
                        ["to", "to"],
                        ["downto", "downto"]
                    ]
                },
                {
                    "type": "field_number",
                    "name": "TO",
                    "min": 0,
                    "value": 0,
                }
            ],
            "output": null,
            "tooltip": "Logic range"
        },
        {
            "kind": "block",
            "type": "list_concat",
            "message0": "%1 & %2",
            "colour": "%{BKY_MATH_HUE}",
            "args0": [
                {
                    "type": "input_value",
                    "name": "A",
                },
                {
                    "type": "input_value",
                    "name": "B",
                }
            ],
            "output": null,
            "inputsInline": true,
            "tooltip": "Join 2 lists together"
        },
        {
            "type": "variables_set",
            "message0": "set %1 to %2",
            "colour": "%{BKY_VARIABLES_HUE}",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "VAR",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                },
                {
                    "type": "input_value",    // This expects an input of any type
                    "name": "VALUE"
                }
            ],
            "inputsInline": true,
            "previousStatement": null,
            "nextStatement": null,
            "tooltip": "Set a signal"
        },
        {
            "type": "variables_get",
            "message0": "%1",
            "colour": "%{BKY_VARIABLES_HUE}",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "VAR",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                }
            ],
            "inputsInline": true,
            "output": null,
            "tooltip": "Get a signal"
        },
        {
            "type": "math_change",
            "message0": "change %1 by %2",
            "colour": "%{BKY_VARIABLES_HUE}",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "VAR",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                },
                {
                    "type": "input_value",
                    "name": "DELTA"
                }
            ],
            "inputsInline": true,
            "previousStatement": null,
            "nextStatement": null,
            "tooltip": "Change a signal"
        },
        {
            "type": "variables_set_index",
            "message0": "set %1 %2 to %3",
            "colour": "%{BKY_VARIABLES_HUE}",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "VAR",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                },
                {
                    "type": "input_value",
                    "name": "INDEX",
                },
                {
                    "type": "input_value",    // This expects an input of any type
                    "name": "VALUE"
                }
            ],
            "inputsInline": true,
            "previousStatement": null,
            "nextStatement": null,
            "tooltip": "Set an index of a  signal"
        },
        {
            "kind": "block",
            "type": "logic_rising_edge",
            "message0": "rising_edge %1",
            "args0": [
                {
                    "type": "field_variable",
                    "name": "dep",
                    // "variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
                }
            ],
            "output": "Boolean",
            "style": "logic_blocks",
            "tooltip": "Goes high in the rising edge of the variable"
        },
        {
            "kind": "block",
            "type": "report",
            "message0": "report %1",
            "args0": [
                {
                    "type": "field_input",
                    "name": "S"
                }
            ],
            "previousStatement": null,
            "nextStatement": null,
            "tooltip": "print a message in the simulator (does not synthesise)"
        },
        {
            "kind": "block",
            "type": "controls_case",
            "message0": "case %1 is",
            "args0": [
                {
                    "type": "input_value",
                    "name": "ON"
                }
            ],
            "message1": "%1",
            "args1": [
                { "type": "input_statement", "name": "body", "check": ["controls_when"] }
            ],
            "colour": "%{BKY_LOGIC_HUE}",
            "previousStatement": null,
            "nextStatement": null,
            "inputsInline": true,
            "tooltip": "case"
        },
        {
            "kind": "block",
            "type": "controls_when",
            "message0": "when %1",
            "args0": [
                {
                    "type": "input_value",
                    "name": "TEST"
                }
            ],
            "message1": "%1",
            "args1": [
                { "type": "input_statement", "name": "body" }
            ],
            "colour": "%{BKY_LOGIC_HUE}",
            "previousStatement": "controls_when",
            "nextStatement": "controls_when",
            "tooltip": "when"
        },
        {
            "kind": "block",
            "type": "logic_others",
            "message0": "others",
            "colour": "%{BKY_LOGIC_HUE}",
            "args0": [],
            "output": null,
            "tooltip": "The pattern for anything that doesn't match any other patterns"
        },
        {
            "kind": "block",
            "type": "logic_or",
            "message0": "%1 | %2",
            "colour": "%{BKY_LOGIC_HUE}",
            "args0": [
                {
                    "type": "input_value",
                    "name": "A"
                },
                {
                    "type": "input_value",
                    "name": "B"
                }
            ],
            "inputsInline": true,
            "output": null,
            "tooltip": "The pattern that matches both of the patterns supplied"
        },
    ]);

    Blockly.Extensions.registerMutator("process_mutator", {
        updateShape_: function () {
            if (this.all_) {
                if (this.prevDepCount_ > 0) {
                    for (var i = this.prevDepCount_; i > 0; i--) {
                        this.inputList[0].removeField(i.toString());
                    }
                }
                this.prevDepCount_ = 0;
                this.inputList[0].removeField("all", true);
                this.inputList[0].appendField(new Blockly.FieldLabel("all"), "all");
            } else {
                this.inputList[0].removeField("all", true);
                if (this.prevDepCount_ < this.depCount_) {
                    for (var i = this.prevDepCount_ + 1; i <= this.depCount_; i++) {
                        this.inputList[0].appendField(new Blockly.FieldVariable(), i.toString());
                    }
                } else if (this.prevDepCount_ > this.depCount_) {
                    for (var i = this.prevDepCount_; i > this.depCount_; i--) {
                        this.inputList[0].removeField(i.toString());
                    }
                }
                this.prevDepCount_ = this.depCount_;
            }
        },

        saveExtraState: function () {
            return {
                'depCount': this.depCount_,
                'all': this.all_,
            };
        },
        loadExtraState: function (state) {
            this.depCount_ = state['depCount'];
            this.all_ = state['all'];
            this.updateShape_();
        },

        decompose: function (workspace) {
            var topBlock = workspace.newBlock('process_internal_container');
            topBlock.initSvg();

            var connection = topBlock.getInput('body').connection;
            for (var i = 0; i < this.depCount_; i++) {
                var itemBlock = workspace.newBlock('process_internal_item');
                itemBlock.initSvg();
                connection.connect(itemBlock.previousConnection);
                connection = itemBlock.nextConnection;
            }

            if (this._all) {
                var itemBlock = workspace.newBlock('process_internal_all');
                itemBlock.initSvg();
                connection.connect(itemBlock.previousConnection);
            }

            return topBlock;
        },
        compose: function (topBlock) {
            var itemBlock = topBlock.getInputTargetBlock('body');

            var connections = [];
            var all = false;
            var allConnection = undefined;
            while (itemBlock && !itemBlock.isInsertionMarker()) {
                if (itemBlock.type === "process_internal_item") {
                    connections.push(itemBlock.valueConnection_);
                } else if (itemBlock.type === "process_internal_all") {
                    all = true;
                    allConnection = itemBlock.valueConnection_;
                }
                itemBlock = itemBlock.nextConnection?.targetBlock();
            }

            this.depCount_ = connections.length;
            this.all_ = all;
            this.updateShape_();

            for (var i = 0; i < this.itemCount_; i++) {
                Blockly.Mutator.reconnect(connections[i], this, 'item' + i);
            }
            if (all) Blockly.Mutator.reconnect(allConnection, this, 'all');
        },
    }, function () {
        this.prevDepCount_ = 1;
        this.depCount_ = 1;
        this.all_ = false;
        this.updateShape_();
    }, ["process_internal_item", "process_internal_all"]);

    Blockly.dialog.setAlert((m, cb) => (alert(m), cb()));
    Blockly.dialog.setPrompt((m, a, cb) => prompt(m).then((d) => cb(d ?? a)));
    Blockly.dialog.setConfirm((m, cb) => confirm(m).then((d) => cb(d ?? false)));

    const entityVars = {};
    const aliasVars = {};

    (() => {
        Blockly.fieldRegistry.unregister("field_variable");
        Blockly.fieldRegistry.register("field_variable", Blockly.FieldVariable = class extends Blockly.FieldVariable {
            renderSelectedText_() {
                super.renderSelectedText_();
                if (["variables_get", "variables_set", "variables_set_index", "math_change", "process_direct_set"].indexOf(this.sourceBlock_.type) !== -1) {
                    if (Object.keys(entityVars).indexOf(this.value_) !== -1) this.sourceBlock_.setColour(20);
                    else if (Object.keys(aliasVars).indexOf(this.value_) !== -1) this.sourceBlock_.setColour(120);
                    else this.sourceBlock_.setColour('%{BKY_VARIABLES_HUE}');
                }
            }

            initModel() {
                if (!this.variable_) {
                    if (this.defaultVariableName === "") {
                        this.doValueUpdate_(this.getSourceBlock().workspace.getAllVariables()[0].getId());
                    } else {
                        super.initModel();
                    }
                }
            }
        });
    })();

    const theme = Blockly.Theme.defineTheme('vscode', {
        'base': Blockly.Themes.Classic,
        'componentStyles': {
            'workspaceBackgroundColour': 'var(--vscode-editor-background)',
            'toolboxBackgroundColour': 'var(--vscode-editorWidget-background)',
            'toolboxForegroundColour': 'var(--vscode-editorWidget-foreground)',
            'flyoutBackgroundColour': 'var(--vscode-editorWidget-background)',
            'flyoutForegroundColour': 'var(--vscode-editorWidget-foreground)',
            'flyoutOpacity': 0.8,
            'scrollbarColour': '#797979',
            'insertionMarkerColour': '#fff',
            'insertionMarkerOpacity': 0.3,
            'scrollbarOpacity': 0.4,
            'cursorColour': '#d0d0d0',
        },
    });

    const MAPGenerator = new Blockly.Generator("MAP");
    const VHDLGenerator = new Blockly.Generator("VHDL");

    MAPGenerator.ORDER_ATOMIC   /**/ = VHDLGenerator.ORDER_ATOMIC   /**/ = 0;
    MAPGenerator.ORDER_FUNCTION_CALL = VHDLGenerator.ORDER_FUNCTION_CALL = 1;
    MAPGenerator.ORDER_INDEX    /**/ = VHDLGenerator.ORDER_INDEX    /**/ = 1.1;
    MAPGenerator.ORDER_CONCAT   /**/ = VHDLGenerator.ORDER_CONCAT   /**/ = 2;
    MAPGenerator.ORDER_MUL      /**/ = VHDLGenerator.ORDER_MUL      /**/ = 3.0;
    MAPGenerator.ORDER_DIV      /**/ = VHDLGenerator.ORDER_DIV      /**/ = 3.1;
    MAPGenerator.ORDER_SUB      /**/ = VHDLGenerator.ORDER_SUB      /**/ = 4.1;
    MAPGenerator.ORDER_ADD      /**/ = VHDLGenerator.ORDER_ADD      /**/ = 4.2;
    MAPGenerator.ORDER_NOT      /**/ = VHDLGenerator.ORDER_NOT      /**/ = 5;
    MAPGenerator.ORDER_COMPARE  /**/ = VHDLGenerator.ORDER_COMPARE  /**/ = 6;
    MAPGenerator.ORDER_LOGIC    /**/ = VHDLGenerator.ORDER_LOGIC    /**/ = 7;
    MAPGenerator.ORDER_NONE     /**/ = VHDLGenerator.ORDER_NONE     /**/ = 99;

    const Generator = {};

    Generator.finish = function (generator, code) {
        function gen_signals(signals) {
            return Object.keys(signals).map((n) =>
                "\n  signal " + n + " : " + signals[n] + ";"
            ).join("");
        }
        return librariesCode + "\n\n" + entityCode + "\n\n\narchitecture scratch of " + name + " is\n" + constantsCode + "\n" + gen_signals(entity.signals) + "\n" + aliasesCode + "\n\nbegin\n" + Object.getPrototypeOf(generator).finish.call(generator, code) + "\n\nend architecture;\n";
    }

    Generator.scrub_ = function (generator, block, code, opt_thisOnly) {
        let commentCode = '';
        // Only collect comments for blocks that aren't inline.
        if (!block.outputConnection || !block.outputConnection.targetConnection) {
            // Collect comment for this block.
            let comment = block.getCommentText();
            if (comment) {
                comment = Blockly.utils.string.wrap(comment, generator.COMMENT_WRAP - 3);
                commentCode += generator.prefixLines(comment, '-- ') + '\n';
            }
            // Collect comments for all value arguments.
            // Don't collect comments for nested statements.
            for (let i = 0; i < block.inputList.length; i++) {
                if (block.inputList[i].type === Blockly.inputTypes.VALUE) {
                    const childBlock = block.inputList[i].connection.targetBlock();
                    if (childBlock) {
                        comment = generator.allNestedComments(childBlock);
                        if (comment) {
                            commentCode += generator.prefixLines(comment, '-- ');
                        }
                    }
                }
            }
        }
        const nextBlock = block.nextConnection && block.nextConnection.targetBlock();
        const nextCode = opt_thisOnly ? '' : generator.blockToCode(nextBlock);
        return commentCode + code + nextCode;
    };

    Generator.process = function (generator, block) {
        return "\n  process" + ((a) => a.length > 0 ? "(" + a + ")" : "")(
            block.all_ ? "all" : block.inputList[0]
                .fieldRow.filter(
                    (a) => a instanceof Blockly.FieldVariable
                ).map(
                    (a) => a.getVariable().name
                ).join(", ")) + "\n  begin\n  " +
            generator.statementToCode(block, 'body').replaceAll("\n", "\n  ") +
            "end process;";
    }

    Generator.process_wait = function (generator, block) {
        return 'wait;\n';
    }

    Generator.process_direct_set = function (generator, block) {
        return "\n  " + block.getField("VAR").getVariable().name + ' <= ' +
            generator.valueToCode(block, 'VALUE', generator.ORDER_NONE) + ';';
    }

    Generator.controls_if = function (generator, block) {
        let n = 0;
        let code = '';
        while (block.getInput('IF' + n)) {
            const conditionCode =
                generator.valueToCode(block, 'IF' + n, generator.ORDER_NONE) || 'false';
            let branchCode = generator.statementToCode(block, 'DO' + n);
            code +=
                (n > 0 ? 'els' : '') + 'if ' + conditionCode + ' then\n' + branchCode;
            n++;
        }

        if (block.getInput('ELSE')) {
            let branchCode = generator.statementToCode(block, 'ELSE');
            code += 'else\n' + branchCode;
        }
        return code + 'end if;\n';
    }

    Generator.controls_case = function (generator, block) {
        return "case " + generator.valueToCode(block, "ON", generator.ORDER_NONE) + " is\n" + generator.statementToCode(block, 'body') + "end case;\n";
    }

    Generator.controls_when = function (generator, block) {
        return "when " + generator.valueToCode(block, "TEST", generator.ORDER_NONE) + " =>\n" + generator.statementToCode(block, 'body') + "\n";
    }

    Generator.logic_others = function (generator, block) {
        return ["others", generator.ORDER_ATOMIC];
    }

    Generator.others_to = function (generator, block) {
        return ["(others => " + generator.valueToCode(block, "INPUT", generator.ORDER_NONE) + ")", generator.ORDER_ATOMIC];
    }

    Generator.logic_or = function (generator, block) {
        return [generator.valueToCode(block, "A", generator.ORDER_NONE) + " | " + generator.valueToCode(block, 'B', generator.ORDER_NONE), generator.ORDER_ATOMIC];
    }

    Generator.logic_rising_edge = function (generator, block) {
        return ["rising_edge(" + block.getField("dep").getVariable().name + ")", generator.ORDER_FUNCTION_CALL]
    }

    Generator.logic_not = function (generator, block) {
        return ["not " + generator.valueToCode(block, "INPUT", generator.ORDER_NOT), generator.ORDER_NOT]
    }

    Generator.logic_boolean = function (generator, block) {
        return [block.getFieldValue(""), generator.ORDER_ATOMIC]
    }

    Generator.logic_operation = function (generator, block) {
        return [generator.valueToCode(block, "A", generator.ORDER_LOGIC) + " " + block.getFieldValue("OPERATION") + " " + generator.valueToCode(block, "B", generator.ORDER_LOGIC), generator.ORDER_LOGIC]
    }

    Generator.logic_operation_vector = function (generator, block) {
        return [block.getFieldValue("OPERATION") + "(" + generator.valueToCode(block, "LIST", generator.ORDER_NONE) + ")", generator.ORDER_FUNCTION_CALL]
    }

    Generator.logic_compare = function (generator, block) {
        return [generator.valueToCode(block, "A", generator.ORDER_COMPARE) + " = " + generator.valueToCode(block, "B", generator.ORDER_COMPARE), generator.ORDER_COMPARE]
    }

    Generator.variables_get = function (generator, block) {
        return [block.getField("VAR").getVariable().name, generator.ORDER_ATOMIC];
    }

    Generator.constant = function (generator, block) {
        return [block.getFieldValue("NAME"), generator.ORDER_ATOMIC];
    }

    Generator.variables_set = function (generator, block) {
        return block.getField("VAR").getVariable().name + ' <= ' +
            generator.valueToCode(block, 'VALUE', generator.ORDER_NONE) + ';\n';
    }

    Generator.variables_set_index = function (generator, block) {
        return block.getField("VAR").getVariable().name + "(" + generator.valueToCode(block, 'INDEX', generator.ORDER_NONE) + ') <= ' +
            generator.valueToCode(block, 'VALUE', generator.ORDER_NONE) + ';\n';
    }

    Generator.math_change = function (generator, block) {
        return block.getField("VAR").getVariable().name + ' <= ' +
            block.getField("VAR").getVariable().name + " + " + generator.valueToCode(block, 'DELTA', generator.ORDER_ADD) + ';\n';
    }

    Generator.value_std_logic = function (generator, block) {
        return ["'" + block.getFieldValue("VALUE") + "'", generator.ORDER_ATOMIC];
    };

    Generator.value_std_logic_vector = function (generator, block) {
        return ['"' + block.getFieldValue("VALUE") + '"', generator.ORDER_ATOMIC];
    };

    Generator.math_number = function (generator, block) {
        return [block.getFieldValue("NUM"), generator.ORDER_ATOMIC];
    };

    Generator.math_arithmetic = function (generator, block) {
        // Basic arithmetic operators, and power.
        const OPERATORS = {
            'ADD': [' + ', generator.ORDER_ADD],
            'MINUS': [' - ', generator.ORDER_SUB],
            'MULTIPLY': [' * ', generator.ODER_MUL],
            'DIVIDE': [' / ', generator.ORDER_DIV],
        };
        const tuple = OPERATORS[block.getFieldValue('OP')];
        const order = tuple[1];
        return [generator.valueToCode(block, 'A', order) || '0' + tuple[0] + generator.valueToCode(block, 'B', order) || '0', order];
    };

    Generator.list_index = function (generator, block) {
        return [generator.valueToCode(block, 'LIST', generator.ORDER_INDEX) + "(" + generator.valueToCode(block, 'INDEX', generator.ORDER_NONE) + ")", ["list_index", "list_range"].includes(block.getParent().type) ? generator.ORDER_ATOMIC : generator.ORDER_INDEX];
    };

    Generator.list_range = function (generator, block) {
        return [generator.valueToCode(block, 'LIST', generator.ORDER_INDEX) + "(" + block.getFieldValue("FROM") + " " + block.getFieldValue("ORDER") + " " + block.getFieldValue("TO") + ")", ["list_index", "list_range"].includes(block.getParent().type) ? generator.ORDER_ATOMIC : generator.ORDER_INDEX];
    };

    Generator.list_concat = function (generator, block) {
        return [generator.valueToCode(block, 'A', generator.ORDER_CONCAT) + " & " + generator.valueToCode(block, 'B', generator.ORDER_CONCAT), generator.ORDER_CONCAT];
    };

    Generator.report = function (generator, block) {
        return "report " + block.getFieldValue("S") + ";\n";
    };

    const u = String.fromCharCode;

    Object.keys(Generator).forEach((b) => {
        VHDLGenerator[b] = Generator[b].bind(undefined, VHDLGenerator);
        MAPGenerator[b] = function (block) {
            const c = Generator[b].bind(this)(MAPGenerator, block);
            if (c instanceof Array) return [u(0x200B) + block.id + u(0x200B) + c[0] + u(0xFEFF), c[1]];
            else return u(0x200B) + block.id + u(0x200B) + c + u(0xFEFF);
        };
    });
    MAPGenerator.scrub_ = Generator.scrub_.bind(undefined, MAPGenerator);
    MAPGenerator.finish = Generator.finish.bind(undefined, MAPGenerator);

    function generateMap() {
        const map = {};
        var i = 0;
        var l = 1;
        var c = 1;
        function gen(code) {
            while (i < code.length) {
                if (code[i] === '\n') {
                    l++;
                    c = 1;
                } else c++;
                if (code[i] === u(0x200B)) {
                    i++;
                    c--;
                    var id = "";
                    var s = [l, c];
                    while (code[i] !== u(0x200B)) {
                        id += code[i];
                        i++;
                    }
                    i++;
                    gen(code);
                    map[id] = [s, [l, c]]
                } else if (code[i] === u(0xFEFF)) {
                    c--;
                    return;
                }
                i++;
            }
        }
        gen(MAPGenerator.workspaceToCode(ws));
        return map;
    }
    function highlightCodePosition(line, column) {
        column = column || 0;
        const map = generateMap();
        ws.getBlockById(Object.entries(map)
            .filter(([_, range]) =>
                (range[0][0] < line &&
                    range[1][0] > line) ||
                (range[0][0] === line &&
                    column > range[0][1]) ||
                (range[1][0] === line &&
                    column < range[1][1])
            ).reduce(
                (a, b) =>
                    (a[1][0][0] > b[1][0][0] ||
                        (a[1][0][0] === b[1][0][0] && a[1][0][1] > b[1][0][1])) ? a : b,
                [null, [[-Infinity, -Infinity]]]
            )[0]).select();
    }

    // TODO: finish
    // VHDLGenerator.procedures_defreturn = function (block) {
    //     // Define a procedure with a return value.
    //     const funcName = block.getFieldValue("NAME");
    //     let branch = VHDLGenerator.statementToCode(block, 'STACK');
    //     let returnValue = VHDLGenerator.valueToCode(block, 'RETURN', VHDLGenerator.ORDER_NONE) || '';
    //     if (returnValue) {
    //         returnValue = 'return ' + returnValue + '\n';
    //     } else if (!branch) {
    //         branch = '';
    //     }
    //     const args = [];
    //     const variables = block.getVars();
    //     for (let i = 0; i < variables.length; i++) {
    //         args[i] = variables[i].name;
    //     }
    //     return 'function ' + funcName + '(' + args.join('; ') + ')\n' + branch + returnValue + 'end function;\n';
    // };

    // VHDLGenerator.procedures_defnoreturn = function (block) {
    //     // Define a procedure with a return value.
    //     const funcName = block.getFieldValue("NAME");
    //     let branch = VHDLGenerator.statementToCode(block, 'STACK') || "";
    //     const args = [];
    //     const variables = block.getVars();
    //     for (let i = 0; i < variables.length; i++) {
    //         args[i] = variables[i].name;
    //     }
    //     return 'function ' + funcName + '(' + args.join(', ') + ')\n' + branch + returnValue + 'end\n';
    // };

    // VHDLGenerator.procedures_callreturn = function (block) {
    //     const funcName = block.getFieldValue('NAME');
    //     const args = [];
    //     const variables = block.getVars();
    //     for (let i = 0; i < variables.length; i++) {
    //         args[i] = Lua.valueToCode(block, 'ARG' + i, Lua.ORDER_NONE) || 'nil';
    //     }
    //     const code = funcName + '(' + args.join(', ') + ')';
    //     return [code, Lua.ORDER_HIGH];
    // };

    // Lua['procedures_callnoreturn'] = function (block) {
    //     // Call a procedure with no return value.
    //     // Generated code is for a function call as a statement is the same as a
    //     // function call as a value, with the addition of line ending.
    //     const tuple = Lua['procedures_callreturn'](block);
    //     return tuple[0] + '\n';
    // };

    // Lua['procedures_ifreturn'] = function (block) {
    //     // Conditionally return value from a procedure.
    //     const condition =
    //         Lua.valueToCode(block, 'CONDITION', Lua.ORDER_NONE) || 'false';
    //     let code = 'if ' + condition + ' then\n';
    //     if (Lua.STATEMENT_SUFFIX) {
    //         // Inject any statement suffix here since the regular one at the end
    //         // will not get executed if the return is triggered.
    //         code +=
    //             Lua.prefixLines(Lua.injectId(Lua.STATEMENT_SUFFIX, block), Lua.INDENT);
    //     }
    //     if (block.hasReturnValue_) {
    //         const value = Lua.valueToCode(block, 'VALUE', Lua.ORDER_NONE) || 'nil';
    //         code += Lua.INDENT + 'return ' + value + '\n';
    //     } else {
    //         code += Lua.INDENT + 'return\n';
    //     }
    //     code += 'end\n';
    //     return code;
    // };

    const ws = Blockly.inject('root', {
        toolbox: structuredClone(toolbox),
        grid: {
            spacing: 25,
            length: 3,
            colour: '#ccc',
            snap: true,
        },
        zoom: {
            controls: true,
            wheel: true,
            startScale: 1.0,
            maxScale: 3,
            minScale: 0.3,
            scaleSpeed: 1.2,
            pinch: true
        },
        theme,
        renderer: "zelos"
    });

    const bp = new StorageBackpack(ws);
    bp.init();

    let entity = {};
    let libraries = {};
    let entityCode = "";
    let librariesCode = "";
    let constantsCode = "";
    let aliasesCode = "";

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "View Code",
        preconditionFn() {
            return "enabled";
        },
        callback() {
            vscode.postMessage({
                type: "code"
            });
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'viewCode',
        weight: -1,
    });

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "Generated by",
        preconditionFn() {
            return "enabled";
        },
        async callback() {
            let p = (await prompt("Position (line[:column]):")).split(":");
            highlightCodePosition(p[0], p[1])
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'generatedBy',
        weight: -0.9,
    });

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "Run",
        preconditionFn() {
            return entity.command ? "enabled" : "disabled";
        },
        callback() {
            vscode.postMessage({
                type: "cmd",
                cmd: entity.command
            });
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'run',
        weight: -0.8,
    });

    // const notExists = (n) => !(entity.entity.hasOwnProperty(n) || signals.hasOwnProperty(n) || constants.hasOwnProperty(n) || aliases.hasOwnProperty(n));

    function table_modal(columns, data) {
        return new Promise((resolve) => {
            const isArray = Object.values(data)[0] instanceof Array;

            const modal = document.createElement("dialog");
            const table = document.createElement("table");

            const cs = document.createElement("tr");
            cs.appendChild(document.createElement("th"));
            columns.forEach((c) => {
                const a = document.createElement("th");
                a.innerText = c;
                cs.appendChild(a);
            });
            table.appendChild(cs);

            const rows = [];
            Object.keys(data).forEach((r, i) => {
                const a = document.createElement("tr");

                const rem = document.createElement("td");
                const remb = document.createElement("button");
                remb.innerText = "-";
                remb.addEventListener("click", () => {
                    table.deleteRow(1 + i);
                    rows.splice(i, 1);
                });
                rem.appendChild(remb);
                a.appendChild(rem);

                const cols = [];

                const n = document.createElement("td");
                const ni = document.createElement("input");
                ni.type = "text";
                ni.value = r;
                cols.push(ni);
                n.appendChild(ni);
                a.appendChild(n);

                if (isArray) {
                    data[r].forEach((x) => {
                        const b = document.createElement("td");
                        const ib = document.createElement("input");
                        ib.type = "text";
                        ib.value = x;
                        cols.push(ib);
                        b.appendChild(ib);
                        a.appendChild(b);
                    });
                } else {
                    const b = document.createElement("td");
                    const ib = document.createElement("input");
                    ib.type = "text";
                    ib.value = data[r];
                    cols.push(ib);
                    b.appendChild(ib);
                    a.appendChild(b);
                }

                rows.push(cols);
                table.appendChild(a);
            });

            modal.appendChild(table);

            const addb = document.createElement("button");
            addb.innerText = "+";
            addb.addEventListener("click", () => {
                const i = rows.length;
                const a = document.createElement("tr");

                const rem = document.createElement("td");
                const remb = document.createElement("button");
                remb.innerText = "-";
                remb.addEventListener("click", () => {
                    table.deleteRow(1 + i);
                    rows.splice(i, 1);
                });
                rem.appendChild(remb);
                a.appendChild(rem);

                const cols = [];

                const n = document.createElement("td");
                const ni = document.createElement("input");
                ni.type = "text";
                cols.push(ni);
                n.appendChild(ni);
                a.appendChild(n);

                if (isArray) {
                    for (var j = 0; j < Object.values(data)[0].length; j++) {
                        const b = document.createElement("td");
                        const ib = document.createElement("input");
                        ib.type = "text";
                        cols.push(ib);
                        b.appendChild(ib);
                        a.appendChild(b);
                    }
                } else {
                    const b = document.createElement("td");
                    const ib = document.createElement("input");
                    ib.type = "text";
                    cols.push(ib);
                    b.appendChild(ib);
                    a.appendChild(b);
                }

                rows.push(cols);
                table.appendChild(a);
            });
            modal.appendChild(addb);

            const submit = document.createElement("button");
            submit.innerText = "Submit";
            submit.addEventListener("click", () => {
                modal.removeEventListener("close", () => resolve(data));
                modal.close();
                if (isArray) {
                    const arraySplit = (array) => [array[0], array.slice(1)];
                    resolve(Object.fromEntries(rows.map((cols) => arraySplit(cols.map(c => c.value)))));
                } else {
                    resolve(Object.fromEntries(rows.map((cols) => cols.map(c => c.value))));
                }
            });
            modal.appendChild(submit);

            document.body.appendChild(modal);
            modal.showModal();
            modal.addEventListener("close", () => resolve(data));
        })
    }

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "Edit ports",
        preconditionFn() {
            return "enabled";
        },
        callback() {
            table_modal(["name", "direction", "type"], entity.entity).then((data) => {
                entity.entity = data;
                vscode.postMessage({
                    type: "updateEntity",
                    body: JSON.stringify(entity)
                });
            })
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'editPorts',
        weight: 9,
    });

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "Edit signals",
        preconditionFn() {
            return "enabled";
        },
        callback() {
            table_modal(["name", "type"], entity.signals).then((data) => {
                entity.signals = data;
                vscode.postMessage({
                    type: "updateEntity",
                    body: JSON.stringify(entity)
                });
            })
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'editSignals',
        weight: 9.0,
    });

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "Edit constants",
        preconditionFn() {
            return "enabled";
        },
        callback() {
            table_modal(["name", "type", "value"], entity.constants).then((data) => {
                entity.constants = data;
                vscode.postMessage({
                    type: "updateEntity",
                    body: JSON.stringify(entity)
                });
            })
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'editConstants',
        weight: 9.0,
    });

    Blockly.ContextMenuRegistry.registry.register({
        displayText: "Edit aliases",
        preconditionFn() {
            return "enabled";
        },
        callback() {
            table_modal(["name", "value"], entity.aliases).then((data) => {
                entity.aliases = data;
                vscode.postMessage({
                    type: "updateEntity",
                    body: JSON.stringify(entity)
                });
            })
        },
        scopeType: Blockly.ContextMenuRegistry.ScopeType.WORKSPACE,
        id: 'editAliases',
        weight: 9.0,
    });

    let name = "hi";

    // window.addEventListener('message',
    //     (message) => message.data.type == "getFileData" &&
    //         vscode.postMessage({
    //             type: 'response',
    //             requestId: message.data.requestId,
    //             body: VHDLGenerator.workspaceToCode(ws)
    //         }));
    // window.addEventListener('message',
    //     (message) => message.data.type == "getScratchData" &&
    //         vscode.postMessage({
    //             type: 'response',
    //             requestId: message.data.requestId,
    //             body: JSON.stringify(Blockly.serialization.workspaces.save(ws))
    //         }));
    // window.addEventListener('message',
    //     (message) => message.data.type == "getEntityData" &&
    //         vscode.postMessage({
    //             type: 'response',
    //             requestId: message.data.requestId,
    //             body: JSON.stringify(entity)
    //         }));
    function generateEntity() {
        Blockly.Events.disable();
        for (const n in entity.entity) {
            entityVars[ws.createVariable(n).id_] = n;
        }
        // rerender all variable fields
        ws.getAllBlocks().forEach((b) => b.inputList.forEach((c) => c.fieldRow.forEach((d) => d instanceof Blockly.FieldVariable && d.renderSelectedText_())));
        Blockly.Events.enable();

        if (entity.name == undefined)
            entityCode = "entity " + name + " is\n  port(" +
                Object.keys(entity.entity).map((n) =>
                    "\n    " + n + " : " + entity.entity[n][0] + " " + entity.entity[n][1]
                ).join(";") +
                "\n  );\nend entity;";
    }
    function generateAliases() {
        Blockly.Events.disable();
        for (const n in entity.aliases) {
            aliasVars[ws.createVariable(n).id_] = n;
        }
        // rerender all variable fields
        ws.getAllBlocks().forEach((b) => b.inputList.forEach((c) => c.fieldRow.forEach((d) => d instanceof Blockly.FieldVariable && d.renderSelectedText_())));
        Blockly.Events.enable();

        aliasesCode =
            Object.keys(entity.aliases).map((n) =>
                "\n  alias " + n + " is " + entity.aliases[n] + ";"
            ).join("");
    }
    function generateSignals() {
        Blockly.Events.disable();
        Object.keys(entity.signals).forEach(signal => ws.createVariable(signal));
        Blockly.Events.enable();
    }
    window.addEventListener('message',
        (message) => message.data.type == "contentUpdate" && (
            Blockly.Events.disable(),
            Blockly.serialization.workspaces.load(JSON.parse(message.data.body), ws, { registerUndo: false }),
            Blockly.Events.enable(),
            generateEntity(), generateAliases(), generateSignals
        ));
    window.addEventListener('message',
        async (message) => {
            if (message.data.type == "entity") {
                entity = JSON.parse(message.data.body);
                name = entity.name || message.data.file_name;
                entity.signals = entity.signals || {};
                entity.constants = entity.constants || {};
                entity.aliases = entity.aliases || {};

                // reset toolbox
                ws.updateToolbox(structuredClone(toolbox));

                if (entity.constants) {
                    Blockly.defineBlocksWithJsonArray([{
                        type: "constant",
                        message0: "%1",
                        args0: [
                            {
                                "type": "field_dropdown",
                                "name": "NAME",
                                "options": Object.keys(entity.constants).map((a) => [a, a])
                            },
                        ],
                        colour: 250,
                        "inputsInline": true,
                        "output": null
                    }]);
                    const tb = ws.getToolbox().toolboxDef_;
                    tb.contents = [
                        ...tb.contents,
                        {
                            kind: "category",
                            colour: 250,
                            contents: Object.keys(entity.constants).map((a) => ({
                                kind: "block",
                                type: "constant",
                                fields: {
                                    "NAME": a
                                }
                            })),
                            name: "Constants"
                        }
                    ];
                    ws.updateToolbox(tb);
                    constantsCode = Object.keys(entity.constants).map((n) =>
                        "\n  constant " + n + " : " + entity.constants[n][0] + " := " + entity.constants[n][1] + ";"
                    ).join("");
                }

                libraries = {
                    "ieee": {
                        "std_logic_1164": null
                    }
                };

                if (entity.libraries) {
                    function libraryDef(def) {
                        Blockly.defineBlocksWithJsonArray(def.map((a) => a.block));
                        def.forEach((a) => VHDLGenerator[a.block.type] = a.generator);
                        return def.map((a) => ({
                            kind: "block",
                            type: a.block.type
                        }));
                    }

                    libraries = mergeDeep(libraries, entity.libraries);
                    categories = [];

                    for (const a in libraries) {
                        let c = [];
                        let colour = Array.from(a).slice(0, 10).map((x) => parseInt(x, 36) - 10).reduce((x, y) => x + y, 0) * Math.min(a.length, 10) / 10;
                        for (const lib in libraries[a]) {
                            if (libraries[a][lib] === null)
                                continue;
                            else if (libraries[a][lib] === "builtin")
                                def = builtinLibs[a][lib];
                            else
                                def = eval("((colour, generator)=>" + await getFile(libraries[a][lib]) + ")")(colour, VHDLGenerator).blocks;
                            c.push({
                                kind: "category",
                                colour,
                                contents: libraryDef(def),
                                name: lib
                            });
                        }
                        if (c.length > 0)
                            categories.push({
                                kind: "category",
                                colour,
                                contents: c,
                                name: a
                            });
                    }

                    const tb = ws.getToolbox().toolboxDef_;
                    tb.contents = [
                        ...tb.contents,
                        {
                            'kind': 'sep',
                        },
                        ...categories
                    ];
                    ws.updateToolbox(tb);
                }

                vscode.postMessage({ type: 'requestUpdate' });

                librariesCode = Object.keys(libraries).map((l) => "library " + l + ";" + Object.keys(libraries[l]).map((p) => "\n  use " + l + "." + p + ".all;").join("")).join("\n");
            }
        }
    );

    ws.addChangeListener((e) => {
        if (e.isUiEvent) return;

        if (e.type == Blockly.Events.VAR_DELETE) {
            if (entity.signals[e.varName])
                delete entity.signals[e.varName];
            else if (entity.aliases[e.varName]) {
                delete entity.aliases[e.varName];
            } else if (entity.entity[e.varName]) {
                delete entity.entity[e.varName];
            }
            vscode.postMessage({
                type: "updateEntity",
                body: JSON.stringify(entity)
            });
        } else if (e.type == Blockly.Events.VAR_RENAME) {
            if (entity.signals[e.oldName]) {
                entity.signals[e.newName] = entity.signals[e.oldName];
                delete entity.signals[e.oldName];
            } else if (entity.aliases[e.varName]) {
                entity.aliases[e.newName] = entity.aliases[e.oldName];
                delete entity.aliases[e.oldName];
            } else if (entity.entity[e.varName]) {
                entity.entity[e.newName] = entity.entity[e.oldName];
                delete entity.entity[e.oldName];
            }
            vscode.postMessage({
                type: "updateEntity",
                body: JSON.stringify(entity)
            });
        }

        vscode.postMessage({
            type: "update",
            body: [JSON.stringify(Blockly.serialization.workspaces.save(ws)), VHDLGenerator.workspaceToCode(ws)]
        });
    });

    vscode.postMessage({ type: 'requestEntity' });
});
