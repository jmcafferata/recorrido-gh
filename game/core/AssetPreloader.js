import { AssetLoader } from './AssetLoader.js';

export class AssetPreloader {
    constructor() {
        this.assetManifest = {
            // Modelos 3D
            models: [
                '/game-assets/recorrido/escena01.glb',
                '/game-assets/recorrido/escena02.glb',
                '/game-assets/recorrido/escena03.glb',
                '/game-assets/recorrido/escena04.glb',
                '/game-assets/recorrido/escena05.glb',
                '/game-assets/recorrido/escena06.glb',
                '/game-assets/recorrido/recorrido01.glb',
                '/game-assets/recorrido/butter_flying.glb',
                '/game-assets/recorrido/paneles/inventario.glb',
                '/assets/isla.glb',
                '/assets/island.glb'
            ],
            
            // Videos principales
            videos: [
                '/assets/island.mp4',
                '/assets/island.webm',
                '/assets/island_1.webm',
                '/assets/island_2.webm',
                '/assets/mapa_gigante.webm',
                '/assets/web-bgs/web-bg01.webm',
                '/assets/web-bgs/web-bg02.webm',
                '/assets/web-bgs/web-bg03.webm',
                '/game-assets/menu/cinematicas/logo_naranja.webm',
                '/game-assets/menu/logo_naranja_alpha.webm',
                '/game-assets/recorrido/cinematicas/carpa_flota.webm',
                '/game-assets/transiciones/lab-a-subacua.webm',
                '/game-assets/transiciones/secuencia_inicio_recorrido1.webm',
                '/game-assets/transiciones/secuencia_inicio_recorrido2.webm'
            ],

            // Videos de criaturas (los más importantes para la gameplay)
            criaturaVideos: [
                '/game-assets/recorrido/criaturas/camalote/camalote_data.webm',
                '/game-assets/recorrido/criaturas/camalote/camalote_glitch.webm',
                '/game-assets/recorrido/criaturas/ceibo/ceibo_data.webm',
                '/game-assets/recorrido/criaturas/ceibo/ceibo_glitch.webm',
                '/game-assets/recorrido/criaturas/clavel/clavel_data.webm',
                '/game-assets/recorrido/criaturas/clavel/clavel_glitch.webm',
                '/game-assets/recorrido/criaturas/efedra/efedra_data.webm',
                '/game-assets/recorrido/criaturas/efedra/efedra_glitch.webm',
                '/game-assets/recorrido/criaturas/espinillo/espinillo_data.webm',
                '/game-assets/recorrido/criaturas/espinillo/espinillo_glitch.webm',
                '/game-assets/recorrido/criaturas/helecho/helecho_data.webm',
                '/game-assets/recorrido/criaturas/helecho/helecho_glitch.webm',
                '/game-assets/recorrido/criaturas/ombu/ombu_data.webm',
                '/game-assets/recorrido/criaturas/ombu/ombu_glitch.webm',
                '/game-assets/recorrido/criaturas/salvia/salvia_data.webm',
                '/game-assets/recorrido/criaturas/salvia/salvia_glitch.webm',
                '/game-assets/recorrido/criaturas/tembetari/tembetari_data.webm',
                '/game-assets/recorrido/criaturas/tembetari/tembetari_glitch.webm',
                '/game-assets/recorrido/criaturas/tortuga_de_agua/tortuga_de_agua_data.webm',
                '/game-assets/recorrido/criaturas/tortuga_de_agua/tortuga_de_agua_glitch.webm',
                '/game-assets/recorrido/criaturas/viraro/viraro_data.webm',
                '/game-assets/recorrido/criaturas/viraro/viraro_glitch.webm',
                '/game-assets/recorrido/criaturas/yarara/yarara_data.webm',
                '/game-assets/recorrido/criaturas/yarara/yarara_glitch.webm'
            ],

            // Audio esencial
            audio: [
                '/game-assets/menu/cinematicas/logo delta mas vf2.mp3',
                '/game-assets/recorrido/monte.mp3',
                '/game-assets/recorrido/musica.mp3',
                '/game-assets/recorrido/gracias_a_la_vida.m4a',
                '/game-assets/recorrido/sonido/Transicion delta mas.mp3',
                '/game-assets/recorrido/sonido/metadata_popup.mp3',
                '/game-assets/recorrido/sonido/metadata_cierre.mp3'
            ],

            // Imágenes críticas
            images: [
                '/game-assets/recorrido/mapa01.png',
                '/game-assets/recorrido/paneles/mapa_fondo.png',
                '/game-assets/recorrido/paneles/panel mapa.png',
                '/game-assets/recorrido/paneles/paneles_entero.png',
                '/game-assets/recorrido/paneles/paneles_vacio.png',
                '/game-assets/recorrido/recorrido01.jpg',
                '/game-assets/recorrido/recorrido02.jpg',
                '/game-assets/recorrido/recorrido03.jpg',
                '/game-assets/recorrido/recorrido04.jpg',
                '/game-assets/recorrido/recorrido05.jpg',
                '/game-assets/recorrido/recorrido06.jpg',
                '/game-assets/recorrido/criaturas/camalote/camalote_rastro.png',
                '/game-assets/recorrido/criaturas/ceibo/ceibo_rastro.png',
                '/game-assets/recorrido/criaturas/clavel/clavel_rastro.png',
                '/game-assets/recorrido/criaturas/clavel/clavel_limpio.png',
                '/game-assets/recorrido/criaturas/efedra/efedra_rastro.png',
                '/game-assets/recorrido/criaturas/efedra/efedra_foto.png',
                '/game-assets/recorrido/criaturas/espinillo/espinillo_rastro.png',
                '/game-assets/recorrido/criaturas/helecho/helecho_rastro.png',
                '/game-assets/recorrido/criaturas/ombu/ombu_rastro.png',
                '/game-assets/recorrido/criaturas/salvia/salvia_rastro.png',
                '/game-assets/recorrido/criaturas/tembetari/tembetari_rastro.png',
                '/game-assets/recorrido/criaturas/tortuga_de_agua/tortuga_de_agua_rastro.png',
                '/game-assets/recorrido/criaturas/viraro/viraro_rastro.png',
                '/game-assets/recorrido/interfaz/cursor.png',
                '/game-assets/recorrido/flecha.png'
            ]
        };

        this.loadedAssets = new Map();
        this.loadingPromises = new Map();
    }

