module.exports = ->
  lastFormField = null


  # Follow a menu path: 'Inbound Calls > New Inbound Call'
  # Click on a text fragment: 'Mark as resolved'
  # Click on any element: '.btn.cancel'
  @When 'I click on \'$linkText\'', (linkText) ->
    menuPath = linkText.indexOf('>') isnt -1

    browser.waitForExist '#loaded'
    if menuPath
      browser.execute(((s0) ->
        $(".level-0[title=#{s0}]").click()
        return
      ), linkText.split(' > ')[0])
      browser.pause 300
      browser.execute(((s1) ->
        $(".level-1[title=#{s1}]").click()
        return
      ), linkText.split(' > ')[1])
      browser.pause 300
      browser.waitForExist '#loaded'
    else if browser.isExisting('//a[@title="' + linkText + '"]')
      browser.execute ((title) ->
        $('a[title="' + title + '"]').click()
        return
      ), linkText
      browser.pause 300
      browser.waitForExist '#loaded'
    else
      if linkText.match(/(^\.|^\#)/ig)
        browser.waitForVisible linkText
        browser.click linkText
      else
        browser.pause 300
        foundAndClicked = browser.execute(((linkText) ->

          # Taken from jQuery UI
          zIndex = (elem) ->
            elem = $(elem)
            position = 0
            value = 0

            while elem.length and elem[0] isnt document
              # Ignore z-index if position is set to a value where z-index is ignored by the browser
              # This makes behavior of this function consistent across browsers
              # WebKit always returns auto if the element is positioned
              position = elem.css('position')
              if (position is 'absolute' or position is 'relative' or position is 'fixed')
                # IE returns 0 when zIndex is not specified
                # other browsers return a string
                # we ignore the case of nested elements with an explicit value of 0
                # <div style="z-index: -10;"><div style="z-index: 0;"></div></div>
                value = parseInt(elem.css('zIndex'), 10)
                return value if (not isNaN(value) and value isnt 0)

              elem = elem.parent()
            return 0

          # Sort matched elements by computed zIndex and click on the topmost one
          el = $('a,input,button,span').filter(':contains("' + linkText + '")').sort((a, b) ->
            Number(zIndex(b)) - Number(zIndex(a))
          )
          if el.length > 0
            el.first().click()
            true
          else
            false
        ), linkText)
        browser.pause 300
        browser.waitForExist '#loaded'
        expect(foundAndClicked.value).not.toBe false, 'Could not find any element (a|input|button|span) containing text: ' + linkText
    return


  @When 'I fill in \'$labelText\' with \'$fieldValue\'', (labelText, fieldValue) ->
    selector = 'label=' + labelText
    lastFormField = selector
    browser.waitForExist(selector)
    fieldId = browser.getAttribute(selector, 'for')
    browser.setValue('#' + fieldId, fieldValue)

  @When 'I submit the form', ->
    browser.waitForVisible(lastFormField)
    browser.submitForm(lastFormField)

  @When 'I press \'$key\'', (key) ->
    key.replace('Back space', '\uE003')
    key.replace('Tab', '\uE004')
    key.replace('Clear', '\uE005')
    key.replace('Return', '\uE006')
    key.replace('Enter', '\uE007')
    key.replace('Shift', '\uE008')
    key.replace('Control', '\uE009')
    key.replace('Alt', '\uE00A')
    key.replace('Escape', '\uE00C')
    key.replace('Left arrow', '\uE012')
    key.replace('Up arrow', '\uE013')
    key.replace('Right arrow', '\uE014')
    key.replace('Down arrow', '\uE015')
    key.replace('Pageup', '\uE00E')
    key.replace('Pagedown', '\uE00F')
    key.replace('Space', '\uE00D')
    browser.keys(key)
