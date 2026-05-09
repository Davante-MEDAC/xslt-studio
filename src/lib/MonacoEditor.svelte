<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import type * as Monaco from 'monaco-editor';

	interface Props {
		value: string;
		language?: string;
		onChange?: (val: string) => void;
	}

	let { value = $bindable(''), language = 'xml', onChange }: Props = $props();

	let container: HTMLDivElement;
	let editor: Monaco.editor.IStandaloneCodeEditor | null = null;
	let monaco: typeof Monaco | null = null;
	let ignoreChange = false;

	onMount(async () => {
		const m = await import('monaco-editor');
		monaco = m;

		// Configure monaco workers via CDN
		(self as any).MonacoEnvironment = {
			getWorker(_: string, label: string) {
				const getWorkerModule = (moduleUrl: string, label: string) => {
					return new Worker(
						new URL(moduleUrl, import.meta.url),
						{ type: 'module', name: label }
					);
				};
				if (label === 'xml') {
					return getWorkerModule(
						'../../../node_modules/monaco-editor/esm/vs/language/json/json.worker?worker',
						label
					);
				}
				return getWorkerModule(
					'../../../node_modules/monaco-editor/esm/vs/editor/editor.worker?worker',
					label
				);
			}
		};

		editor = m.editor.create(container, {
			value,
			language,
			theme: 'vs-dark',
			fontSize: 13,
			minimap: { enabled: false },
			scrollBeyondLastLine: false,
			automaticLayout: true,
			wordWrap: 'on',
			lineNumbers: 'on',
			renderLineHighlight: 'line',
			padding: { top: 8, bottom: 8 }
		});

		editor.onDidChangeModelContent(() => {
			if (ignoreChange) return;
			const val = editor!.getValue();
			value = val;
			onChange?.(val);
		});
	});

	$effect(() => {
		if (editor && editor.getValue() !== value) {
			ignoreChange = true;
			editor.setValue(value);
			ignoreChange = false;
		}
	});

	onDestroy(() => {
		editor?.dispose();
	});
</script>

<div bind:this={container} class="w-full h-full"></div>
