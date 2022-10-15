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
					}
				],
			},
			{
				'kind': 'category',
				'name': 'Functions',
				'categorystyle': 'procedure_category',
				'custom': 'PROCEDURE',
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
					"name": "hello",
					"variable": "item"
				}
			],
			"message1": "%1",
			"args1": [
				{ "type": "input_statement", "name": "body" }
			],
			"colour": 190,
			"tooltip": "Returns number of letters in the provided text.",
			"helpUrl": "http://www.w3schools.com/jsref/jsref_length_string.asp"
		},
		{
			"kind": "block",
			"type": "logic_rising_edge",
			"message0": "rising_edge %1",
			"args0": [
				{
					"type": "field_variable",
					"name": "hello",
					"variable": "item"
				}
			],
			"output": "Boolean",
			"style": "logic_blocks",
			"tooltip": "Returns number of letters in the provided text.",
			"helpUrl": "http://www.w3schools.com/jsref/jsref_length_string.asp"
		}
	]);

	Blockly.alert = (m, cb) => (alert(m), cb());
	Blockly.prompt = (m, a, cb) => prompt(m).then((d) => cb(d ?? a));
	Blockly.confirm = (m, cb) => confirm(m).then((d) => cb(d ?? false));


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

	ws.addChangeListener((e) => {
		if (e.isUiEvent) return;

		vscode.postMessage({
			type: "update",
			body: JSON.stringify(Blockly.serialization.workspaces.save(ws))
		})
	});

	vscode.postMessage({ type: 'requestUpdate' });
});
