<template>
  <div>
    <section v-if="!$auth.ready()">
      <div class="lds-container">
        <div class="lds-dual-ring" />
      </div>
    </section>

    <v-app v-cloak>
      <router-view v-if="$auth.ready()" />
    </v-app>
  </div>
</template>

<style>
.lds-container {
  position:fixed; top:0; left:0; width:100vw; display: flex;align-items: center;justify-content: center; height: 100vh;
}

.lds-dual-ring {
  display: inline-block;
  width: 64px;
  height: 64px;
}

.lds-dual-ring:after {
  content: " ";
  display: block;
  width: 46px;
  height: 46px;
  margin: 1px;
  border-radius: 50%;
  border: 5px solid #555;
  border-color: #555 transparent #555 transparent;
  animation: lds-dual-ring 1.2s linear infinite;
}

@keyframes lds-dual-ring {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

  [v-cloak] { display: none; }

</style>
