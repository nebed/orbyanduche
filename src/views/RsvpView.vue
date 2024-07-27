<script setup>
import RsvpForm from '../components/RsvpForm.vue';
</script>

<template>
  <div class="container argesta-text mb-5">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-6 col-xl-6">
            <div class="card mb-3">
                <img src="@/assets/images/rsvp.jpg" class="card-img-top" alt="image of orby and uche showing up util the cheat alone">
                <div class="card-body">
                    <h4 class="card-title blacksword-text display-5">Confirm Your Attendance</h4>
                    <p class="card-text">Please complete this form to confirm your attendance and receive the entry ticket</p>
                    <main class="form-signin">
                      <RsvpForm />
                    </main>
                </div>
            </div>
        </div>
    </div>
</div>
</template>