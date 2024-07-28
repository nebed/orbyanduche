<template>
    <div class="container">
      <h1 class="blacksword-text text-center mb-4 display-3">Gallery</h1>
      <div class="masonry">
        <div
          v-for="(image, index) in images"
          :key="index"
          class="masonry-item mb-3"
        >
          <a @click="openLightbox(index)">
            <img
              v-lazy="image.src"
              :alt="image.title"
              class="img-fluid"
              :title="image.title"
              width="200"
            />
          </a>
        </div>
      </div>
      <Lightbox :images="images" :current-image-index="currentImageIndex" @close="closeLightbox" @update:currentImageIndex="handleUpdateIndex" />
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  import Lightbox from '../components/Lightbox.vue';
  
  const images = ref([
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_1.jpg', title: '31-5-2024 1' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_2.jpg', title: '31-5-2024 2' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_3.jpg', title: '31-5-2024 3' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_4.jpg', title: '31-5-2024 4' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_5.jpg', title: '31-5-2024 5' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_6.jpg', title: '31-5-2024 6' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_7.jpg', title: '31-5-2024 7' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/31-5-2024_8.jpg', title: '31-5-2024 8' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/5-5-2024.jpg', title: '5-5-2024' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/4-3-2024_1.jpg', title: '4-3-2024 1' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/4-3-2024_2.jpg', title: '4-3-2024 2' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/4-3-2024_3.jpg', title: '4-3-2024 3' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/4-3-2024_4.jpg', title: '4-3-2024 4' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/17-12-2023_1.jpg', title: '17-12-2023 1' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/17-12-2023_2.jpg', title: '17-12-2023 2' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/17-12-2023_3.jpg', title: '17-12-2023 3' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/17-12-2023_4.jpg', title: '17-12-2023 4' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/17-12-2023_5.jpg', title: '17-12-2023 5' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/14-7-2023.jpg', title: '14-7-2023' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/8-7-2023.jpg', title: '8-7-2023' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/29-12-2022.jpg', title: '29-12-2022' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/9-7-2022_1.jpg', title: '9-7-2022 1' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/9-7-2022_2.jpg', title: '9-7-2022 2' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/8-7-2022.jpg', title: '8-7-2022' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/18-6-2022.jpg', title: '18-6-2022' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/1-5-2022.jpg', title: '1-5-2022'},
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/4-7-2021.jpg', title: '4-7-2021' },
    { src: 'https://storage.googleapis.com/orbyanduche/gallery/13-3-2021.jpg', title: '13-3-2021' },
  ]);

const currentImageIndex = ref(null);
  
  function openLightbox(index) {
    currentImageIndex.value = index;
  }

  function handleUpdateIndex(newIndex) {
    currentImageIndex.value = newIndex;
  }
  
  function closeLightbox() {
    currentImageIndex.value = null;
  }
  </script>
  
  <style scoped>
  .masonry {
    column-count: 3;
    column-gap: 1rem;
  }
  
  .masonry-item {
    display: inline-block;
    width: 100%;
  }
  
  @media (min-width: 576px) {
    .masonry {
      column-count: 3;
    }
  }
  
  @media (min-width: 768px) {
    .masonry {
      column-count: 3;
    }
  }
  
  @media (min-width: 992px) {
    .masonry {
      column-count: 4;
    }
  }
  
  .img-fluid {
    width: 100%;
    height: auto;
    object-fit: cover;
    cursor: pointer;
    border-radius: 0.25rem;
  }
  </style>
  