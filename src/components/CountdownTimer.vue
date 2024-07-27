<template>
    <div class="bg-black bg-gradient text-light argesta-text pt-5 pb-5 text-center mb-3">
      <p class="text-uppercase">Let the countdown begin</p>
      <h3 class="text-light display-5">{{ countdown.days }} days  {{ countdown.hours }} hours  {{ countdown.minutes }} minutes  {{ countdown.seconds }} seconds</h3>
    </div>
</template>
  
  <script setup>
  import { onMounted, onBeforeUnmount, reactive } from 'vue';
  
  const targetDate = new Date('2024-12-14T09:00:00+01:00');
  
  const countdown = reactive({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });
  
  const calculateCountdown = () => {
    const now = new Date();
    const distance = targetDate - now;
  
    if (distance < 0) {
      clearInterval(interval);
      countdown.days = 0;
      countdown.hours = 0;
      countdown.minutes = 0;
      countdown.seconds = 0;
      return;
    }
  
    countdown.days = Math.floor(distance / (1000 * 60 * 60 * 24));
    countdown.hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    countdown.minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    countdown.seconds = Math.floor((distance % (1000 * 60)) / 1000);
  };
  
  let interval;
  
  onMounted(() => {
    calculateCountdown();
    interval = setInterval(calculateCountdown, 1000);
  });
  
  onBeforeUnmount(() => {
    clearInterval(interval);
  });
  </script>
  
  <style scoped>
  .countdown-timer {
    font-family: Arial, sans-serif;
    font-size: 1.5rem;
    color: #333;
    text-align: center;
  }
  </style>