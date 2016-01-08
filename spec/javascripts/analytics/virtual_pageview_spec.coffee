//= require analytics/virtual_pageview

describe 'VirtualPageview', ->
  element = null

  describe 'given "data-virtual-pageview" anchor link', ->

    beforeEach ->
      element = $('<body>' +
        '<a id="a_link" data-virtual-pageview="/top-3-search-result" href="https://peoplefinder.service.gov.uk/people/john-smith">John Smith</a>' +
        '</body>')
      $(document.body).append(element)
      new window.VirtualPageview.bindLinks()

    afterEach ->
      element.remove()
      element = null

    describe 'on first click', ->
      it 'dispatches pageview', ->
        spyOn window, 'dispatchPageView'
        $('#a_link').trigger 'click'

        expect(window.dispatchPageView).toHaveBeenCalledWith('/top-3-search-result')
