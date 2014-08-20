(function() {
  require.config({
    baseUrl: '/',
    paths: {
      jquery:     'vendor/jquery/dist/jquery',
      bootstrap:  'vendor/bootstrap/dist/js/bootstrap',
      bseditable: 'vendor/x-editable/dist/bootstrap3-editable/js/bootstrap-editable.min',
      bsdatepicker: 'vendor/bootstrap-datepicker/js/bootstrap-datepicker',
      d3: 'vendor/d3/d3'
    },
    shim: {
      bsdatepicker: {
        deps: ['bootstrap']
      },
      bseditable: {
        deps: ['bootstrap']
      },
      bootstrap:  {
        deps: ['jquery']
      }
    }
  });
}).call(this);
