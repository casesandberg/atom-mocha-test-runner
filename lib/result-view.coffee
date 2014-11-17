{$, $$$, View} = require 'atom'

module.exports =
class ResultView extends View

  @content: ->
    @div class: 'mocha-test-runner', =>
      @div outlet: 'resizeHandle', class: 'resize-handle'
      @div class: 'panel', =>
        @div outlet: 'heading', class: 'heading', =>
          @div class: 'pull-right', =>
            @span outlet: 'closeButton', class: 'close-icon'
          @span outlet: 'headingText', =>
            @span class: 'heading-failing'
            # @span class: 'heading-passing', 'Mocha test results'
            @span class: 'heading-failed-tests'
        @div class: 'panel-body', =>
          @pre outlet: 'results', class: 'results'

  initialize: (state) ->
    @height state?.height
    @closeButton.on 'click', => @trigger 'result-view:close'
    @resizeHandle.on 'mousedown', (e) => @resizeStarted e
    @results.addClass 'native-key-bindings'
    @results.attr 'tabindex', -1

  serialize: ->
    height: @height()

  resizeStarted: ({pageY}) ->
    @resizeData =
      pageY: pageY
      height: @height()
    $(document.body).on 'mousemove', @resizeView
    $(document.body).on 'mouseup', @resizeStopped

  resizeStopped: ->
    $(document.body).off 'mousemove', @resizeView
    $(document.body).off 'mouseup', @resizeStopped

  resizeView: ({pageY}) =>
    @height @resizeData.height + @resizeData.pageY - pageY

  reset: ->
    @headingText.find('.heading-failed-tests').html('')
    @heading.removeClass 'alert-success alert-danger'
    @results.empty()

  addLine: (line) ->
    if line isnt '\n'
      @results.append line

      passing = line.match /[0-9]+\s*passing/g
      failing = line.match /[0-9]+\s*failing/g

      failingTests = line.match /(<span style="color:#ff7e76">  [0-9]\) ).*(?=<\/span>)/

      if failing
        @headingText.find('.heading-failing').html failing

    #   if passing
    #     @headingText.find('.heading-passing').html passing

      if failingTests
        testName = failingTests[0].replace /(<span style="color:#ff7e76">  [0-9]\) )/, ''

        if @headingText.find('.heading-failed-tests').html() == ''
          @headingText.find('.heading-failed-tests').html ' -- ' + testName
        else
          @headingText.find('.heading-failed-tests').html @headingText.find('.heading-failed-tests').html() + ', ' + testName

  success: ->
    @heading.addClass 'alert-success'

  failure: ->
    @heading.addClass 'alert-danger'
