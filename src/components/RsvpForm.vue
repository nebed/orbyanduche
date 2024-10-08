<template>
        <!-- Bootstrap Alerts for Success/Failure -->
    <div v-if="alert.visible" class="alert alert-dismissible fade show" :class="alert.class" role="alert">
        <strong>{{ alert.title }}!</strong> {{ alert.message }}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" @click="alert.visible = false"></button>
    </div>
    <form class="needs-validation" @submit.prevent="validateForm" novalidate>
      <div class="row g-3 my-4 needs-validation">
        <div class="col-sm-6">
          <label for="firstName" class="form-label">First name</label>
          <input
            type="text"
            :class="{'is-invalid': errors.firstName, 'is-valid': !errors.firstName && form.firstName}"
            class="form-control"
            id="firstName"
            v-model="form.firstName"
            @input="validateField('firstName')"
            required
          >
          <div class="invalid-feedback" v-if="errors.firstName">
            {{ errors.firstName }}
          </div>
        </div>
  
        <div class="col-sm-6">
          <label for="lastName" class="form-label">Last name</label>
          <input
            type="text"
            :class="{'is-invalid': errors.lastName, 'is-valid': !errors.lastName && form.lastName}"
            class="form-control"
            id="lastName"
            v-model="form.lastName"
            @input="validateField('lastName')"
            required
          >
          <div class="invalid-feedback" v-if="errors.lastName">
            {{ errors.lastName }}
          </div>
        </div>
  
        <div class="col-12">
          <label for="email" class="form-label">Email</label>
          <input
            type="email"
            :class="{'is-invalid': errors.email, 'is-valid': !errors.email && form.email}"
            class="form-control"
            id="email"
            v-model="form.email"
            @input="validateField('email')"
            required
          >
          <div class="invalid-feedback" v-if="errors.email">
            {{ errors.email }}
          </div>
        </div>
  
        <div class="col-12">
          <label for="phonenumber" class="form-label">Phone Number <span class="text-muted">(Whatsapp enabled)</span></label>
          <vue-tel-input
            v-model="phone.value"
            @on-input="onPhoneInput"
            v-bind="phone.options"
          ></vue-tel-input>
          <div class="invalid-feedback" v-if="!phone.inputValue.valid">
            Please enter a valid phone number
          </div>
        </div>
  
        <div class="col-12">
          <label for="additional-guests" class="form-label">No. of Accompanying Guests <span class="text-muted">(Optional)</span></label>
          <select
            class="form-select"
            id="additional-guests"
            v-model="form.additionalGuests"
            @change="validateField('additionalGuests')"
          >
            <option  type="number" value=0>No additional guests</option>
            <option  type="number" value=1>1</option>
            <option  type="number" value=2>2</option>
          </select>
          <div class="invalid-feedback" v-if="errors.additionalGuests">
            {{ errors.additionalGuests }}
          </div>
        </div>
      </div>
  
      <button class="w-100 btn btn-danger btn-lg" type="submit">Confirm</button>
    </form>
  </template>
  

<script setup>
  import { reactive, computed, ref } from 'vue';

    // Define reactive state
  const form = reactive({
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
    additionalGuests: 0
  });

  const phone = reactive({
    value: "",
    isBlurred: false,
    inputValue: {
      formatted: "",
      valid: false,
      country: undefined,
    },
    options: {
      autoFormat: true,
      styleClasses: computed(() => {
        return {
          'is-invalid': !phone.inputValue.valid && phone.value != ''
        };
      }),
      inputOptions: {
        showDialCodeInList: true,
        id: 'phonenumber', 
        required: true,
        styleClasses: computed(() => {
        return {
          'form-control is-invalid': !phone.inputValue.valid && phone.value != '',
          'form-control is-valid': phone.inputValue.valid && !phone.value != ''
        };
      })
      },
      validCharactersOnly: true,
    },
  })
  
  const errors = reactive({});

  const alert = reactive({
    visible: false,
    class: '',
    title: '',
    message: ''
  });

  const username = import.meta.env.VITE_API_USERNAME; 
  const password = import.meta.env.VITE_API_PASSWORD;
  const api_host = import.meta.env.VITE_API_HOST;
  const auth = 'Basic ' + btoa(username + ':' + password);

  function onPhoneInput(formattedNumber, input) {
    phone.inputValue = input;
  };

  function showAlert(title, message, type) {
    alert.title = title;
    alert.message = message;
    alert.class = `alert-${type}`;
    alert.visible = true;
  }
  
  // Function to validate email format
  function validateEmail(email) {
    const re = /^(([^<>()\[\]\.,;:\s@"]+(\.[^<>()\[\]\.,;:\s@"]+)*)|(".+"))@(([^<>()[\]\.,;:\s@"]+\.[^<>()[\]\.,;:\s@"]{2,}))$/i;
    return re.test(String(email).toLowerCase());
  }
  
  // Function to validate additional guests (must be between 0 and 5)
  function validateAdditionalGuests(additionalGuests) {
    const value = parseInt(additionalGuests, 0);
    return Number.isInteger(value) && value >= 0 && value <= 2;
  }
  
  // Function to validate individual fields
  function validateField(field) {
    switch (field) {
      case 'firstName':
        errors.firstName = form.firstName.trim() ? '' : 'Valid first name is required.';
        break;
      case 'lastName':
        errors.lastName = form.lastName.trim() ? '' : 'Valid last name is required.';
        break;
      case 'email':
        errors.email = form.email && validateEmail(form.email) ? '' : 'Please enter a valid email address.';
        break;
      case 'additionalGuests':
        errors.additionalGuests = validateAdditionalGuests(form.additionalGuests) ? '' : 'Please select a valid number of guests (0-2).';
        break;
    }
  }

  // Computed property to check if the form is valid
  const isValid = () => {
    validateField('firstName');
    validateField('lastName');
    validateField('email');
    validateField('additionalGuests');
    return !errors.firstName && !errors.lastName && !errors.email && !errors.additionalGuests && phone.inputValue.valid;
  }
  
  // Form validation handler
  function validateForm() {
    if (isValid()) {
      submitForm();
    }
  }
  
    async function submitForm() {
        if (isValid()) {
            try {
                form.phoneNumber = phone.inputValue.number
                const response = await fetch(api_host + '/api/rsvp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': auth
                },
                body: JSON.stringify(form)
                });
                const responseData = await response.json();
                if (response.ok) {
                    showAlert('Success', responseData.message || 'Your RSVP has been submitted successfully.', 'success');
                } else {
                    showAlert('Failure', responseData.message || 'There was an error submitting your RSVP.', 'danger');
                }
            } catch (error) {
                showAlert('Failure', 'There was an error submitting your RSVP.', 'danger');
            }
        }
    }
  </script>
  