(function () {
  'use strict';

  module.exports = function () {
    var url = require('url');

    var lastFormField = null;

    this.When(/^I click on '([^']*)'$/, function (linkText) {
      var menuPath = (linkText.indexOf('>') !== -1);
      var getSelector = function(_linkText, level) {
        if (typeof level === 'number')
          return '#' + _linkText.replace(/[^a-z]/ig, '-').toLowerCase() + '.level-' + level;
        else
          return '(//a|//input|//button)[contains(.,"' + _linkText + '")]';
      }

      client.waitForExist('#loaded');

      if (menuPath) {
        client.execute(function(s0) {
          $(s0).click();
        }, getSelector(linkText.split(' > ')[0], 0));
        client.pause(600);

        client.execute(function(s1) {
          $(s1).click();
        }, getSelector(linkText.split(' > ')[1], 1));
        client.pause(600);


        client.waitForExist('#loaded');
      } else {
        client.execute(function(linkText) {
          $(':contains("' + linkText + '")').click();
        }, linkText);
      }
    });

    this.When(/^I fill in '([^']*)' with '([^']*)'$/, function (labelText, fieldValue) {
      var selector = lastFormField = 'label=' + labelText;

      client.waitForExist('#loaded');
      client.element(selector);
      var fieldId = client.getAttribute(selector, 'for');
      client.setValue('#' + fieldId, fieldValue);
    });

    this.When(/^I submit the form$/, function() {
      client.waitForExist('#loaded');
      client.waitForVisible(lastFormField);
      client.submitForm(lastFormField);
    });

  };
})();