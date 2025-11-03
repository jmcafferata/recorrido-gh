import * as THREE from 'three';

export const AssetLoader = {
  texture(url) {
    // Check if asset is preloaded
    if (window.assetPreloader && window.assetPreloader.isLoaded(url)) {
      const preloadedTexture = window.assetPreloader.getAsset(url);
      if (preloadedTexture) {
        return Promise.resolve(preloadedTexture);
      }
    }
    
    return new Promise((resolve, reject) => {
      const loader = new THREE.TextureLoader();
      loader.load(url, (tex) => { 
        tex.colorSpace = THREE.SRGBColorSpace; 
        resolve(tex); 
      }, undefined, reject);
    });
  },
  
  audio(url) {
    // Check if asset is preloaded
    if (window.assetPreloader && window.assetPreloader.isLoaded(url)) {
      const preloadedAudio = window.assetPreloader.getAsset(url);
      if (preloadedAudio) {
        return preloadedAudio.cloneNode(); // Clone to allow multiple instances
      }
    }
    
    // Fallback to original implementation
    const a = new Audio(url);
    a.preload = 'auto';
    return a;
  },
  
  audioBuffer(url) {
    return new Promise(async (resolve, reject) => {
      const { AudioLoader } = await import('three');
      const loader = new AudioLoader();
      loader.load(url, resolve, undefined, reject);
    });
  },
  
  async gltf(url) {
    // Check if asset is preloaded
    if (window.assetPreloader && window.assetPreloader.isLoaded(url)) {
      const preloadedGltf = window.assetPreloader.getAsset(url);
      if (preloadedGltf) {
        return preloadedGltf;
      }
    }
    
    // Fallback to original implementation
    const { GLTFLoader } = await import('three/addons/loaders/GLTFLoader.js');
    const loader = new GLTFLoader();
    return new Promise((resolve, reject) => loader.load(url, resolve, undefined, reject));
  },
  
  video(url) {
    // Check if asset is preloaded
    if (window.assetPreloader && window.assetPreloader.isLoaded(url)) {
      const preloadedVideo = window.assetPreloader.getAsset(url);
      if (preloadedVideo) {
        return Promise.resolve(preloadedVideo.cloneNode()); // Clone to allow multiple instances
      }
    }
    
    // Fallback to original implementation
    return new Promise((resolve, reject) => {
      const video = document.createElement('video');
      video.preload = 'auto';
      video.muted = true;
      
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
};