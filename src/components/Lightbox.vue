<template>
    <div v-if="show" class="lightbox">
      <div class="overlay" @click="close"></div>
      <div class="lightbox-content">
        <button class="close" @click="close">&times;</button>
        <img :src="currentImage.src" class="img-fluid" @touchstart="startTouch" @touchmove="moveTouch" @touchend="handleGesture"/>
        <button class="prev" @click="prevImage">&laquo;</button>
        <button class="next" @click="nextImage">&raquo;</button>
      </div>
    </div>
  </template>
  
  <script setup>
  import { computed, defineProps, defineEmits, onMounted, onBeforeUnmount } from 'vue';
  
  const props = defineProps({
    images: Array,
    currentImageIndex: Number,
  });
  
  const emit = defineEmits(['close', 'update:currentImageIndex']);
  
  const show = computed(() => props.currentImageIndex !== null);
  const currentImage = computed(() => props.images[props.currentImageIndex] || {});
  
  function close() {
    emit('close');
  }
  
  function prevImage() {
    if (props.currentImageIndex > 0) {
      emit('update:currentImageIndex', props.currentImageIndex - 1);
    }
  }
  
  function nextImage() {
    if (props.currentImageIndex < props.images.length - 1) {
      emit('update:currentImageIndex', props.currentImageIndex + 1);
    }
  }
  
  function handleKeydown(event) {
    if (event.key === 'ArrowLeft') {
      prevImage();
    } else if (event.key === 'ArrowRight') {
      nextImage();
    } else if (event.key === 'Escape') {
      close();
    }
  }
  
  let touchStartX = 0;
  let touchEndX = 0;
  
  function startTouch(event) {
    touchStartX = event.touches[0].clientX;
  }
  
  function moveTouch(event) {
    touchEndX = event.touches[0].clientX;
  }
  
  function handleGesture() {
    if (touchEndX < touchStartX) {
      nextImage();
    }
    if (touchEndX > touchStartX) {
      prevImage();
    }
    // Reset touch positions
    touchStartX = 0;
    touchEndX = 0;
  }
  
  onMounted(() => {
    window.addEventListener('keydown', handleKeydown);
  });
  
  onBeforeUnmount(() => {
    window.removeEventListener('keydown', handleKeydown);
  });
  </script>
  
  <style scoped>
  .lightbox {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 1050;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  
  .overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.7);
  }
  
  .lightbox-content {
    position: relative;
    max-width: 90%;
    max-height: 90%;
    background: #fff;
    padding: 20px;
    text-align: center;
  }
  
  .close {
    position: absolute;
    top: 10px;
    right: 10px;
    background: none;
    border: none;
    font-size: 30px;
    cursor: pointer;
  }
  
  .prev,
  .next {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    font-size: 30px;
    cursor: pointer;
  }
  
  .prev {
    left: -5px;
  }
  
  .next {
    right: -5px;
  }
  
  .img-fluid {
    max-width: 100%;
    max-height: 70vh;
  }
  </style>
  