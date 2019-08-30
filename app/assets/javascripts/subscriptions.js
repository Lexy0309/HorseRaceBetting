// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
var stripeResponseHandler;

$(document).ready(function() {
    $('.mask_card_number').mask("9999 9999 9999 9999");
    $('.mask_cvv').mask("999");
    $('.mask_month').mask("99");
    $('.mask_year').mask("9999");
    $('.mask_mobile').mask("9999999999");
    $('.mask_zipcode').mask("9999")  ;
});

jQuery(function() {
  Stripe.setPublishableKey($("meta[name='stripe-key']").attr("content"));
  $('#subscription-form').submit(function(event) {
    var $form;
    $form = $(this);
    // Disable the submit button to prevent repeated clicks
    $form.find('button').prop('disabled', true);
    // Prevent form submittion
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });
});

stripeResponseHandler = function(status, response) {
  var $form, token;
  $form = $('#subscription-form');
  if (response.error) {
    $form.find('.subscription-errors').text(response.error.message);
    $form.find('button').prop('disabled', false);
  } else {
    token = response.id;

    // Stripe.charge.create({
    //   amount:18.8,
    //   currency:usd,
    //   source: "",
    //   descripttion: "Charge for weekly"
    // }, function (err, charge){

    // })
    $form.append($('<input type="hidden" name="payment_gateway_token" />').val(token));
    $form.get(0).submit();
  }
};