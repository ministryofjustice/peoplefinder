//= require modules/virtual_pageview

describe 'VirtualPageview', ->
  element = null

  describe 'given "data-virtual-pageview" anchor link', ->

    setUpPage = (page_url) ->
      element = $('<body>' +
        '<a id="a_link" data-virtual-pageview="' + page_url + '" href="https://peoplefinder.service.gov.uk/people/john-smith">John Smith</a>' +
        '</body>')
      $(document.body).append(element)
      new window.VirtualPageview.bindLinks()

    afterEach ->
      element.remove()
      element = null

    describe 'with single page url', ->
      beforeEach ->
        setUpPage('/top-3-search-result')

      describe 'on first click', ->
        it 'dispatches pageview', ->
          spyOn window, 'dispatchPageView'
          $('#a_link').trigger 'click'

          expect(window.dispatchPageView).toHaveBeenCalledWith('/top-3-search-result')

    describe 'with comma list of page urls', ->
      beforeEach ->
        setUpPage('/search-result,/top-3-search-result')

      describe 'on first click', ->
        it 'dispatches pageview for each url', ->
          spyOn window, 'dispatchPageView'
          $('#a_link').trigger 'click'

          expect(window.dispatchPageView).toHaveBeenCalledWith('/search-result')
          expect(window.dispatchPageView).toHaveBeenCalledWith('/top-3-search-result')
