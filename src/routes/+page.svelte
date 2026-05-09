<script lang="ts">
	import { browser } from '$app/environment';
	import { onMount } from 'svelte';

	let MonacoEditor: any = $state(null);

	// State
	let xmlValue = $state('');
	let xsltValue = $state('');
	let outputMode: 'rendered' | 'raw' = $state('rendered');
	let status = $state<{ msg: string; ok: boolean }>({ msg: 'Ready', ok: true });
	let previewSrc = $state('');
	let rawOutput = $state('');
	let samples: { id: string; label: string }[] = $state([]);
	let selectedSample = $state('');
	let loadingSample = $state(false);

	// Load Monaco lazily (browser only)
	onMount(async () => {
		MonacoEditor = (await import('$lib/MonacoEditor.svelte')).default;
		const res = await fetch('/xml/manifest.json');
		samples = await res.json();
		if (samples.length) {
			selectedSample = samples[0].id;
			await loadSample(samples[0].id);
		}
	});

	async function loadSample(id: string) {
		loadingSample = true;
		try {
			const [xmlRes, xsltRes] = await Promise.all([
				fetch(`/xml/${id}/data.xml`),
				fetch(`/xml/${id}/transform.xslt`)
			]);
			xmlValue = await xmlRes.text();
			xsltValue = await xsltRes.text();
			setStatus('Sample loaded', true);
			transform();
		} catch {
			setStatus('Failed to load sample', false);
		} finally {
			loadingSample = false;
		}
	}

	function onSampleChange(e: Event) {
		const id = (e.target as HTMLSelectElement).value;
		selectedSample = id;
		loadSample(id);
	}

	function setStatus(msg: string, ok: boolean) {
		status = { msg, ok };
	}

	function transform() {
		const parser = new DOMParser();
		const serializer = new XMLSerializer();
		setStatus('Transforming…', true);
		let xmlDoc: Document, xsltDoc: Document;
		try {
			xmlDoc = parser.parseFromString(xmlValue, 'application/xml');
			if (xmlDoc.getElementsByTagName('parsererror').length)
				throw new Error('XML parse error');
		} catch {
			setStatus('XML parse error — check XML pane', false);
			return;
		}
		try {
			xsltDoc = parser.parseFromString(xsltValue, 'application/xml');
			if (xsltDoc.getElementsByTagName('parsererror').length)
				throw new Error('XSLT parse error');
		} catch {
			setStatus('XSLT parse error — check XSLT pane', false);
			return;
		}
		try {
			const proc = new XSLTProcessor();
			proc.importStylesheet(xsltDoc);
			const result = proc.transformToDocument(xmlDoc);
			const str = serializer.serializeToString(result);
			rawOutput = str;

			const blob = new Blob([str], { type: 'text/html' });
			const url = URL.createObjectURL(blob);
			if (previewSrc) URL.revokeObjectURL(previewSrc);
			previewSrc = url;

			setStatus('Transform successful', true);
		} catch (err: any) {
			setStatus('Transform error: ' + (err.message ?? String(err)), false);
		}
	}

	function download() {
		if (!rawOutput) return;
		const blob = new Blob([rawOutput], { type: 'text/html' });
		const a = document.createElement('a');
		a.href = URL.createObjectURL(blob);
		a.download = 'result.html';
		a.click();
		setTimeout(() => URL.revokeObjectURL(a.href), 5000);
	}
</script>

<svelte:head>
	<title>XSLT Studio</title>
</svelte:head>

