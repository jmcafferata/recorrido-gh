const { app, BrowserWindow, session } = require('electron');
const path = require('path');
const { pathToFileURL } = require('url');

/**
 * Creates the main application window and loads the bundled web content.
 */
function createMainWindow() {
	// Optional runtime flags for debugging when packaged
	// Enable remote debugging and verbose logging if requested
	if (process.env.REMOTE_DEBUG || process.argv.includes('--remote-debug')) {
		app.commandLine.appendSwitch('remote-debugging-port', '9222');
		app.commandLine.appendSwitch('enable-logging');
		app.commandLine.appendSwitch('v', '1');
	}

	// Allow disabling GPU to test black screen due to drivers
	if (process.env.DISABLE_GPU === '1' || process.argv.includes('--disable-gpu')) {
		app.disableHardwareAcceleration();
	}
	const mainWindow = new BrowserWindow({
		width: 1280,
		height: 720,
		backgroundColor: '#000000',
		show: false,
		autoHideMenuBar: true,
		webPreferences: {
			// Keep sandboxed renderer; app is browser-only
			contextIsolation: true,
			sandbox: true,
			devTools: true
		}
	});

	mainWindow.once('ready-to-show', () => {
		mainWindow.show();
	});

	mainWindow.loadFile(path.join(__dirname, 'game', 'index.html'));

	// Help debugging in packaged builds: toggle with flag
	const shouldOpenDevTools =
		!app.isPackaged ||
		process.env.OPEN_DEVTOOLS === '1' ||
		process.argv.includes('--devtools');

	if (shouldOpenDevTools) {
		mainWindow.webContents.openDevTools({ mode: 'detach' });
	}

	// Keyboard shortcuts to open devtools in packaged app
	mainWindow.webContents.on('before-input-event', (event, input) => {
		if (input.type === 'keyDown') {
			const isToggle = (input.key?.toLowerCase?.() === 'i' && input.control && input.shift) || input.code === 'F12';
			if (isToggle) {
				mainWindow.webContents.toggleDevTools();
				event.preventDefault();
			}
		}
	});

	// Surface renderer crashes and load failures
	mainWindow.webContents.on('render-process-gone', (_e, details) => {
		console.error('[renderer gone]', details);
	});
	mainWindow.webContents.on('did-fail-load', (_e, errorCode, errorDescription, validatedURL) => {
		console.error('[did-fail-load]', { errorCode, errorDescription, validatedURL });
	});

	if (!app.isPackaged) {
		mainWindow.webContents.openDevTools({ mode: 'detach' });
	}
}

app.whenReady().then(() => {
	// Rewrite absolute /game-assets/... and /assets/... file URLs to the app's bundled folders
	try {
		const baseGameAssetsPath = path.join(__dirname, 'game-assets');
		const baseAssetsPath = path.join(__dirname, 'assets');
		const filter = { urls: ['file://*/*'] };
		session.defaultSession.webRequest.onBeforeRequest(filter, (details, callback) => {
			try {
				const reqUrl = new URL(details.url);
				// On Windows, pathname looks like /C:/... ; we want to find /game-assets/ or /assets/
				let idx = reqUrl.pathname.indexOf('/game-assets/');
				if (idx !== -1) {
					const rest = decodeURIComponent(reqUrl.pathname.slice(idx + '/game-assets/'.length));
					const targetPath = path.join(baseGameAssetsPath, rest);
					const redirectURL = pathToFileURL(targetPath).toString();
					return callback({ redirectURL });
				}
				idx = reqUrl.pathname.indexOf('/assets/');
				if (idx !== -1) {
					const rest = decodeURIComponent(reqUrl.pathname.slice(idx + '/assets/'.length));
					const targetPath = path.join(baseAssetsPath, rest);
					const redirectURL = pathToFileURL(targetPath).toString();
					return callback({ redirectURL });
				}
			} catch (err) {
				// fallthrough
			}
			callback({});
		});
	} catch (err) {
		console.error('[assets rewrite] failed to install handler', err);
	}

	createMainWindow();

	app.on('activate', () => {
		if (BrowserWindow.getAllWindows().length === 0) {
			createMainWindow();
		}
	});
});

app.on('window-all-closed', () => {
	if (process.platform !== 'darwin') {
		app.quit();
	}
});
