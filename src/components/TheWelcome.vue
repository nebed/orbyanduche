<script setup>
import CountdownTimer from './CountdownTimer.vue'
import LocationIcon from './icons/IconLocation.vue'
</script>

<template>

<div class="text-center">
  <div class="row">
    <div class="">
      <h2 class="display-3 fw-bold text-body-emphasis blacksword-text">14 . 12 . 2024</h2>
    </div>
    <div class="d-none d-md-block d-lg-block d-xl-block col-md-4 col">
      <div class="container p-5">
        <img src="@/assets/images/orby_uche_left.jpg" class="img-fluid p-5" alt="Image of Orby and Uche in an Embrace" width="700" height="500" loading="lazy">
      </div>
    </div>
    <div class="col-md-4 col mx-auto my-auto">
      <div class="container">
        <img src="@/assets/images/orby_uche_home.jpg" class="img-fluid rounded-3" alt="Image of Orby in a white dress and Uche in a black suit in an Embrace" width="700" height="500" loading="lazy">
      </div>
      <p class="text-wrap argesta-text text-uppercase fw-medium mt-3">JOIN US AS WE EMBARK ON A JOURNEY OF LOVE, JOY, AND ETERNAL HAPPINESS.</p>
    </div>
    <div class="d-none d-md-block d-lg-block d-xl-block col-md-4 col">
      <div class="container p-5">
        <img src="@/assets/images/orby_uche_right.jpg" class="img-fluid p-5" alt="Image of Orby and Uche in an Embrace" width="700" height="500" loading="lazy">
      </div>
    </div>
  </div>
</div>
<CountdownTimer />
<div class="text-center container location-section">
  <p class="blacksword-text display-3 pt-2">Location</p>
  <div class="row flex-lg-row-reverse align-items-center m-3">
    <div class="col-10 col-sm-8 mx-auto col-lg-6">
      <img src="@/assets/images/church_image.jpg" class="img-fluid rounded-4 p-2" alt="Image of St Paul's Anglican church in black and white" width="700" height="500" loading="lazy">
    </div>
    <div class="col-lg-6 p-2">
      <div class="mb-3 text-start argesta-text">
        <h5>
          Church Wedding
        </h5>
        <a class="link-dark link-underline link-underline-opacity-0" href="https://maps.app.goo.gl/8BeujCDvzgx8FXY98">
          <p class="fw-bolder">
            <h6> <LocationIcon />  St Paul's Anglican Church, Abayi</h6>
            <p class="fs-6 fw-light">
              48JR+9V2, Umuocham Rd, Abayi, Aba 453111, Abia, Nigeria
            </p>
          </p>
        </a>
      </div>
    </div>
  </div>
</div>
<div class="bg-black argesta-text text-light pt-5 pb-5 mb-3 bg-gradient text-center">
  <div>
    <p class="text-uppercase">Here's a sneak peek of</p>
    <h3 class="text-capitalize display-5">Our Special Day's Schedule</h3>
    <div class="text-uppercase mt-4">
      <h6 class="display-6">10:00 AM</h6>
      <p>Church Ceremony</p>
    </div>
    <div class="text-uppercase">
      <h6 class="display-6">1:00 PM</h6>
      <p>Wedding Party</p>
    </div>
  </div>
</div>
<div class="container mb-5">
  <div class="row text-center">
    <div class="col-6">
      <p class="blacksword-text display-6 pt-2 mb-1">Gallery</p>
      <img src="@/assets/images/uche_personal.jpg" class="img-fluid rounded-4 p-2" alt="A picture of Uche alone in a suit" width="200" height="500" loading="lazy">
      <p class="argesta-text p-2">Visit our gallery to see all the beautiful moments and memories.</p>
      <div class="argesta-text row justify-content-center">
        <div class="col-8 d-grid mx-auto gap-2">
          <a href="/gallery" class="btn btn-outline-danger">
            View
          </a>
        </div>
      </div>
    </div>
    <div class="col-6">
      <p class="blacksword-text display-6 pt-2 mb-1">Colors</p>
      <img src="@/assets/images/orby_personal.jpg" class="img-fluid rounded-4 p-2" alt="A picture of Orby alone in a traditional attire" width="200" height="500" loading="lazy">
      <p class="argesta-text p-2">We've chosen these beautiful shades to celebrate our wedding.</p>
      <div class="row justify-content-center argesta-text">
        <div class="col-8">
          <div class="swatch">
            <div class="color" style="background-color: rgb(244, 227, 209);"></div>
            <div class="color" style="background-color: rgb(181, 119, 88);"></div>
            <div class="color" style="background-color: rgb(119, 6, 0);"></div>
            <div class="color" style="background-color: rgb(137, 125, 4);"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

</template>
