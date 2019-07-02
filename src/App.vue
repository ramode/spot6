<template>
	<v-app>
        <router-view v-if="$auth.ready()"></router-view>
		<div v-if="!$auth.ready()">
			Loading ...
		</div>
	</v-app>
</template>
