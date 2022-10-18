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

	const toolbox = {
		'kind': 'categoryToolbox',
		'contents': [
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
						'kind': 'block',
						'type': 'logic_compare',
					},
					{
						'kind': 'block',
						'type': 'logic_operation',
					},
					{
						'kind': 'block',
						'type': 'logic_negate',
					},
					{
						'kind': 'block',
						'type': 'logic_boolean',
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
			{
				'kind': 'category',
				'name': 'Loops',
				'categorystyle': 'loop_category',
				'contents': [
					{
						'kind': 'block',
						'type': 'controls_repeat_ext',
						'inputs': {
							'TIMES': {
								'shadow': {
									'type': 'math_number',
									'fields': {
										'NUM': 10,
									},
								},
							},
						},
					},
					{
						'kind': 'block',
						'type': 'controls_flow_statements',
					},
				],
			},
			{
				'kind': 'category',
				'name': 'Math',
				'categorystyle': 'math_category',
				'contents': [
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
					{
						'kind': 'block',
						'type': 'math_single',
						'inputs': {
							'NUM': {
								'shadow': {
									'type': 'math_number',
									'fields': {
										'NUM': 9,
									},
								},
							},
						},
					},
					{
						'kind': 'block',
						'type': 'math_number_property',
						'inputs': {
							'NUMBER_TO_CHECK': {
								'shadow': {
									'type': 'math_number',
									'fields': {
										'NUM': 0,
									},
								},
							},
						},
					},
					{
						'kind': 'block',
						'type': 'list_index',
					},
					{
						'kind': 'block',
						'type': 'variables_set_index',
					},
					{
						'kind': 'block',
						'type': 'value_std_logic',
					},
					{
						'kind': 'block',
						'type': 'value_std_logic_vector',
					},
				],
			},
			{
				'kind': 'category',
				'name': 'Text',
				'categorystyle': 'text_category',
				'contents': [
					{
						'kind': 'block',
						'type': 'text',
					},
					{
						'kind': 'block',
						'type': 'text_multiline',
					},
					{
						'kind': 'label',
						'text': 'Input/Output:',
						'web-class': 'ioLabel',
					},
					{
						'kind': 'block',
						'type': 'text_print',
						'inputs': {
							'TEXT': {
								'shadow': {
									'type': 'text',
									'fields': {
										'TEXT': 'abc',
									},
								},
							},
						},
					},
					{
						'kind': 'block',
						'type': 'text_prompt_ext',
						'inputs': {
							'TEXT': {
								'shadow': {
									'type': 'text',
									'fields': {
										'TEXT': 'abc',
									},
								},
							},
						},
					},
				],
			},
			{
				'kind': 'sep',
			},
			{
				'kind': 'category',
				'name': 'Signals',
				'categorystyle': 'variable_category',
				'custom': 'VARIABLE',
			},
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
					}
				],
			},
			// {
			// 	'kind': 'category',
			// 	'name': 'Functions',
			// 	'categorystyle': 'procedure_category',
			// 	'custom': 'PROCEDURE',
			// },
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
					"variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
				}
			],
			"message1": "%1",
			"args1": [
				{ "type": "input_statement", "name": "body" }
			],
			"colour": 190,
			"mutator": "process_mutator",
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
			"type": "process_wait",
			"message0": "wait",
			"args0": [],
			"previousStatement": null,
			"nextStatement": null,
			"colour": 190
		},
		{
			"kind": "block",
			"type": "value_std_logic",
			"colour": "%{BKY_MATH_HUE}",
			"message0": "'%1'",
			"args0": [
				{
					"type": "field_number",
					"name": "INDEX",
					"min": 0,
					"max": 1,
					"precision": 1,
					"value": 0,
				}
			],
			"output": null,
		},
		{
			"kind": "block",
			"type": "value_std_logic_vector",
			"colour": "%{BKY_MATH_HUE}",
			"message0": "\"%1\"",
			"args0": [
				{
					"type": "field_number",
					"name": "INDEX",
					"min": 0,
					"precision": 1,
					"value": 0,
				}
			],
			"output": null,
		},
		{
			"kind": "block",
			"type": "list_index",
			"message0": "%1 %2",
			"colour": "%{BKY_MATH_HUE}",
			"args0": [
				{
					"type": "field_variable",
					"name": "LIST",
					"variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
				},
				{
					"type": "field_number",
					"name": "INDEX",
					"min": 0,
					"value": 0,
				}
			],
			"output": null,
		},
		{
			"type": "variables_set_index",
			"message0": "set %1 %2 to %3",
			"colour": "%{BKY_VARIABLES_HUE}",
			"args0": [
				{
					"type": "field_variable",
					"name": "VAR",
					"variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
				},
				{
					"type": "field_number",
					"name": "INDEX",
					"min": 0,
					"value": 0,
				},
				{
					"type": "input_value",    // This expects an input of any type
					"name": "VALUE"
				}
			],
		},
		{
			"kind": "block",
			"type": "logic_rising_edge",
			"message0": "rising_edge %1",
			"args0": [
				{
					"type": "field_variable",
					"name": "dep",
					"variable": "%{BKY_VARIABLES_DEFAULT_NAME}"
				}
			],
			"output": "Boolean",
			"style": "logic_blocks",
			"tooltip": "Returns number of letters in the provided text.",
			"helpUrl": "http://www.w3schools.com/jsref/jsref_length_string.asp"
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
			"nextStatement": null
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
			"nextStatement": "controls_when"
		}
	]);

	Blockly.Extensions.registerMutator("process_mutator", {
		updateShape_: function () {
			if (this.prevDepCount_ < this.depCount_) {
				console.log(this.prevDepCount_, this.depCount_);
				for (var i = this.prevDepCount_ + 1; i <= this.depCount_; i++) {
					console.log("+", i);
					this.inputList[0].appendField(new Blockly.FieldVariable("clk"), i.toString());
				}
			} else if (this.prevDepCount_ > this.depCount_) {
				for (var i = this.prevDepCount_; i > this.depCount_; i--) {
					this.inputList[0].removeField(i.toString());
				}
			}
			this.prevDepCount_ = this.depCount_;
		},

		saveExtraState: function () {
			return {
				'depCount': this.depCount_,
			};
		},
		loadExtraState: function (state) {
			this.depCount_ = state['depCount'];
			this.updateShape_();
		},

		// TODO: fix
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

			return topBlock;
		},
		compose: function (topBlock) {
			var itemBlock = topBlock.getInputTargetBlock('body');

			var connections = [];
			while (itemBlock && !itemBlock.isInsertionMarker()) {
				connections.push(itemBlock.valueConnection_);
				itemBlock = itemBlock.nextConnection?.targetBlock();
			}

			this.depCount_ = connections.length;
			this.updateShape_();

			for (var i = 0; i < this.itemCount_; i++) {
				Blockly.Mutator.reconnect(connections[i], this, 'ADD' + i);
			}
		},
	}, function () {
		this.prevDepCount_ = 1;
		this.depCount_ = 1;
		this.updateShape_();
	}, ["process_internal_item"]);

	Blockly.dialog.setAlert((m, cb) => (alert(m), cb()));
	Blockly.dialog.setPrompt((m, a, cb) => prompt(m).then((d) => cb(d ?? a)));
	Blockly.dialog.setConfirm((m, cb) => confirm(m).then((d) => cb(d ?? false)));

	const entityVars = {};

	(() => {
		Blockly.fieldRegistry.unregister("field_variable");
		Blockly.fieldRegistry.register("field_variable", class extends Blockly.FieldVariable {
			// TODO: Prevent deleting and renaming entity signals by removing the dropdown option for entities
			renderSelectedText_() {
				super.renderSelectedText_();
				if (["variables_get", "variables_set", "variables_set_index", "math_change"].indexOf(this.sourceBlock_.type) !== -1) {
					if (Object.keys(entityVars).indexOf(this.value_) !== -1) this.sourceBlock_.setColour(20);
					else this.sourceBlock_.setColour('%{BKY_VARIABLES_HUE}');
				}
			}
		});
	})();

	const theme = Blockly.Theme.defineTheme('dark', {
		'base': Blockly.Themes.Classic,
		'componentStyles': {
			'workspaceBackgroundColour': '#1e1e1e',
			'toolboxBackgroundColour': 'blackBackground',
			'toolboxForegroundColour': '#fff',
			'flyoutBackgroundColour': '#252526',
			'flyoutForegroundColour': '#ccc',
			'flyoutOpacity': 1,
			'scrollbarColour': '#797979',
			'insertionMarkerColour': '#fff',
			'insertionMarkerOpacity': 0.3,
			'scrollbarOpacity': 0.4,
			'cursorColour': '#d0d0d0',
			'blackBackground': '#333',
		},
	});

	const ws = Blockly.inject('root', {
		toolbox: toolbox,
		grid: {
			spacing: 25,
			length: 3,
			colour: '#ccc',
			snap: true,
		},
		theme,
		renderer: "zelos"
	});

	let entity = undefined;

	window.addEventListener('message',
		(message) => message.data.type == "getFileData" &&
			vscode.postMessage({
				type: 'response',
				requestId: message.data.requestId,
				body: ""
			}));
	window.addEventListener('message',
		(message) => message.data.type == "getScratchData" &&
			vscode.postMessage({
				type: 'response',
				requestId: message.data.requestId,
				body: JSON.stringify(Blockly.serialization.workspaces.save(ws))
			}));
	window.addEventListener('message',
		(message) => message.data.type == "contentUpdate" && (
			Blockly.Events.disable(),
			Blockly.serialization.workspaces.load(JSON.parse(message.data.body), ws, { registerUndo: false }),
			Blockly.Events.enable()
		));
	window.addEventListener('message',
		(message) => {
			if (message.data.type == "entity") {
				Blockly.Events.disable();
				entity = JSON.parse(message.data.body);
				for (const n in entity.entity) {
					entityVars[ws.createVariable(n).id_] = n;
				}
				Blockly.Events.enable();
				vscode.postMessage({ type: 'requestUpdate' });
			}
		}
	);

	ws.addChangeListener((e) => {
		if (e.isUiEvent) return;

		vscode.postMessage({
			type: "update",
			body: JSON.stringify(Blockly.serialization.workspaces.save(ws))
		});
	});

	vscode.postMessage({ type: 'requestUpdate' });
	vscode.postMessage({ type: 'requestEntity' });
});