<div class="flex flex-col h-screen bg-gray-950 text-gray-100 overflow-hidden">
	<!-- Header -->
	<header class="flex items-center gap-3 px-4 py-2.5 bg-gray-900 border-b border-gray-800 shrink-0">
		<div class="flex items-center gap-2">
			<svg class="w-6 h-6 text-violet-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
				<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5"/>
			</svg>
			<span class="font-semibold text-white tracking-tight text-sm">XSLT Studio</span>
		</div>

		<!-- Sample picker -->
		<div class="flex items-center gap-2 ml-2">
			<label for="sample-select" class="text-xs text-gray-400 uppercase tracking-wider">Sample</label>
			<select
				id="sample-select"
				class="bg-gray-800 border border-gray-700 text-sm text-gray-200 rounded-md px-2.5 py-1.5 focus:outline-none focus:ring-2 focus:ring-violet-500 cursor-pointer"
				value={selectedSample}
				onchange={onSampleChange}
				disabled={loadingSample}
			>
				{#each samples as s}
					<option value={s.id}>{s.label}</option>
				{/each}
			</select>
		</div>

		<div class="ml-auto flex items-center gap-2">
			<!-- Output toggle -->
			<div class="flex items-center bg-gray-800 rounded-lg p-0.5 border border-gray-700">
				<button
					class="px-3 py-1 text-xs rounded-md transition-colors {outputMode === 'rendered' ? 'bg-violet-600 text-white' : 'text-gray-400 hover:text-gray-200'}"
					onclick={() => (outputMode = 'rendered')}
				>Rendered</button>
				<button
					class="px-3 py-1 text-xs rounded-md transition-colors {outputMode === 'raw' ? 'bg-violet-600 text-white' : 'text-gray-400 hover:text-gray-200'}"
					onclick={() => (outputMode = 'raw')}
				>Raw XML</button>
			</div>

			<button
				onclick={transform}
				class="flex items-center gap-1.5 bg-violet-600 hover:bg-violet-500 active:bg-violet-700 text-white text-sm px-3.5 py-1.5 rounded-md transition-colors font-medium"
			>
				<svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
					<path stroke-linecap="round" stroke-linejoin="round" d="m5.25 4.5 14.25 7.5-14.25 7.5V4.5z"/>
				</svg>
				Transform
			</button>

			<button
				onclick={download}
				disabled={!rawOutput}
				class="flex items-center gap-1.5 bg-gray-800 hover:bg-gray-700 disabled:opacity-40 disabled:cursor-not-allowed border border-gray-700 text-sm px-3 py-1.5 rounded-md transition-colors"
			>
				<svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
					<path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3"/>
				</svg>
				Download
			</button>
		</div>
	</header>

	<!-- Status bar -->
	<div class="flex items-center px-4 py-1 bg-gray-900 border-b border-gray-800 shrink-0">
		<span class="text-xs {status.ok ? 'text-emerald-400' : 'text-red-400'} flex items-center gap-1.5">
			<span class="inline-block w-1.5 h-1.5 rounded-full {status.ok ? 'bg-emerald-400' : 'bg-red-400'}"></span>
			{status.msg}
		</span>
	</div>

	<!-- Three-pane layout -->
	<main class="flex flex-1 min-h-0 gap-px bg-gray-800">
		<!-- XML Pane -->
		<section class="flex flex-col flex-1 min-w-0 bg-gray-950">
			<div class="flex items-center gap-2 px-3 py-2 bg-gray-900 border-b border-gray-800 shrink-0">
				<span class="text-xs font-semibold text-gray-400 uppercase tracking-wider">XML</span>
				<span class="ml-auto text-xs text-gray-600">Input document</span>
			</div>
			<div class="flex-1 min-h-0 overflow-hidden">
				{#if MonacoEditor && browser}
					<MonacoEditor bind:value={xmlValue} language="xml" />
				{:else}
					<div class="flex items-center justify-center h-full text-gray-600 text-sm">Loading editor…</div>
				{/if}
			</div>
		</section>

		<!-- XSLT Pane -->
		<section class="flex flex-col flex-1 min-w-0 bg-gray-950">
			<div class="flex items-center gap-2 px-3 py-2 bg-gray-900 border-b border-gray-800 shrink-0">
				<span class="text-xs font-semibold text-gray-400 uppercase tracking-wider">XSLT</span>
				<span class="ml-auto text-xs text-gray-600">Stylesheet</span>
			</div>
			<div class="flex-1 min-h-0 overflow-hidden">
				{#if MonacoEditor && browser}
					<MonacoEditor bind:value={xsltValue} language="xml" />
				{:else}
					<div class="flex items-center justify-center h-full text-gray-600 text-sm">Loading editor…</div>
				{/if}
			</div>
		</section>

		<!-- Preview Pane -->
		<section class="flex flex-col flex-1 min-w-0 bg-gray-950">
			<div class="flex items-center gap-2 px-3 py-2 bg-gray-900 border-b border-gray-800 shrink-0">
				<span class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Preview</span>
				<span class="ml-auto text-xs text-gray-600">{outputMode === 'rendered' ? 'Rendered HTML' : 'Raw output'}</span>
			</div>
			<div class="flex-1 min-h-0 overflow-hidden relative">
				{#if outputMode === 'rendered'}
					{#if previewSrc}
						<iframe
							src={previewSrc}
							title="XSLT output preview"
							class="absolute inset-0 w-full h-full border-0 bg-white"
							sandbox="allow-same-origin allow-scripts"
						></iframe>
					{:else}
						<div class="flex flex-col items-center justify-center h-full text-gray-600 gap-2">
							<svg class="w-10 h-10 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909M3 21h18M3 3h18"/>
							</svg>
							<span class="text-sm">Run Transform to see preview</span>
						</div>
					{/if}
				{:else}
					<pre class="absolute inset-0 overflow-auto p-4 text-xs text-green-300 font-mono leading-relaxed whitespace-pre-wrap bg-gray-950">{rawOutput || 'No output yet — run Transform first.'}</pre>
				{/if}
			</div>
		</section>
	</main>
</div>