    getAllAssets() {
        return [
            ...this.assetManifest.models,
            ...this.assetManifest.videos,
            ...this.assetManifest.criaturaVideos,
            ...this.assetManifest.audio,
            ...this.assetManifest.images
        ];
    }

    async preloadAll(onProgress) {
        const allAssets = this.getAllAssets();
        const totalAssets = allAssets.length;
        let loadedCount = 0;

        const loadPromises = allAssets.map(async (assetPath) => {
            try {
                const asset = await this.loadAsset(assetPath);
                this.loadedAssets.set(assetPath, asset);
                loadedCount++;
                
                if (onProgress) {
                    const fileName = assetPath.split('/').pop();
                    onProgress(loadedCount, fileName);
                }
                
                return asset;
            } catch (error) {
                console.warn(`Failed to load asset: ${assetPath}`, error);
                loadedCount++;
                
                if (onProgress) {
                    const fileName = assetPath.split('/').pop();
                    onProgress(loadedCount, `Error: ${fileName}`);
                }
                
                return null;
            }
        });

        await Promise.allSettled(loadPromises);
        return this.loadedAssets;
    }

    async loadAsset(assetPath) {
        // Si ya está cargado, devolverlo
        if (this.loadedAssets.has(assetPath)) {
            return this.loadedAssets.get(assetPath);
        }

        // Si ya está cargándose, esperar la promesa existente
        if (this.loadingPromises.has(assetPath)) {
            return this.loadingPromises.get(assetPath);
        }

        // Determinar el tipo de asset y cargar
        const extension = assetPath.split('.').pop().toLowerCase();
        let loadPromise;

        switch (extension) {
            case 'glb':
            case 'gltf':
                loadPromise = AssetLoader.gltf(assetPath);
                break;
            
            case 'webm':
            case 'mp4':
                loadPromise = this.loadVideo(assetPath);
                break;
            
            case 'mp3':
            case 'm4a':
            case 'wav':
                loadPromise = this.loadAudio(assetPath);
                break;
            
            case 'png':
            case 'jpg':
            case 'jpeg':
                loadPromise = AssetLoader.texture(assetPath);
                break;
            
            default:
                throw new Error(`Unsupported asset type: ${extension}`);
        }

        this.loadingPromises.set(assetPath, loadPromise);
        
        try {
            const asset = await loadPromise;
            this.loadedAssets.set(assetPath, asset);
            this.loadingPromises.delete(assetPath);
            return asset;
        } catch (error) {
            this.loadingPromises.delete(assetPath);
            throw error;
        }
    }

    loadVideo(url) {
        return new Promise((resolve, reject) => {
            const video = document.createElement('video');
            video.preload = 'auto';
            video.muted = true; // Para evitar problemas de autoplay
            
            const handleLoad = () => {
                video.removeEventListener('canplaythrough', handleLoad);
                video.removeEventListener('error', handleError);
                resolve(video);
            };
            
            const handleError = () => {
                video.removeEventListener('canplaythrough', handleLoad);
                video.removeEventListener('error', handleError);
                reject(new Error(`Failed to load video: ${url}`));
            };
            
            video.addEventListener('canplaythrough', handleLoad);
            video.addEventListener('error', handleError);
            video.src = url;
        });
    }

    loadAudio(url) {
        return new Promise((resolve, reject) => {
            const audio = new Audio();
            audio.preload = 'auto';
            
            const handleLoad = () => {
                audio.removeEventListener('canplaythrough', handleLoad);
                audio.removeEventListener('error', handleError);
                resolve(audio);
            };
            
            const handleError = () => {
                audio.removeEventListener('canplaythrough', handleLoad);
                audio.removeEventListener('error', handleError);
                reject(new Error(`Failed to load audio: ${url}`));
            };
            
            audio.addEventListener('canplaythrough', handleLoad);
            audio.addEventListener('error', handleError);
            audio.src = url;
        });
    }

    getAsset(assetPath) {
        return this.loadedAssets.get(assetPath);
    }

    isLoaded(assetPath) {
        return this.loadedAssets.has(assetPath);
    }

    clearCache() {
        this.loadedAssets.clear();
        this.loadingPromises.clear();
    }
}