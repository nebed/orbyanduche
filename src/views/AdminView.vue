<template>
  <div class="container mt-5">
    <h1 class="mb-4">Admin Panel</h1>
    <div class="row mb-3">
        <div class="col-6">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Approved Guests</h5>
                    <h6 class="card-subtitle mb-2 text-muted">Guests invited</h6>
                    <p class="card-text fw-bold">{{ approvedGuestsCount }}</p>
                </div>
            </div>
        </div>
        <div class="col-6">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Pending Guests</h5>
                    <h6 class="card-subtitle mb-2 text-muted">Guests yet to be reviewed</h6>
                    <p class="card-text fw-bold">{{ pendingGuestsCount }}</p>
                </div>
            </div>
        </div>
    </div>
    <div v-if="guests.length" class="table-responsive">
      <table class="table table-striped table-bordered">
        <thead class="table-dark">
          <tr>
            <th>#</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Email</th>
            <th>Phone Number</th>
            <th>Additional Guests</th>
            <th>Approved</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="guest in guests" :key="guest.id">
            <td>{{ guest.id }}</td>
            <td>{{ guest.firstName }}</td>
            <td>{{ guest.lastName }}</td>
            <td>{{ guest.email }}</td>
            <td>{{ guest.phoneNumber }}</td>
            <td>{{ guest.additionalGuests }}</td>
            <td>{{ guest.approved ? 'Yes' : 'No' }}</td>
            <td>
              <button class="btn btn-success btn-sm me-2" @click="approveGuest(guest.id)">Approve</button>
              <button class="btn btn-danger btn-sm" @click="deleteGuest(guest.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else>
      <p>No guests found.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';

// State to hold the guest data
const guests = ref([]);
const api_host = import.meta.env.VITE_API_HOST;

const approvedGuestsCount = computed(() =>
  guests.value.reduce((count, guest) => (guest.approved ? count + 1 + guest.additionalGuests : count), 0)
);
const pendingGuestsCount = computed(() =>
  guests.value.reduce((count, guest) => (!guest.approved ? count + 1 + guest.additionalGuests : count), 0)
);

// Fetch guests from the API
async function fetchGuests() {
  try {
    const response = await fetch(`${api_host}/api/rsvps`, {
      method: 'GET',
      headers: {
        'Authorization': 'Basic ' + btoa(import.meta.env.VITE_API_USERNAME + ':' + import.meta.env.VITE_API_PASSWORD)
      }
    });
    if (response.ok) {
      guests.value = await response.json();
    } else {
      console.error('Failed to fetch guests');
    }
  } catch (error) {
    console.error('Error fetching guests:', error);
  }
}

// Approve a guest
async function approveGuest(id) {
  try {
    const response = await fetch(`${api_host}/api/rsvp/${id}/approve`, {
      method: 'PATCH',
      headers: {
        'Authorization': 'Basic ' + btoa(import.meta.env.VITE_API_USERNAME + ':' + import.meta.env.VITE_API_PASSWORD),
        'Content-Type': 'application/json'
      }
    });
    if (response.ok) {
      // Refresh the guest list after approving
      fetchGuests();
    } else {
      console.error('Failed to approve guest');
    }
  } catch (error) {
    console.error('Error approving guest:', error);
  }
}

// Delete a guest
async function deleteGuest(id) {
  try {
    const response = await fetch(`${api_host}/api/rsvp/${id}`, {
      method: 'DELETE',
      headers: {
        'Authorization': 'Basic ' + btoa(import.meta.env.VITE_API_USERNAME + ':' + import.meta.env.VITE_API_PASSWORD)
      }
    });
    if (response.ok) {
      // Refresh the guest list after deleting
      fetchGuests();
    } else {
      console.error('Failed to delete guest');
    }
  } catch (error) {
    console.error('Error deleting guest:', error);
  }
}

onMounted(() => {
  fetchGuests();
});
</script>