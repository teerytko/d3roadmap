(function() {
  require.config({
    baseUrl: '/vendor/',
    paths: {
      jquery:     'jquery/dist/jquery',
      bootstrap:  'bootstrap/dist/js/bootstrap',
      bseditable: 'x-editable/dist/bootstrap3-editable/js/bootstrap-editable.min',
      bsdatepicker: 'bootstrap-datepicker/js/bootstrap-datepicker',
    },
    shim: {
      bsdatepicker: ['boostrap'],
      bseditable: ['boostrap'],
      bootstrap: ['jquery']
    }
  });
}).call(this);
