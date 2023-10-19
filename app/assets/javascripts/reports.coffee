reportsRun = () ->
  button = this
  $.getJSON(this.dataset.resultUrl).then((data) ->
    document.getElementById('js-report-run-result').innerHTML = data.report.result
    button.setAttribute('data-result-loaded', 'true')
  )

reportsPreviewRender = (data) ->
  document.getElementById('js-report-preview-result').innerHTML = data.report.result

document.addEventListener 'turbolinks:load', ->
  # report result
  runner = $('#js-report-run').on('click', reportsRun)
  if runner.length && !runner.data('resultLoaded')
    runner.click()

  # report preview
  $('#js-report-preview').on('click', () ->
    query = document.getElementById('report_query').CodeMirror.getValue()
    return unless query.trim()

    $.post({
      url: '/reports/preview.json',
      data: {
        report: {
          query: query
        }
      }
    }).then(reportsPreviewRender, (xhr) ->
      if xhr.status == 422
        reportsPreviewRender(JSON.parse(xhr.responseText))
    )
  )


  return
