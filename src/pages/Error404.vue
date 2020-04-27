<template>
  <div class="fixed-center text-center">
    <p>
      <img
        src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/SARS-CoV-2_without_background.png/1280px-SARS-CoV-2_without_background.png"
        style="width:30vw;max-width:150px;"
      >
    </p>
    <p class="text-faded">
      Page not found <strong>(404)</strong>
    </p>
    <q-btn
      color="primary"
      style="width:200px;"
      to="/"
      label="Go back"
    />
  </div>
</template>

<script>
export default {
  name: 'Error404'
}
</script>
