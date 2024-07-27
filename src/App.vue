<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div class="container">
    <header class="d-flex flex-wrap justify-content-center py-3 mb-4">
      <a href="/" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto link-body-emphasis text-decoration-none">
        <span class="fs-1 blacksword-text">Orby & Uche</span>
      </a>

      <ul class="nav nav-pills">
        <li class="nav-item argesta-text text-uppercase"><RouterLink class="nav-link" to="/ourstory">Our Story</RouterLink></li>
        <li class="nav-item argesta-text text-uppercase"><RouterLink class="btn btn-outline-danger" to="/rsvp">RSVP</RouterLink></li>
      </ul>
    </header>
  </div>
  <RouterView />
</template>

<style scoped>

</style>
