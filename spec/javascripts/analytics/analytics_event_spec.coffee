//= require analytics/analytics_event

describe 'AnalyticsEvent', ->
  element = null

  describe 'given "data-event-category" anchor link', ->

    beforeEach ->
      element = $('<body>' +
        '<a id="a_link" data-event-category="Search result" ' +
        'data-event-action="Click result 1" ' +
        'href="https://peoplefinder.service.gov.uk/people/john-smith">John Smith</a>' +
        '</body>')
      $(document.body).append(element)
      new window.AnalyticsEvent.bindLinks()

    afterEach ->
      element.remove()
      element = null

    describe 'click on "data-event-label" element', ->
      it "dispatches analytics event", ->
        spyOn window, 'dispatchAnalyticsEvent'
        $('#a_link').trigger 'click'

        expect(window.dispatchAnalyticsEvent).toHaveBeenCalledWith('Search result', 'Click result 1', 'John Smith')
