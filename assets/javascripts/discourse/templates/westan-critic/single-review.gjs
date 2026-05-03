import ReviewForm from "../../components/westan-critic/review-form";

<template>
<section class="westan-critic__section">
  <h1 class="westan-title">{{@model.album.title}} — {{@model.album.artist}}</h1>
  <ReviewForm
    @album={{@model.album}}
    @existing={{@model.existing}}
  />
</section>
</template>
